const model = require("./model.js");
const { Type } = require("@google/genai");
const { formSchema } = require("./utils/formSchema.js");
const { webSearch } = require("./utils/webSearch.js");
const { tavily } = require("@tavily/core");
require("dotenv").config();


async function generateRoadmap({ prompt }) {
	const tavily_client = tavily({ api_key: process.env.TAVILY_API_KEY });

	const config = {
		tools: [{
			functionDeclarations: [webSearch]
		}],
		responseMimeType: "application/json",
		responseSchema: formSchema
	};

	const contents = [{
		role: 'user',
		parts: [{ text: `You are an excellent roadmap generator. Provide the user a good roadmap according to the prompt provided by the user: ${prompt}. Provide A 100-200 word explanation for him to understand the concepts for each day. You can also add tasks to be done each day on that project. You can also add weekly projects and instructions for the user to practically understand the topics covered each week or each 1/2th day of the course. IMPORTANT: use the search_resources tool for resource generation for each day according to the day's topic and append it to resource field.` }]
	}];

	console.log("First Gemini API request initiated...");
	const res = await model.models.generateContent({
		model: "gemini-3-flash-preview",
		contents: contents,
		config: config
	});

	console.log("First Gemini API request completed.");
	const candidateContent = res.candidates?.[0]?.content;
	const parts = candidateContent?.parts || [];
	const toolCalls = parts.filter(p => p.functionCall);

	if (toolCalls.length > 0) {
		console.log("Web Search Tool Calls detected. Initiating search...");
		const toolResponses = await Promise.all(toolCalls.map(async (call) => {
			const { name, args } = call.functionCall;
			console.log(`Executing ${name} tool with query: "${args.query}"`);
			const searchResult = await tavily_client.search(args.query);
			return {
				name: name,
				response: { content: searchResult }
			};
		}));

		contents.push(candidateContent);
		const responseParts = toolResponses.map(tRes => ({
			functionResponse: {
				name: tRes.name,
				response: tRes.response
			}
		}));

		contents.push({
			role: 'user',
			parts: responseParts
		});

		console.log("Tool execution completed. Second Gemini API request initiated...");
		const final_response = await model.models.generateContent({
			model: 'gemini-3-flash-preview',
			contents: contents,
			config: config
		});

		console.log("Second Gemini API request completed.");
		return final_response.text;
	}

	return res.text;
}

module.exports = { generateRoadmap };

