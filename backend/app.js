const express = require('express');
const {generateRoadmap} = require('./agent.js');
const app = express();
const PORT = 3000;

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get('/', (req, res) => {
	res.send("<h1>SkillSprint Backend</h1>");
});

app.post('/generate', async(req, res) => {	
	const prompt = req.body.query;
	//res.json(prompt);
	try {
		const result = await generateRoadmap({prompt});
		if(result){
			res.json({"message": "Check the roadmap list"});
		}
	} catch (error) {
		res.console.error(error);
		
	}
});

app.listen(PORT, () => {
	console.log(`Server running on http://localhost:${PORT}`);
})
