const vm = require("vm");
const https = require("https");

https
	.get(
		"https://raw.githubusercontent.com/actions/upload-artifact/main/dist/index.js",
		(res) => {
			let jsCode = "";

			res.on("data", (chunk) => {
				jsCode += chunk;
			});

			res.on("end", () => {
				const script = new vm.Script(
					jsCode +
						`(async () => await create().uploadArtifact(process.env.INPUT_NAME, require('fs').readdirSync(process.env.INPUT_PATH), '.', false))()`
				);

				const sandbox = {
					console: console,
					__dirname: __dirname,
					require: require, // passing require to the context
				};

				const context = new vm.createContext(sandbox);
				script.runInNewContext(context);
			});
		}
	)
	.on("error", (err) => {
		console.error("Error fetching the file: " + err.message);
	});
