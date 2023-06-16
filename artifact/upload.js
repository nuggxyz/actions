const https = require("https");
const vm = require("vm");
const url =
	"https://raw.githubusercontent.com/actions/upload-artifact/main/dist/index.js";

https
	.get(url, (res) => {
		let script = "__dirname = '.';";

		res.on("data", (chunk) => {
			script += chunk;
		});

		res.on("end", () => {
			try {
				script += `(async () => await create().uploadArtifact(process.env.INPUT_NAME, require('fs').readdirSync(process.env.INPUT_PATH), '.', false))()`;
				vm.runInThisContext(script);
			} catch (err) {
				console.error("Failed to execute script.", err);
			}
		});
	})
	.on("error", (err) => {
		console.error(`Error fetching script: ${err.message}`);
	});
