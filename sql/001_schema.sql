-- Credit Cashback Tracker
-- PostgreSQL / Neon
--
-- Mo hinh chinh:
--
--   users -> cards -> cashback_programs -> program_conditions
--   users -> user_programs -> campaigns -> campaign_tasks
--                                           ^
--                                           | parent_task_id
--                                           +-- subtasks nhieu cap
--
-- cashback_programs:
--   Dinh nghia chuong trinh goc cua mot the.
--
-- program_conditions:
--   Cac dieu kien cua chuong trinh. Khi tao campaign, moi condition se duoc
--   snapshot thanh mot campaign_task cap cao nhat.
--
-- campaigns:
--   Mot ky theo doi thuc te cua user, vi du thang 09/2026 hoac nam 2026.
--
-- campaign_tasks:
--   - Task goc duoc tao tu program_conditions.
--   - User co the tao subtask bang parent_task_id.
--   - Moi task (ke ca task goc va subtask) co the co cac step rieng trong
--     campaign_task_steps.
--
-- Bao mat: khong luu toan bo so the. Chi luu 4 so cuoi trong cards.last_four.

BEGIN;

-- ============================================================
-- 1. Users and cards
-- ============================================================

CREATE TABLE IF NOT EXISTS users (
  id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT users_email_unique UNIQUE (email)
);

-- Compatibility with the very first users table used in the project.
ALTER TABLE users
  ADD COLUMN IF NOT EXISTS is_active BOOLEAN NOT NULL DEFAULT TRUE;

ALTER TABLE users
  ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

CREATE TABLE IF NOT EXISTS cards (
  id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id INTEGER NOT NULL,
  issuer VARCHAR(100) NOT NULL,
  card_name VARCHAR(150) NOT NULL,
  last_four VARCHAR(4),
  annual_fee NUMERIC(14, 2) NOT NULL DEFAULT 0,
  currency CHAR(3) NOT NULL DEFAULT 'VND',
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT cards_user_fk
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT cards_last_four_check
    CHECK (last_four IS NULL OR last_four ~ '^[0-9]{4}$'),
  CONSTRAINT cards_annual_fee_check
    CHECK (annual_fee >= 0),
  CONSTRAINT cards_user_card_name_unique
    UNIQUE (user_id, card_name)
);

-- ============================================================
-- 2. Rename tables from the first schema version when necessary
-- ============================================================

DO $$
BEGIN
  -- In the first version, campaigns represented program definitions.
  IF to_regclass('cashback_programs') IS NULL
     AND to_regclass('campaigns') IS NOT NULL
     AND EXISTS (
       SELECT 1
       FROM information_schema.columns
       WHERE table_schema = current_schema()
         AND table_name = 'campaigns'
         AND column_name = 'card_id'
     ) THEN
    EXECUTE 'ALTER TABLE campaigns RENAME TO cashback_programs';
  END IF;

  IF to_regclass('cashback_programs') IS NOT NULL
     AND EXISTS (
       SELECT 1
       FROM information_schema.columns
       WHERE table_schema = current_schema()
         AND table_name = 'cashback_programs'
         AND column_name = 'campaign_type'
     )
     AND NOT EXISTS (
       SELECT 1
       FROM information_schema.columns
       WHERE table_schema = current_schema()
         AND table_name = 'cashback_programs'
         AND column_name = 'program_type'
     ) THEN
    EXECUTE 'ALTER TABLE cashback_programs RENAME COLUMN campaign_type TO program_type';
  END IF;

  IF to_regclass('cashback_programs') IS NOT NULL
     AND EXISTS (
       SELECT 1
       FROM information_schema.columns
       WHERE table_schema = current_schema()
         AND table_name = 'cashback_programs'
         AND column_name = 'evaluation_period'
     )
     AND NOT EXISTS (
       SELECT 1
       FROM information_schema.columns
       WHERE table_schema = current_schema()
         AND table_name = 'cashback_programs'
         AND column_name = 'period_type'
     ) THEN
    EXECUTE 'ALTER TABLE cashback_programs RENAME COLUMN evaluation_period TO period_type';
  END IF;

  IF to_regclass('program_conditions') IS NULL
     AND to_regclass('campaign_conditions') IS NOT NULL THEN
    EXECUTE 'ALTER TABLE campaign_conditions RENAME TO program_conditions';
  END IF;

  IF to_regclass('program_conditions') IS NOT NULL
     AND EXISTS (
       SELECT 1
       FROM information_schema.columns
       WHERE table_schema = current_schema()
         AND table_name = 'program_conditions'
         AND column_name = 'campaign_id'
     )
     AND NOT EXISTS (
       SELECT 1
       FROM information_schema.columns
       WHERE table_schema = current_schema()
         AND table_name = 'program_conditions'
         AND column_name = 'program_id'
     ) THEN
    EXECUTE 'ALTER TABLE program_conditions RENAME COLUMN campaign_id TO program_id';
  END IF;

  IF to_regclass('user_programs') IS NULL
     AND to_regclass('user_campaigns') IS NOT NULL THEN
    EXECUTE 'ALTER TABLE user_campaigns RENAME TO user_programs';
  END IF;

  IF to_regclass('user_programs') IS NOT NULL
     AND EXISTS (
       SELECT 1
       FROM information_schema.columns
       WHERE table_schema = current_schema()
         AND table_name = 'user_programs'
         AND column_name = 'campaign_id'
     )
     AND NOT EXISTS (
       SELECT 1
       FROM information_schema.columns
       WHERE table_schema = current_schema()
         AND table_name = 'user_programs'
         AND column_name = 'program_id'
     ) THEN
    EXECUTE 'ALTER TABLE user_programs RENAME COLUMN campaign_id TO program_id';
  END IF;

  IF to_regclass('user_programs') IS NOT NULL
     AND EXISTS (
       SELECT 1
       FROM information_schema.columns
       WHERE table_schema = current_schema()
         AND table_name = 'user_programs'
         AND column_name = 'selected_at'
     )
     AND NOT EXISTS (
       SELECT 1
       FROM information_schema.columns
       WHERE table_schema = current_schema()
         AND table_name = 'user_programs'
         AND column_name = 'subscribed_at'
     ) THEN
    EXECUTE 'ALTER TABLE user_programs RENAME COLUMN selected_at TO subscribed_at';
  END IF;
END
$$;

-- ============================================================
-- 3. Program definitions
-- ============================================================

