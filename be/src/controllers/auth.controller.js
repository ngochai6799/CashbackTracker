const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const pool = require("../db");

const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const PASSWORD_SALT_ROUNDS = 12;
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || "1d";

function getJwtSecret() {
  if (!process.env.JWT_SECRET) {
    throw new Error("JWT_SECRET chưa được cấu hình.");
  }

  return process.env.JWT_SECRET;
}

function toPublicUser(user) {
  return {
    id: user.id,
    name: user.name,
    email: user.email,
    isActive: user.is_active,
    emailVerified: Boolean(user.email_verified_at),
    createdAt: user.created_at,
  };
}

async function register(req, res) {
  const { name, email, password, confirmPassword } = req.body || {};
  const normalizedName = typeof name === "string" ? name.trim() : "";
  const normalizedEmail = typeof email === "string" ? email.trim().toLowerCase() : "";
  const errors = {};

  if (normalizedName.length < 2 || normalizedName.length > 100) {
    errors.name = "Họ và tên cần có từ 2 đến 100 ký tự.";
  }

  if (!EMAIL_PATTERN.test(normalizedEmail) || normalizedEmail.length > 255) {
    errors.email = "Email không hợp lệ.";
  }

  if (typeof password !== "string" || password.length < 6) {
    errors.password = "Mật khẩu cần ít nhất 6 ký tự.";
  }

  if (password !== confirmPassword) {
    errors.confirmPassword = "Mật khẩu xác nhận chưa khớp.";
  }

  if (Object.keys(errors).length > 0) {
    return res.status(400).json({
      message: "Dữ liệu đăng ký không hợp lệ.",
      data: { errors },
    });
  }

  try {
    const existingUser = await pool.query(
      "SELECT id FROM users WHERE LOWER(email) = LOWER($1) LIMIT 1",
      [normalizedEmail],
    );

    if (existingUser.rowCount > 0) {
      return res.status(409).json({
        message: "Email đã được đăng ký.",
        data: null,
      });
    }

    const passwordHash = await bcrypt.hash(password, PASSWORD_SALT_ROUNDS);
    const result = await pool.query(
      `
        INSERT INTO users (name, email, password_hash)
        VALUES ($1, $2, $3)
        RETURNING id, name, email, is_active, email_verified_at, created_at
      `,
      [normalizedName, normalizedEmail, passwordHash],
    );

    return res.status(201).json({
      message: "Đăng ký tài khoản thành công.",
      data: {
        user: toPublicUser(result.rows[0]),
      },
    });
  } catch (error) {
    if (error.code === "23505") {
      return res.status(409).json({
        message: "Email đã được đăng ký.",
        data: null,
      });
    }

    console.error("Đăng ký tài khoản thất bại:", error);

    return res.status(500).json({
      message: "Không thể đăng ký tài khoản lúc này. Vui lòng thử lại sau.",
      data: null,
    });
  }
}

async function login(req, res) {
  const { email, password } = req.body || {};
  const normalizedEmail = typeof email === "string" ? email.trim().toLowerCase() : "";

  if (!EMAIL_PATTERN.test(normalizedEmail)) {
    return res.status(400).json({
      message: "Email không hợp lệ.",
      data: null,
    });
  }

  if (typeof password !== "string" || !password) {
    return res.status(400).json({
      message: "Mật khẩu không hợp lệ.",
      data: null,
    });
  }

  try {
    const result = await pool.query(
      `
        SELECT id, name, email, password_hash, is_active, email_verified_at, created_at
        FROM users
        WHERE LOWER(email) = LOWER($1)
        LIMIT 1
      `,
      [normalizedEmail],
    );

    const user = result.rows[0];

    if (!user || !user.password_hash) {
      return res.status(401).json({
        message: "Email hoặc mật khẩu không đúng.",
        data: null,
      });
    }

    if (!user.is_active) {
      return res.status(403).json({
        message: "Tài khoản đã bị vô hiệu hóa.",
        data: null,
      });
    }

    const isPasswordCorrect = await bcrypt.compare(password, user.password_hash);

    if (!isPasswordCorrect) {
      return res.status(401).json({
        message: "Email hoặc mật khẩu không đúng.",
        data: null,
      });
    }

    const accessToken = jwt.sign(
      {
        sub: user.id,
        email: user.email,
      },
      getJwtSecret(),
      { expiresIn: JWT_EXPIRES_IN },
    );

    return res.status(200).json({
      message: "Đăng nhập thành công.",
      data: {
        accessToken,
        tokenType: "Bearer",
        expiresIn: JWT_EXPIRES_IN,
        user: toPublicUser(user),
      },
    });
  } catch (error) {
    console.error("Đăng nhập thất bại:", error);

    return res.status(500).json({
      message: "Không thể đăng nhập lúc này. Vui lòng thử lại sau.",
      data: null,
    });
  }
}

module.exports = {
  register,
  login,
};
