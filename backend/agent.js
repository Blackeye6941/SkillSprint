const model = require("./model.js");

(async function main(){
	const res = await model.models.generateContent({
		model:"gemini-2.5-flash",
		contents:"Explain ai"
	});
	console.log(res.text);
}
)();