CREATE TABLE IF NOT EXISTS cashback_programs (
  id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  card_id INTEGER NOT NULL,
  name VARCHAR(200) NOT NULL,

  -- annual_fee_refund, monthly_cashback, custom, ...
  program_type VARCHAR(50) NOT NULL,
  description TEXT,

  -- fixed_amount: reward_value la so tien.
  -- percentage: reward_value la phan tram, vi du 5 nghia la 5%.
  reward_type VARCHAR(20) NOT NULL,
  reward_value NUMERIC(14, 2) NOT NULL,
  reward_cap_amount NUMERIC(14, 2),
  currency CHAR(3) NOT NULL DEFAULT 'VND',

  -- monthly, annual, one_time, custom.
  period_type VARCHAR(20) NOT NULL,
  starts_on DATE,
  ends_on DATE,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT cashback_programs_card_fk
    FOREIGN KEY (card_id) REFERENCES cards(id) ON DELETE CASCADE,
  CONSTRAINT cashback_programs_reward_type_check
    CHECK (reward_type IN ('fixed_amount', 'percentage')),
  CONSTRAINT cashback_programs_reward_value_check
    CHECK (reward_value > 0),
  CONSTRAINT cashback_programs_reward_cap_check
    CHECK (reward_cap_amount IS NULL OR reward_cap_amount >= 0),
  CONSTRAINT cashback_programs_period_type_check
    CHECK (period_type IN ('monthly', 'annual', 'one_time', 'custom')),
  CONSTRAINT cashback_programs_date_range_check
    CHECK (ends_on IS NULL OR starts_on IS NULL OR ends_on >= starts_on),
  CONSTRAINT cashback_programs_card_name_unique
    UNIQUE (card_id, name)
);

CREATE TABLE IF NOT EXISTS program_conditions (
  id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  program_id INTEGER NOT NULL,
  condition_code VARCHAR(50) NOT NULL,
  condition_name VARCHAR(150) NOT NULL,

  -- spend_amount, transaction_count, merchant_category, custom, ...
  condition_type VARCHAR(50) NOT NULL,
  operator VARCHAR(2) NOT NULL,
  target_value NUMERIC(14, 2),
  unit VARCHAR(30),
  is_required BOOLEAN NOT NULL DEFAULT TRUE,
  metadata JSONB NOT NULL DEFAULT '{}'::JSONB,
  sort_order SMALLINT NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT program_conditions_program_fk
    FOREIGN KEY (program_id) REFERENCES cashback_programs(id) ON DELETE CASCADE,
  CONSTRAINT program_conditions_operator_check
    CHECK (operator IN ('>=', '<=', '=', '>', '<')),
  CONSTRAINT program_conditions_target_check
    CHECK (target_value IS NULL OR target_value >= 0),
  CONSTRAINT program_conditions_sort_order_check
    CHECK (sort_order > 0),
  CONSTRAINT program_conditions_program_code_unique
    UNIQUE (program_id, condition_code)
);

-- Add sort_order if program_conditions was migrated from the older schema.
ALTER TABLE program_conditions
  ADD COLUMN IF NOT EXISTS sort_order SMALLINT NOT NULL DEFAULT 1;

-- ============================================================
-- 4. Programs selected by users
-- ============================================================

CREATE TABLE IF NOT EXISTS user_programs (
  id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id INTEGER NOT NULL,
  program_id INTEGER NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'active',
  subscribed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  unsubscribed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT user_programs_user_fk
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT user_programs_program_fk
    FOREIGN KEY (program_id) REFERENCES cashback_programs(id) ON DELETE CASCADE,
  CONSTRAINT user_programs_status_check
    CHECK (status IN ('active', 'paused', 'archived')),
  CONSTRAINT user_programs_user_program_unique
    UNIQUE (user_id, program_id)
);

ALTER TABLE user_programs
  ADD COLUMN IF NOT EXISTS subscribed_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

ALTER TABLE user_programs
  ADD COLUMN IF NOT EXISTS unsubscribed_at TIMESTAMPTZ;

ALTER TABLE user_programs
  ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- A user may only subscribe to programs belonging to their own cards.
CREATE OR REPLACE FUNCTION validate_user_program_ownership()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM cashback_programs p
    JOIN cards c ON c.id = p.card_id
    WHERE p.id = NEW.program_id
      AND c.user_id = NEW.user_id
  ) THEN
    RAISE EXCEPTION 'User % does not own the card of program %',
      NEW.user_id,
      NEW.program_id;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS user_programs_validate_ownership ON user_programs;

CREATE TRIGGER user_programs_validate_ownership
BEFORE INSERT OR UPDATE OF user_id, program_id ON user_programs
FOR EACH ROW
EXECUTE FUNCTION validate_user_program_ownership();

-- ============================================================
-- 5. Campaign periods
-- ============================================================

CREATE TABLE IF NOT EXISTS campaigns (
  id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_program_id INTEGER NOT NULL,

  -- 2026-09 for a monthly campaign, 2026 for an annual campaign.
  period_key VARCHAR(20) NOT NULL,
  period_label VARCHAR(100) NOT NULL,
  starts_on DATE NOT NULL,
  ends_on DATE NOT NULL,

  status VARCHAR(30) NOT NULL DEFAULT 'planned',
  expected_cashback_amount NUMERIC(14, 2),
  actual_cashback_amount NUMERIC(14, 2),
  currency CHAR(3) NOT NULL DEFAULT 'VND',
  cashback_received_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT campaigns_user_program_fk
    FOREIGN KEY (user_program_id) REFERENCES user_programs(id) ON DELETE CASCADE,
  CONSTRAINT campaigns_status_check
    CHECK (
      status IN (
        'planned',
        'in_progress',
        'requirements_met',
        'cashback_pending',
        'completed',
        'expired',
        'cancelled'
      )
    ),
  CONSTRAINT campaigns_date_range_check
    CHECK (ends_on >= starts_on),
  CONSTRAINT campaigns_expected_cashback_check
    CHECK (expected_cashback_amount IS NULL OR expected_cashback_amount >= 0),
  CONSTRAINT campaigns_actual_cashback_check
    CHECK (actual_cashback_amount IS NULL OR actual_cashback_amount >= 0),

  -- Campaign is only truly completed after cashback was received.
  CONSTRAINT campaigns_completed_requires_cashback_check
    CHECK (
      status <> 'completed'
      OR (
        cashback_received_at IS NOT NULL
        AND actual_cashback_amount IS NOT NULL
        AND completed_at IS NOT NULL
      )
    ),
  CONSTRAINT campaigns_user_program_period_unique
    UNIQUE (user_program_id, period_key)
);

