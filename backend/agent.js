const model = require("./model.js");
const { formSchema } = require("./utils/formSchema.js");

async function generateRoadmap({prompt}){
	const res = await model.models.generateContent({
		model:"gemini-2.5-flash",
		contents:`You are an excellent roadmap generator. Provide the user a good roadmap according to the prompt provided here ${prompt}. You must provide the resources for each day and a 100-200 word description for him to understand the concepts. You can also add task to be done each day on that project. provide a unique integer id for each roadmap. You can also add weekly projects and instructions for the user to practically understand the topics covered each week or each 1/2th day of the course. Provide direct links to youtube and official docs for each day. Links or urls needed`,
		config: {
			responseMimeType: "application/json",
			responseSchema: formSchema
		}
	});
	console.log(res.text);
};

module.exports = {generateRoadmap};
