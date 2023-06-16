const https = require("https");
const vm = require("vm");
const url =
	"https://raw.githubusercontent.com/actions/download-artifact/main/dist/index.js";

https
	.get(url, (res) => {
		let script = "";

		res.on("data", (chunk) => {
			script += chunk;
		});

		res.on("end", () => {
			try {
				script +=
					"(async () => await create().downloadArtifact(process.env.INPUT_NAME, process.env.INPUT_PATH))()";
				vm.runInThisContext(script);
			} catch (err) {
				console.error("Failed to execute script.", err);
			}
		});
	})
	.on("error", (err) => {
		console.error(`Error fetching script: ${err.message}`);
	});