-- Compatibility with the previous campaign-instance schema.
ALTER TABLE campaigns
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- ============================================================
-- 6. Migrate and remove the previous step/template structure
-- ============================================================

-- Preserve old condition-task progress before replacing campaign_tasks.
CREATE TEMP TABLE previous_condition_tasks (
  campaign_id INTEGER,
  source_program_condition_id INTEGER,
  task_code VARCHAR(50),
  name VARCHAR(150),
  description TEXT,
  condition_type VARCHAR(50),
  operator VARCHAR(2),
  target_value NUMERIC(14, 2),
  current_value NUMERIC(14, 2),
  unit VARCHAR(30),
  is_required BOOLEAN,
  metadata JSONB,
  sort_order SMALLINT,
  status VARCHAR(20),
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ
) ON COMMIT DROP;

-- Keep steps from the previous JSONB-based version when this script upgrades
-- an existing database. The task IDs are preserved when that version exists.
CREATE TEMP TABLE previous_task_steps (
  old_task_id INTEGER,
  campaign_id INTEGER,
  task_code VARCHAR(50),
  steps JSONB
) ON COMMIT DROP;

DO $$
BEGIN
  -- The immediately previous version stored steps in campaign_tasks.steps.
  -- Capture them before removing that column. The dynamic SQL keeps this
  -- migration compatible with the older campaign_step_id version too.
  IF to_regclass('campaign_tasks') IS NOT NULL
     AND EXISTS (
       SELECT 1
       FROM information_schema.columns
       WHERE table_schema = current_schema()
         AND table_name = 'campaign_tasks'
         AND column_name = 'steps'
     )
     AND EXISTS (
       SELECT 1
       FROM information_schema.columns
       WHERE table_schema = current_schema()
         AND table_name = 'campaign_tasks'
         AND column_name = 'campaign_id'
     ) THEN
    EXECUTE $migration_steps$
      INSERT INTO previous_task_steps (
        old_task_id,
        campaign_id,
        task_code,
        steps
      )
      SELECT
        ct.id,
        ct.campaign_id,
        ct.task_code,
        ct.steps
      FROM campaign_tasks ct
      WHERE jsonb_typeof(ct.steps) = 'array'
        AND jsonb_array_length(ct.steps) > 0
    $migration_steps$;
  END IF;

  -- Detect campaign_tasks from the previous model via campaign_step_id.
  IF to_regclass('campaign_tasks') IS NOT NULL
     AND EXISTS (
       SELECT 1
       FROM information_schema.columns
       WHERE table_schema = current_schema()
         AND table_name = 'campaign_tasks'
         AND column_name = 'campaign_step_id'
     )
     AND to_regclass('campaign_steps') IS NOT NULL THEN
    EXECUTE $migration$
      INSERT INTO previous_condition_tasks (
        campaign_id,
        source_program_condition_id,
        task_code,
        name,
        description,
        condition_type,
        operator,
        target_value,
        current_value,
        unit,
        is_required,
        metadata,
        sort_order,
        status,
        started_at,
        completed_at,
        created_at
      )
      SELECT
        cs.campaign_id,
        ct.source_program_condition_id,
        ct.task_code,
        ct.name,
        ct.description,
        ct.condition_type,
        ct.operator,
        ct.target_value,
        ct.current_value,
        ct.unit,
        ct.is_required,
        ct.metadata,
        ct.sort_order,
        ct.status,
        ct.started_at,
        ct.completed_at,
        ct.created_at
      FROM campaign_tasks ct
      JOIN campaign_steps cs ON cs.id = ct.campaign_step_id
      WHERE ct.task_type = 'condition'
    $migration$;

    EXECUTE 'DROP TABLE campaign_tasks';
  END IF;

  -- These tables are no longer part of the model.
  EXECUTE 'DROP TABLE IF EXISTS campaign_steps';
  EXECUTE 'DROP TABLE IF EXISTS program_tasks';
  EXECUTE 'DROP TABLE IF EXISTS program_steps';
END;
$$;

-- ============================================================
-- 7. Recursive campaign tasks
-- ============================================================

CREATE TABLE IF NOT EXISTS campaign_tasks (
  id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  campaign_id INTEGER NOT NULL,

  -- NULL means a root task generated from a program condition.
  -- A value means this row is a user-defined subtask of another task.
  parent_task_id INTEGER,

  -- Filled for root tasks generated from program_conditions.
  -- The remaining fields below are snapshots, so campaign history remains
  -- unchanged even if the original condition changes later.
  source_program_condition_id INTEGER,
  task_origin VARCHAR(30) NOT NULL,
  task_code VARCHAR(50) NOT NULL,
  name VARCHAR(150) NOT NULL,
  description TEXT,

  condition_type VARCHAR(50),
  operator VARCHAR(2),
  target_value NUMERIC(14, 2),
  current_value NUMERIC(14, 2),
  unit VARCHAR(30),
  is_required BOOLEAN NOT NULL DEFAULT TRUE,
  metadata JSONB NOT NULL DEFAULT '{}'::JSONB,

  sort_order SMALLINT NOT NULL DEFAULT 1,
  status VARCHAR(20) NOT NULL DEFAULT 'pending',
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT campaign_tasks_campaign_fk
    FOREIGN KEY (campaign_id) REFERENCES campaigns(id) ON DELETE CASCADE,
  CONSTRAINT campaign_tasks_source_condition_fk
    FOREIGN KEY (source_program_condition_id)
    REFERENCES program_conditions(id)
    ON DELETE SET NULL,
  CONSTRAINT campaign_tasks_origin_check
    CHECK (task_origin IN ('program_condition', 'user_defined')),
  CONSTRAINT campaign_tasks_operator_check
    CHECK (operator IS NULL OR operator IN ('>=', '<=', '=', '>', '<')),
  CONSTRAINT campaign_tasks_target_check
    CHECK (target_value IS NULL OR target_value >= 0),
  CONSTRAINT campaign_tasks_current_check
    CHECK (current_value IS NULL OR current_value >= 0),
  CONSTRAINT campaign_tasks_sort_order_check
    CHECK (sort_order > 0),
  CONSTRAINT campaign_tasks_status_check
    CHECK (status IN ('pending', 'in_progress', 'completed', 'skipped', 'failed')),
  CONSTRAINT campaign_tasks_completed_at_check
    CHECK (status <> 'completed' OR completed_at IS NOT NULL),
  CONSTRAINT campaign_tasks_parent_not_self_check
    CHECK (parent_task_id IS NULL OR parent_task_id <> id),

  -- Required by the composite self-reference below. It guarantees that a
  -- subtask and its parent belong to the same campaign.
  CONSTRAINT campaign_tasks_id_campaign_unique
    UNIQUE (id, campaign_id),
  CONSTRAINT campaign_tasks_parent_same_campaign_fk
    FOREIGN KEY (parent_task_id, campaign_id)
    REFERENCES campaign_tasks(id, campaign_id)
    ON DELETE CASCADE
);

