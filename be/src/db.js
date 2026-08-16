const { Pool } = require("pg");

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 5,
  connectionTimeoutMillis: 10000,
  enableChannelBinding: true
});

pool.on("error", (error) => {
  console.error("Unexpected database error:", error);
});

module.exports = pool;