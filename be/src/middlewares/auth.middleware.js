const jwt = require("jsonwebtoken");

function authMiddleware(req, res, next) {
  const authorization = req.headers.authorization;
  const tokenMatch = authorization?.match(/^Bearer\s+(.+)$/i);

  if (!tokenMatch) {
    return res.status(401).json({
      message: "Yêu cầu này cần đăng nhập.",
      data: null,
    });
  }

  if (!process.env.JWT_SECRET) {
    console.error("JWT_SECRET chưa được cấu hình.");

    return res.status(500).json({
      message: "Máy chủ chưa được cấu hình xác thực.",
      data: null,
    });
  }

  try {
    const payload = jwt.verify(tokenMatch[1], process.env.JWT_SECRET);

    if (typeof payload !== "object" || payload === null || !payload.sub) {
      throw new Error("JWT payload không hợp lệ.");
    }

    const userId = Number(payload.sub);

    if (!Number.isInteger(userId) || userId <= 0) {
      throw new Error("JWT user id không hợp lệ.");
    }

    req.user = {
      id: userId,
      email: typeof payload.email === "string" ? payload.email : null,
    };

    return next();
  } catch (error) {
    return res.status(401).json({
      message: "Token không hợp lệ hoặc đã hết hạn.",
      data: null,
    });
  }
}

module.exports = authMiddleware;