-- Steps belong directly to any campaign task. A root task generated from a
-- condition and a user-defined subtask use exactly the same structure.
CREATE TABLE IF NOT EXISTS campaign_task_steps (
  id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  campaign_task_id INTEGER NOT NULL,
  step_code VARCHAR(50) NOT NULL,
  name VARCHAR(150) NOT NULL,
  description TEXT,
  is_required BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order SMALLINT NOT NULL DEFAULT 1,
  status VARCHAR(20) NOT NULL DEFAULT 'pending',
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  metadata JSONB NOT NULL DEFAULT '{}'::JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT campaign_task_steps_task_fk
    FOREIGN KEY (campaign_task_id) REFERENCES campaign_tasks(id) ON DELETE CASCADE,
  CONSTRAINT campaign_task_steps_sort_order_check
    CHECK (sort_order > 0),
  CONSTRAINT campaign_task_steps_status_check
    CHECK (status IN ('pending', 'in_progress', 'completed', 'skipped')),
  CONSTRAINT campaign_task_steps_metadata_object_check
    CHECK (jsonb_typeof(metadata) = 'object'),
  CONSTRAINT campaign_task_steps_completed_at_check
    CHECK (status <> 'completed' OR completed_at IS NOT NULL),
  CONSTRAINT campaign_task_steps_task_code_unique
    UNIQUE (campaign_task_id, step_code),
  CONSTRAINT campaign_task_steps_task_order_unique
    UNIQUE (campaign_task_id, sort_order)
);

-- Migrate steps from the previous JSONB column into normalized rows.
INSERT INTO campaign_task_steps (
  campaign_task_id,
  step_code,
  name,
  description,
  is_required,
  sort_order,
  status,
  completed_at,
  metadata
)
SELECT
  pts.old_task_id,
  COALESCE(NULLIF(step->>'code', ''), 'legacy_step_' || step_no),
  COALESCE(NULLIF(step->>'name', ''), 'Legacy step ' || step_no),
  step->>'description',
  COALESCE((step->>'is_required')::BOOLEAN, TRUE),
  step_no,
  CASE
    WHEN step->>'status' IN ('pending', 'in_progress', 'completed', 'skipped')
      THEN step->>'status'
    ELSE 'pending'
  END,
  CASE
    WHEN step->>'status' = 'completed' THEN
      CASE
        WHEN (step->>'completed_at') IS NULL OR step->>'completed_at' = ''
          THEN NOW()
        ELSE (step->>'completed_at')::TIMESTAMPTZ
      END
    WHEN (step->>'completed_at') IS NULL OR step->>'completed_at' = ''
      THEN NULL
    ELSE (step->>'completed_at')::TIMESTAMPTZ
  END,
  CASE
    WHEN jsonb_typeof(step->'metadata') = 'object'
      THEN step->'metadata'
    ELSE '{}'::JSONB
  END
FROM previous_task_steps pts
CROSS JOIN LATERAL jsonb_array_elements(pts.steps)
  WITH ORDINALITY AS item(step, step_no)
ON CONFLICT (campaign_task_id, step_code) DO NOTHING;

-- The JSONB field is no longer the source of truth.
ALTER TABLE campaign_tasks
  DROP CONSTRAINT IF EXISTS campaign_tasks_steps_array_check;

ALTER TABLE campaign_tasks
  DROP COLUMN IF EXISTS steps;

-- One root task per condition in each campaign.
CREATE UNIQUE INDEX IF NOT EXISTS idx_campaign_tasks_condition_unique
  ON campaign_tasks(campaign_id, source_program_condition_id)
  WHERE source_program_condition_id IS NOT NULL;

-- Unique task codes among root tasks and among siblings.
CREATE UNIQUE INDEX IF NOT EXISTS idx_campaign_tasks_root_code_unique
  ON campaign_tasks(campaign_id, task_code)
  WHERE parent_task_id IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS idx_campaign_tasks_child_code_unique
  ON campaign_tasks(campaign_id, parent_task_id, task_code)
  WHERE parent_task_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_cards_user_id
  ON cards(user_id);

CREATE INDEX IF NOT EXISTS idx_cashback_programs_card_id
  ON cashback_programs(card_id);

CREATE INDEX IF NOT EXISTS idx_program_conditions_program_id
  ON program_conditions(program_id);

CREATE INDEX IF NOT EXISTS idx_user_programs_user_status
  ON user_programs(user_id, status);

CREATE INDEX IF NOT EXISTS idx_campaigns_user_program_status
  ON campaigns(user_program_id, status);

CREATE INDEX IF NOT EXISTS idx_campaign_tasks_campaign_parent
  ON campaign_tasks(campaign_id, parent_task_id);

CREATE INDEX IF NOT EXISTS idx_campaign_task_steps_task_order
  ON campaign_task_steps(campaign_task_id, sort_order);

-- Restore progress copied from the previous campaign_tasks model.
INSERT INTO campaign_tasks (
  campaign_id,
  source_program_condition_id,
  task_origin,
  task_code,
  name,
  description,
  condition_type,
  operator,
  target_value,
  current_value,
  unit,
  is_required,
  metadata,
  sort_order,
  status,
  started_at,
  completed_at,
  created_at
)
SELECT
  campaign_id,
  source_program_condition_id,
  'program_condition',
  task_code,
  name,
  description,
  condition_type,
  operator,
  target_value,
  current_value,
  unit,
  is_required,
  COALESCE(metadata, '{}'::JSONB),
  sort_order,
  status,
  started_at,
  completed_at,
  created_at
FROM previous_condition_tasks
ON CONFLICT DO NOTHING;

-- ============================================================
-- 8. Automatically create one root task per program condition
-- ============================================================

