const express = require('express');
const {generateRoadmap} = require('./agent.js');
const app = express();
const PORT = 3000;

app.use(express.json());

app.get('/', (req, res) => {
	res.send("<h1>SkillSprint Backend</h1>");
});

app.post('/generate', (req, res) => {	
	const prompt = req.body;
	generateRoadmap(prompt);
});

app.listen(PORT, () => {
	console.log(`Server running on http://localhost:${PORT}`);
})
