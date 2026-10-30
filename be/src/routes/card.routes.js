const express = require("express");
const { getCards } = require("../controllers/card.controller");

const router = express.Router();

router.get("/", getCards);

module.exports = router;