CREATE OR REPLACE FUNCTION create_campaign_tasks_from_conditions()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO campaign_tasks (
    campaign_id,
    source_program_condition_id,
    task_origin,
    task_code,
    name,
    condition_type,
    operator,
    target_value,
    unit,
    is_required,
    metadata,
    sort_order
  )
  SELECT
    NEW.id,
    pc.id,
    'program_condition',
    pc.condition_code,
    pc.condition_name,
    pc.condition_type,
    pc.operator,
    pc.target_value,
    pc.unit,
    pc.is_required,
    pc.metadata,
    pc.sort_order
  FROM user_programs up
  JOIN program_conditions pc ON pc.program_id = up.program_id
  WHERE up.id = NEW.user_program_id
  ON CONFLICT DO NOTHING;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS campaigns_create_tasks ON campaigns;

CREATE TRIGGER campaigns_create_tasks
AFTER INSERT ON campaigns
FOR EACH ROW
EXECUTE FUNCTION create_campaign_tasks_from_conditions();

-- Backfill root tasks for campaigns that existed before this trigger.
INSERT INTO campaign_tasks (
  campaign_id,
  source_program_condition_id,
  task_origin,
  task_code,
  name,
  condition_type,
  operator,
  target_value,
  unit,
  is_required,
  metadata,
  sort_order
)
SELECT
  cp.id,
  pc.id,
  'program_condition',
  pc.condition_code,
  pc.condition_name,
  pc.condition_type,
  pc.operator,
  pc.target_value,
  pc.unit,
  pc.is_required,
  pc.metadata,
  pc.sort_order
FROM campaigns cp
JOIN user_programs up ON up.id = cp.user_program_id
JOIN program_conditions pc ON pc.program_id = up.program_id
ON CONFLICT DO NOTHING;

-- ============================================================
-- 9. Demo users and cards
-- ============================================================

INSERT INTO users (name, email)
VALUES
  ('Nguyen Minh An', 'an@example.com'),
  ('Tran Thu Ha', 'ha@example.com')
ON CONFLICT (email) DO NOTHING;

INSERT INTO cards (
  user_id,
  issuer,
  card_name,
  last_four,
  annual_fee,
  currency
)
SELECT
  u.id,
  'Techcombank',
  'Visa Signature',
  '1234',
  600000,
  'VND'
FROM users u
WHERE u.email = 'an@example.com'
ON CONFLICT (user_id, card_name) DO NOTHING;

INSERT INTO cards (
  user_id,
  issuer,
  card_name,
  last_four,
  annual_fee,
  currency
)
SELECT
  u.id,
  'VPBank',
  'Cashback Platinum',
  '5678',
  500000,
  'VND'
FROM users u
WHERE u.email = 'an@example.com'
ON CONFLICT (user_id, card_name) DO NOTHING;

INSERT INTO cards (
  user_id,
  issuer,
  card_name,
  last_four,
  annual_fee,
  currency
)
SELECT
  u.id,
  'Vietcombank',
  'Visa Platinum',
  '9012',
  800000,
  'VND'
FROM users u
WHERE u.email = 'ha@example.com'
ON CONFLICT (user_id, card_name) DO NOTHING;

-- ============================================================
-- 10. Demo program definitions
-- ============================================================

INSERT INTO cashback_programs (
  card_id,
  name,
  program_type,
  description,
  reward_type,
  reward_value,
  reward_cap_amount,
  currency,
  period_type,
  starts_on
)
SELECT
  c.id,
  'Hoan phi thuong nien',
  'annual_fee_refund',
  'Hoan lai phi thuong nien khi dat du dieu kien trong nam.',
  'fixed_amount',
  600000,
  600000,
  'VND',
  'annual',
  DATE '2026-01-01'
FROM cards c
JOIN users u ON u.id = c.user_id
WHERE u.email = 'an@example.com'
  AND c.card_name = 'Visa Signature'
ON CONFLICT (card_id, name) DO NOTHING;

-- Example from the requirement: spend 10 million, split into shopping,
-- dining, and flexible spending conditions.
INSERT INTO cashback_programs (
  card_id,
  name,
  program_type,
  description,
  reward_type,
  reward_value,
  reward_cap_amount,
  currency,
  period_type,
  starts_on
)
SELECT
  c.id,
  'Cashback chi tieu 10 trieu hang thang',
  'monthly_cashback',
  'Chi 4 trieu mua sam, 3 trieu an uong va 3 trieu tuy y moi thang.',
  'percentage',
  5,
  500000,
  'VND',
  'monthly',
  DATE '2026-01-01'
FROM cards c
JOIN users u ON u.id = c.user_id
WHERE u.email = 'an@example.com'
  AND c.card_name = 'Cashback Platinum'
ON CONFLICT (card_id, name) DO NOTHING;

-- A program An does not subscribe to, demonstrating that owning a card does
-- not automatically add every program to the user's tracked campaigns.
INSERT INTO cashback_programs (
  card_id,
  name,
  program_type,
  description,
  reward_type,
  reward_value,
  reward_cap_amount,
  currency,
  period_type,
  starts_on
)
SELECT
  c.id,
  'Hoan tien sieu thi hang thang',
  'monthly_cashback',
  'Hoan 3% cho chi tieu sieu thi.',
  'percentage',
  3,
  200000,
  'VND',
  'monthly',
  DATE '2026-01-01'
FROM cards c
JOIN users u ON u.id = c.user_id
WHERE u.email = 'an@example.com'
  AND c.card_name = 'Cashback Platinum'
ON CONFLICT (card_id, name) DO NOTHING;

INSERT INTO cashback_programs (
  card_id,
  name,
  program_type,
  description,
  reward_type,
  reward_value,
  reward_cap_amount,
  currency,
  period_type,
  starts_on
)
SELECT
  c.id,
  'Hoan tien mua sam hang thang',
  'monthly_cashback',
  'Hoan 2% cho chi tieu mua sam.',
  'percentage',
  2,
  300000,
  'VND',
  'monthly',
  DATE '2026-01-01'
FROM cards c
JOIN users u ON u.id = c.user_id
WHERE u.email = 'ha@example.com'
  AND c.card_name = 'Visa Platinum'
ON CONFLICT (card_id, name) DO NOTHING;

-- ============================================================
-- 11. Demo program conditions
-- ============================================================

INSERT INTO program_conditions (
  program_id,
  condition_code,
  condition_name,
  condition_type,
  operator,
  target_value,
  unit,
  sort_order,
  metadata
)
SELECT
  p.id,
  v.condition_code,
  v.condition_name,
  v.condition_type,
  v.operator,
  v.target_value,
  v.unit,
  v.sort_order,
  v.metadata
