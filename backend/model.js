const {GoogleGenAI} = require("@google/genai");
require("dotenv").config();

const model = new GoogleGenAI({ apiKey : process.env.GEMINI_API_KEY});

module.exports = model;
