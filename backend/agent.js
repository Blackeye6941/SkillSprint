const model = require("./model.js");
const { Type } = require("@google/genai");
const { formSchema } = require("./utils/formSchema.js");
const { webSearch } = require("./utils/webSearch.js");
const { tavily } = require("@tavily/core");
require("dotenv").config();


(async function generateRoadmap(){

	const tavily_client = tavily({api_key : process.env.TAVILY_API_KEY});
	
	/*const config1 = {
		tools: [{
			functionDeclarations: [webSearch]
		}],
	};*/

	const config = {
		tools: [{
			functionDeclarations: [webSearch]
		}],
		responseMimeType: "application/json",
		responseSchema: formSchema
	};


	const prompt = "Docker in 5 days with 1 hr per day"

	const contents = [{
    		role: 'user',
    		parts: [{ text: `You are an excellent roadmap generator. Provide the user a good roadmap according to the prompt provided by the user ${prompt}.Provide A 100-200 word explanation for him to understand the concepts for each day. You can also add task to be done each day on that project. You can also add weekly projects and instructions for the user to practically understand the topics covered each week or each 1/2th day of the course. IMPORTANT: use the search_resources tool for resource generation for each day according to the day's topic and append it to resouce field`}]
  	}];
	console.log("First Api request");
	const res = await model.models.generateContent({
		model:"gemini-3-flash-preview",
		contents: contents,
		config: config
	});

	console.log(res); 
	console.log("first Api req completed.. Web Search Initiated");
	const toolCalls = res.candidates[0].content.parts.filter(p => p.functionCall);
	let toolResponses = {};
	 if(toolCalls.length > 0){
		toolResponses = await Promise.all(toolCalls.map(async (call) => {
			const { name, args } = call.functionCall;
			console.log(`Executing ${name} tool with args ${args.query}`)
			const searchResult = await tavily_client.search(args.query);
			console.log(searchResult);
			return {
				name: name,
				response: { content : searchResult}
			};
		}));	
	 }
	 contents.push(res.candidates[0].content);
	 const responseParts = toolResponses.map(res => ({
    		functionResponse: {
        		name: res.name,
        		response: res.response
    	 	}
	 }));

	contents.push({ 
    		role: 'user', 
    		parts: responseParts 
	});
	 console.log("Websearch completed");	
	 console.log("Second gemini api req!");
	 const final_response = await model.models.generateContent({
		 model: 'gemini-3-flash-preview',
 		contents: contents,
 		config: config
	 });

	console.log(final_response.text);
	return res.text;
})();

//module.exports = {generateRoadmap};