FROM cashback_programs p
JOIN cards c ON c.id = p.card_id
JOIN users u ON u.id = c.user_id
CROSS JOIN (
  VALUES
    (
      'minimum_annual_spend',
      'Chi tieu toi thieu 10 trieu trong nam',
      'spend_amount',
      '>=',
      10000000::NUMERIC,
      'VND',
      1::SMALLINT,
      '{}'::JSONB
    ),
    (
      'minimum_annual_transactions',
      'Thuc hien toi thieu 12 giao dich trong nam',
      'transaction_count',
      '>=',
      12::NUMERIC,
      'transactions',
      2::SMALLINT,
      '{}'::JSONB
    )
) AS v(
  condition_code,
  condition_name,
  condition_type,
  operator,
  target_value,
  unit,
  sort_order,
  metadata
)
WHERE u.email = 'an@example.com'
  AND p.name = 'Hoan phi thuong nien'
ON CONFLICT (program_id, condition_code) DO NOTHING;

INSERT INTO program_conditions (
  program_id,
  condition_code,
  condition_name,
  condition_type,
  operator,
  target_value,
  unit,
  sort_order,
  metadata
)
SELECT
  p.id,
  v.condition_code,
  v.condition_name,
  v.condition_type,
  v.operator,
  v.target_value,
  v.unit,
  v.sort_order,
  v.metadata
FROM cashback_programs p
JOIN cards c ON c.id = p.card_id
JOIN users u ON u.id = c.user_id
CROSS JOIN (
  VALUES
    (
      'shopping_spend',
      'Chi 4 trieu cho mua sam',
      'spend_amount',
      '>=',
      4000000::NUMERIC,
      'VND',
      1::SMALLINT,
      '{"category":"shopping"}'::JSONB
    ),
    (
      'dining_spend',
      'Chi 3 trieu cho an uong',
      'spend_amount',
      '>=',
      3000000::NUMERIC,
      'VND',
      2::SMALLINT,
      '{"category":"dining"}'::JSONB
    ),
    (
      'flexible_spend',
      'Chi 3 trieu tuy y',
      'spend_amount',
      '>=',
      3000000::NUMERIC,
      'VND',
      3::SMALLINT,
      '{"category":"any"}'::JSONB
    )
) AS v(
  condition_code,
  condition_name,
  condition_type,
  operator,
  target_value,
  unit,
  sort_order,
  metadata
)
WHERE u.email = 'an@example.com'
  AND p.name = 'Cashback chi tieu 10 trieu hang thang'
ON CONFLICT (program_id, condition_code) DO NOTHING;

INSERT INTO program_conditions (
  program_id,
  condition_code,
  condition_name,
  condition_type,
  operator,
  target_value,
  unit,
  sort_order,
  metadata
)
SELECT
  p.id,
  'supermarket_spend',
  'Chi 1 trieu tai sieu thi',
  'spend_amount',
  '>=',
  1000000,
  'VND',
  1,
  '{"category":"supermarket"}'::JSONB
FROM cashback_programs p
JOIN cards c ON c.id = p.card_id
JOIN users u ON u.id = c.user_id
WHERE u.email = 'an@example.com'
  AND p.name = 'Hoan tien sieu thi hang thang'
ON CONFLICT (program_id, condition_code) DO NOTHING;

INSERT INTO program_conditions (
  program_id,
  condition_code,
  condition_name,
  condition_type,
  operator,
  target_value,
  unit,
  sort_order,
  metadata
)
SELECT
  p.id,
  'shopping_spend',
  'Chi 3 trieu cho mua sam',
  'spend_amount',
  '>=',
  3000000,
  'VND',
  1,
  '{"category":"shopping"}'::JSONB
FROM cashback_programs p
JOIN cards c ON c.id = p.card_id
JOIN users u ON u.id = c.user_id
WHERE u.email = 'ha@example.com'
  AND p.name = 'Hoan tien mua sam hang thang'
ON CONFLICT (program_id, condition_code) DO NOTHING;

-- ============================================================
-- 12. Demo subscriptions
-- ============================================================

-- An subscribes to annual-fee refund and the 10-million monthly program.
-- An intentionally does not subscribe to the supermarket program.
INSERT INTO user_programs (user_id, program_id, status)
SELECT
  u.id,
  p.id,
  'active'
FROM users u
JOIN cards c ON c.user_id = u.id
JOIN cashback_programs p ON p.card_id = c.id
WHERE u.email = 'an@example.com'
  AND p.name IN (
    'Hoan phi thuong nien',
    'Cashback chi tieu 10 trieu hang thang'
  )
ON CONFLICT (user_id, program_id) DO NOTHING;

INSERT INTO user_programs (user_id, program_id, status)
SELECT
  u.id,
  p.id,
  'active'
FROM users u
JOIN cards c ON c.user_id = u.id
JOIN cashback_programs p ON p.card_id = c.id
WHERE u.email = 'ha@example.com'
  AND p.name = 'Hoan tien mua sam hang thang'
ON CONFLICT (user_id, program_id) DO NOTHING;

-- ============================================================
-- 13. Demo campaigns
-- The trigger automatically creates one root task per condition.
-- ============================================================

INSERT INTO campaigns (
  user_program_id,
  period_key,
  period_label,
  starts_on,
  ends_on,
  status,
  expected_cashback_amount,
  currency
)
SELECT
  up.id,
  '2026',
  'Nam 2026',
  DATE '2026-01-01',
  DATE '2026-12-31',
  'in_progress',
  600000,
  p.currency
FROM user_programs up
JOIN users u ON u.id = up.user_id
JOIN cashback_programs p ON p.id = up.program_id
WHERE u.email = 'an@example.com'
  AND p.name = 'Hoan phi thuong nien'
ON CONFLICT (user_program_id, period_key) DO NOTHING;

-- August is completed because cashback was actually received.
INSERT INTO campaigns (
  user_program_id,
  period_key,
  period_label,
  starts_on,
  ends_on,
  status,
  expected_cashback_amount,
  actual_cashback_amount,
  currency,
  cashback_received_at,
  completed_at
)
SELECT
  up.id,
  '2026-08',
  'Thang 08/2026',
  DATE '2026-08-01',
  DATE '2026-08-31',
  'completed',
  450000,
  450000,
  p.currency,
  TIMESTAMPTZ '2026-09-10 09:00:00+07',
  TIMESTAMPTZ '2026-09-10 09:00:00+07'
