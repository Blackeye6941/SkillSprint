const { Type } = require("@google/genai")

const webSearch = {
	name:"search_resources",
	description: "Find the relevant documentations and youtube tutorias for the provided technical topic",
	parameters: {
		type: Type.OBJECT,
		properties: {
			query: { type: Type.STRING, description: "Search query (eg: react hooks docs, ssr nextjs youtube videos)"}
		},
		required: ['query']
	}
};

module.export = webSearch;


