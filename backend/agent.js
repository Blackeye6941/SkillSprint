const model = require("./model.js");
const { formSchema } = require("./utils/formSchema.js");
const { webSearch } = require("./utils/webSearch.js");
const { tavily } = require("@tavily/core");
require("dotenv").config();


(async function generateRoadmap(){

	const tavily_client = tavily({api_key : process.env.TAVILY_API_KEY});
	
	const config1 = {
		tools: [{
			functionDeclarations: webSearch
		}],
	};

	const config2 = {
		tools: [{
			functionDeclarations: webSearch
		}],
		responseMimeType: "application/json",
		responseSchema: formSchema
	};

	const prompt = "Docker in 10 days with 1 hr per day"

	const contents = [{
    		role: 'user',
    		parts: [{ text: `You are an excellent roadmap generator. Provide the user a good roadmap according to the prompt provided by the user ${prompt}. A 100-200 word explanation for him to understand the concepts. You can also add task to be done each day on that project. You can also add weekly projects and instructions for the user to practically understand the topics covered each week or each 1/2th day of the course. Resouce field should be filled using the search_resources function call by providing relevant query for daily content`}]
  	}];
	console.log("First Api request");
	const res = await model.models.generateContent({
		model:"gemini-3-flash-preview",
		contents: contents,
		config: config1
	});

	console.log(res.candidates[0].content.parts); 
	console.log("first Api req completed.. Web Search Initiated");
	const toolCalls = res.candidates[0].content.parts.filter(p => p.functionCall);
	const toolResponses = {};
	 if(toolCalls.length > 0){
		toolResponses = await Promise.all(toolCalls.map(async (call) => {
			const { name, args } = call.functionCall;
			console.log(`Executing ${name} tool with args ${args}`)
			const searchResult = tavily_client.search(args);
			return {
				name: name,
				response: { content : searchResult}
			};
		}));	
	 }
	 contents.push(res.candidates[0].content);
	 contents.push({ role: 'user', parts: [{ functionResponse: toolResponses }] });
	 console.log("Websearch completed");	
	 console.log("Second gemini api req!");
	 const final_response = await model.models.generateContent({
		 model: 'gemini-3-flash-preview',
 		contents: contents,
 		config: config2
	 });

	console.log(final_response.text);
	return res.text;
})();

//module.exports = {generateRoadmap};