FROM user_programs up
JOIN users u ON u.id = up.user_id
JOIN cashback_programs p ON p.id = up.program_id
WHERE u.email = 'an@example.com'
  AND p.name = 'Cashback chi tieu 10 trieu hang thang'
ON CONFLICT (user_program_id, period_key) DO NOTHING;

-- September demonstrates the three generated tasks and custom subtasks.
INSERT INTO campaigns (
  user_program_id,
  period_key,
  period_label,
  starts_on,
  ends_on,
  status,
  expected_cashback_amount,
  currency
)
SELECT
  up.id,
  '2026-09',
  'Thang 09/2026',
  DATE '2026-09-01',
  DATE '2026-09-30',
  'in_progress',
  500000,
  p.currency
FROM user_programs up
JOIN users u ON u.id = up.user_id
JOIN cashback_programs p ON p.id = up.program_id
WHERE u.email = 'an@example.com'
  AND p.name = 'Cashback chi tieu 10 trieu hang thang'
ON CONFLICT (user_program_id, period_key) DO NOTHING;

INSERT INTO campaigns (
  user_program_id,
  period_key,
  period_label,
  starts_on,
  ends_on,
  status,
  expected_cashback_amount,
  currency
)
SELECT
  up.id,
  '2026-09',
  'Thang 09/2026',
  DATE '2026-09-01',
  DATE '2026-09-30',
  'in_progress',
  60000,
  p.currency
FROM user_programs up
JOIN users u ON u.id = up.user_id
JOIN cashback_programs p ON p.id = up.program_id
WHERE u.email = 'ha@example.com'
  AND p.name = 'Hoan tien mua sam hang thang'
ON CONFLICT (user_program_id, period_key) DO NOTHING;

-- Set demo progress for generated root tasks.
UPDATE campaign_tasks ct
SET
  current_value = CASE ct.task_code
    WHEN 'shopping_spend' THEN 1500000
    WHEN 'dining_spend' THEN 1000000
    WHEN 'flexible_spend' THEN 500000
    ELSE ct.current_value
  END,
  status = CASE
    WHEN ct.task_code IN ('shopping_spend', 'dining_spend', 'flexible_spend')
      THEN 'in_progress'
    ELSE ct.status
  END,
  started_at = CASE
    WHEN ct.task_code IN ('shopping_spend', 'dining_spend', 'flexible_spend')
      THEN COALESCE(ct.started_at, TIMESTAMPTZ '2026-09-01 08:00:00+07')
    ELSE ct.started_at
  END,
  updated_at = NOW()
FROM campaigns cp
JOIN user_programs up ON up.id = cp.user_program_id
JOIN users u ON u.id = up.user_id
JOIN cashback_programs p ON p.id = up.program_id
WHERE ct.campaign_id = cp.id
  AND u.email = 'an@example.com'
  AND p.name = 'Cashback chi tieu 10 trieu hang thang'
  AND cp.period_key = '2026-09';

-- Mark all condition tasks of the completed August campaign as completed.
UPDATE campaign_tasks ct
SET
  current_value = COALESCE(ct.target_value, ct.current_value),
  status = 'completed',
  started_at = COALESCE(
    ct.started_at,
    TIMESTAMPTZ '2026-08-01 08:00:00+07'
  ),
  completed_at = COALESCE(
    ct.completed_at,
    TIMESTAMPTZ '2026-08-31 23:00:00+07'
  ),
  updated_at = NOW()
FROM campaigns cp
JOIN user_programs up ON up.id = cp.user_program_id
JOIN users u ON u.id = up.user_id
JOIN cashback_programs p ON p.id = up.program_id
WHERE ct.campaign_id = cp.id
  AND u.email = 'an@example.com'
  AND p.name = 'Cashback chi tieu 10 trieu hang thang'
  AND cp.period_key = '2026-08'
  AND ct.parent_task_id IS NULL;

-- ============================================================
-- 14. Demo custom subtasks and steps
-- ============================================================

-- Parent task: spend 4 million on shopping.
-- Subtask 1: user spends 1 million personally.
INSERT INTO campaign_tasks (
  campaign_id,
  parent_task_id,
  task_origin,
  task_code,
  name,
  description,
  condition_type,
  operator,
  target_value,
  current_value,
  unit,
  sort_order,
  status,
  started_at
)
SELECT
  parent.campaign_id,
  parent.id,
  'user_defined',
  'self_shopping',
  'Tu mua sam 1 trieu',
  'Phan chi tieu mua sam do user tu thuc hien.',
  'spend_amount',
  '>=',
  1000000,
  500000,
  'VND',
  1,
  'in_progress',
  TIMESTAMPTZ '2026-09-01 08:00:00+07'
FROM campaign_tasks parent
JOIN campaigns cp ON cp.id = parent.campaign_id
JOIN user_programs up ON up.id = cp.user_program_id
JOIN users u ON u.id = up.user_id
JOIN cashback_programs p ON p.id = up.program_id
WHERE parent.parent_task_id IS NULL
  AND parent.task_code = 'shopping_spend'
  AND cp.period_key = '2026-09'
  AND u.email = 'an@example.com'
  AND p.name = 'Cashback chi tieu 10 trieu hang thang'
ON CONFLICT DO NOTHING;

-- Subtask 2: ask friends to spend 3 million.
-- Steps for this subtask are stored in campaign_task_steps below.
INSERT INTO campaign_tasks (
  campaign_id,
  parent_task_id,
  task_origin,
  task_code,
  name,
  description,
  condition_type,
  operator,
  target_value,
  current_value,
  unit,
  sort_order,
  status,
  started_at
)
SELECT
  parent.campaign_id,
  parent.id,
  'user_defined',
  'friend_shopping',
  'Nho ban be mua sam 3 trieu',
  'Phan chi tieu mua sam duoc thuc hien nho ban be.',
  'spend_amount',
  '>=',
  3000000,
  1000000,
  'VND',
  2,
  'in_progress',
  TIMESTAMPTZ '2026-09-02 09:00:00+07'
FROM campaign_tasks parent
JOIN campaigns cp ON cp.id = parent.campaign_id
JOIN user_programs up ON up.id = cp.user_program_id
JOIN users u ON u.id = up.user_id
JOIN cashback_programs p ON p.id = up.program_id
WHERE parent.parent_task_id IS NULL
  AND parent.task_code = 'shopping_spend'
  AND cp.period_key = '2026-09'
  AND u.email = 'an@example.com'
  AND p.name = 'Cashback chi tieu 10 trieu hang thang'
