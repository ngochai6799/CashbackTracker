const pool = require("../db");

function toCardResponse(card) {
  return {
    id: card.id,
    issuer: card.issuer,
    cardName: card.card_name,
    lastFour: card.last_four,
    annualFee: Number(card.annual_fee),
    currency: card.currency,
    isActive: card.is_active,
    createdAt: card.created_at,
  };
}

async function getCards(req, res) {
  try {
    const result = await pool.query(
      `
        SELECT id, issuer, card_name, last_four, annual_fee, currency, is_active, created_at
        FROM cards
        WHERE user_id = $1
        ORDER BY created_at DESC, id DESC
      `,
      [req.user.id],
    );

    return res.status(200).json({
      message: "Lấy danh sách thẻ thành công.",
      data: {
        cards: result.rows.map(toCardResponse),
      },
    });
  } catch (error) {
    console.error("Lấy danh sách thẻ thất bại:", error);

    return res.status(500).json({
      message: "Không thể lấy danh sách thẻ lúc này. Vui lòng thử lại sau.",
      data: null,
    });
  }
}

module.exports = {
  getCards,
};
