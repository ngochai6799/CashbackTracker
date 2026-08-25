require("dotenv").config();

const express = require("express");
const cors = require("cors");
const pool = require("./db");

const authRoutes = require("./routes/auth.routes");

const app = express();
const PORT = process.env.PORT;
const allowedOrigins = (process.env.FRONTEND_URL)
  .split(",")
  .map((origin) => origin.trim())
  .filter(Boolean);

app.use(
  cors({
    origin(origin, callback) {
      // Cho phép các request không có Origin như curl hoặc health check.
      if (!origin || allowedOrigins.includes(origin)) {
        callback(null, true);
        return;
      }

      callback(new Error(`CORS blocked for origin: ${origin}`));
    },
    credentials: true,
  }),
);

app.use(express.json());
app.use("/api/auth", authRoutes);

async function startServer() {
  try {
    await pool.query("SELECT 1");

    console.log("Đã kết nối Neon PostgreSQL");

    app.listen(PORT, () => {
      console.log(`Server chạy tại http://localhost:${PORT}`);
    });
  } catch (error) {
    console.error(
      "Kết nối database thất bại:",
      error.code || "UNKNOWN_ERROR",
      error.message || "Không có thông tin lỗi.",
    );
    process.exit(1);
  }
}

if (require.main === module) {
  startServer();
}

module.exports = app;
