require("dotenv").config();

const express = require("express");
const cors = require("cors");
const pool = require("./db");

const authRoutes = require("./routes/auth.routes");
const cardRoutes = require("./routes/card.routes");
const authMiddleware = require("./middlewares/auth.middleware");

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

// Các API được khai báo sau dòng này sẽ yêu cầu access token.
app.use("/api", authMiddleware);
app.use("/api/cards", cardRoutes);

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
