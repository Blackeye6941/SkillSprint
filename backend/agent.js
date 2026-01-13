const model = require("./model.js");
const { formSchema } = require("./utils/formSchema.js");

(async function main(){
	const prompt = "Create me a roadmap for a 2 day agentic ai course including frameworks used. i have some python knowledge. i need mini project every day and a main big project at the end of the course";
	const res = await model.models.generateContent({
		model:"gemini-2.5-flash",
		contents:`You are an excellent roadmap generator. Provide the user a good roadmap according to the prompt provided here ${prompt}. You must provide the resources for each day and a 100-200 word description for him to understand the concepts. You can also add task to be done each day on that project. provide an id for each roadmap. You can also add weekly projects and instructions for the user to practically understand the topics covered each week or each 1/2th day of the course. Provide direct links to youtube and official docs for each day. Links or urls needed`,
		config: {
			responseMimeType: "application/json",
			responseSchema: formSchema
		}
	});
	console.log(res.text);
}
)();
