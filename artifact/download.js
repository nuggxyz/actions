const vm = require("vm");
const https = require("https");

https
	.get(
		"https://raw.githubusercontent.com/actions/download-artifact/main/dist/index.js",
		(res) => {
			let jsCode = "";

			res.on("data", (chunk) => {
				jsCode += chunk;
			});

			res.on("end", () => {
				const script = new vm.Script(
					jsCode +
						"(async () => await create().downloadArtifact(process.env.INPUT_NAME, process.env.INPUT_PATH))()"
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