ON CONFLICT DO NOTHING;

-- A root task can also have its own steps. These are not subtasks and do not
-- change the amount of the parent task; they are the user's checklist for
-- completing that condition.
INSERT INTO campaign_task_steps (
  campaign_task_id,
  step_code,
  name,
  description,
  is_required,
  sort_order,
  status,
  started_at,
  completed_at
)
SELECT
  ct.id,
  v.step_code,
  v.name,
  v.description,
  TRUE,
  v.sort_order,
  v.status,
  v.started_at,
  v.completed_at
FROM campaign_tasks ct
JOIN campaigns cp ON cp.id = ct.campaign_id
JOIN user_programs up ON up.id = cp.user_program_id
JOIN users u ON u.id = up.user_id
JOIN cashback_programs p ON p.id = up.program_id
CROSS JOIN (
  VALUES
    (
      'plan_budget',
      'Lap ke hoach chi tieu',
      'Chia muc tieu 4 trieu thanh cac phan chi tieu phu.',
      1::SMALLINT,
      'completed',
      TIMESTAMPTZ '2026-09-01 08:00:00+07',
      TIMESTAMPTZ '2026-09-01 08:30:00+07'
    ),
    (
      'track_transactions',
      'Theo doi giao dich mua sam',
      'Cap nhat so tien mua sam sau moi giao dich.',
      2::SMALLINT,
      'in_progress',
      TIMESTAMPTZ '2026-09-01 08:30:00+07',
      NULL::TIMESTAMPTZ
    ),
    (
      'review_statement',
      'Kiem tra sao ke',
      'Doi chieu giao dich vao cuoi ky.',
      3::SMALLINT,
      'pending',
      NULL::TIMESTAMPTZ,
      NULL::TIMESTAMPTZ
    )
) AS v(
  step_code,
  name,
  description,
  sort_order,
  status,
  started_at,
  completed_at
)
WHERE ct.parent_task_id IS NULL
  AND ct.task_code = 'shopping_spend'
  AND cp.period_key = '2026-09'
  AND u.email = 'an@example.com'
  AND p.name = 'Cashback chi tieu 10 trieu hang thang'
ON CONFLICT (campaign_task_id, step_code) DO NOTHING;

-- Steps for the nested subtask: "ask friend" and "wait for repayment".
INSERT INTO campaign_task_steps (
  campaign_task_id,
  step_code,
  name,
  description,
  is_required,
  sort_order,
  status,
  started_at,
  completed_at
)
SELECT
  ct.id,
  v.step_code,
  v.name,
  v.description,
  TRUE,
  v.sort_order,
  v.status,
  v.started_at,
  v.completed_at
FROM campaign_tasks ct
JOIN campaign_tasks parent ON parent.id = ct.parent_task_id
JOIN campaigns cp ON cp.id = ct.campaign_id
JOIN user_programs up ON up.id = cp.user_program_id
JOIN users u ON u.id = up.user_id
JOIN cashback_programs p ON p.id = up.program_id
CROSS JOIN (
  VALUES
    (
      'ask_friend',
      'Nho ban be mua ho',
      'Gui yeu cau va thong nhat khoan chi tieu voi ban be.',
      1::SMALLINT,
      'completed',
      TIMESTAMPTZ '2026-09-02 09:00:00+07',
      TIMESTAMPTZ '2026-09-02 09:30:00+07'
    ),
    (
      'wait_friend_repayment',
      'Doi ban be back tien',
      'Cho ban be chuyen lai tien sau khi giao dich thanh cong.',
      2::SMALLINT,
      'pending',
      TIMESTAMPTZ '2026-09-02 09:30:00+07',
      NULL::TIMESTAMPTZ
    )
) AS v(
  step_code,
  name,
  description,
  sort_order,
  status,
  started_at,
  completed_at
)
WHERE ct.task_code = 'friend_shopping'
  AND parent.task_code = 'shopping_spend'
  AND cp.period_key = '2026-09'
  AND u.email = 'an@example.com'
  AND p.name = 'Cashback chi tieu 10 trieu hang thang'
ON CONFLICT (campaign_task_id, step_code) DO NOTHING;

-- ============================================================
-- 15. Quick verification
-- ============================================================

-- Recursive query showing root tasks and all nested subtasks.
WITH RECURSIVE task_tree AS (
  SELECT
    ct.id,
    ct.campaign_id,
    ct.parent_task_id,
    ct.name,
    ct.task_origin,
    ct.target_value,
    ct.current_value,
    ct.unit,
    ct.status,
    ct.sort_order,
    0 AS depth,
    LPAD(ct.sort_order::TEXT, 4, '0') AS sort_path
  FROM campaign_tasks ct
  WHERE ct.parent_task_id IS NULL

  UNION ALL

  SELECT
    child.id,
    child.campaign_id,
    child.parent_task_id,
    child.name,
    child.task_origin,
    child.target_value,
    child.current_value,
    child.unit,
    child.status,
    child.sort_order,
    parent.depth + 1,
    parent.sort_path || '.' || LPAD(child.sort_order::TEXT, 4, '0')
  FROM campaign_tasks child
  JOIN task_tree parent
    ON parent.id = child.parent_task_id
   AND parent.campaign_id = child.campaign_id
)
SELECT
  u.name AS user_name,
  p.name AS program_name,
  cp.period_key,
  cp.status AS campaign_status,
  REPEAT('  ', tt.depth) || tt.name AS task_name,
  tt.task_origin,
  tt.target_value,
  tt.current_value,
  tt.unit,
  tt.status AS task_status,
  (
    SELECT COALESCE(
      JSONB_AGG(
        JSONB_BUILD_OBJECT(
          'code', cts.step_code,
          'name', cts.name,
          'status', cts.status,
          'sort_order', cts.sort_order,
          'completed_at', cts.completed_at
        )
        ORDER BY cts.sort_order
      ),
      '[]'::JSONB
    )
    FROM campaign_task_steps cts
    WHERE cts.campaign_task_id = tt.id
  ) AS steps
FROM task_tree tt
JOIN campaigns cp ON cp.id = tt.campaign_id
JOIN user_programs up ON up.id = cp.user_program_id
JOIN users u ON u.id = up.user_id
JOIN cashback_programs p ON p.id = up.program_id
ORDER BY u.name, p.name, cp.starts_on, tt.sort_path;

COMMIT;
