require("dotenv").config();

const express = require("express");
const pool = require("./db");

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

async function startServer() {
  try {
    await pool.query("SELECT 1");

    console.log("Đã kết nối Neon PostgreSQL");

    app.listen(PORT, () => {
      console.log(`Server chạy tại http://localhost:${PORT}`);
    });
  } catch (error) {
    console.error("Kết nối database thất bại:", error.message);
    process.exit(1);
  }
}

startServer();