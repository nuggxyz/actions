(async () => await require('@actions/artifact').create().uploadArtifact(process.env.INPUT_NAME, require('fs').readdirSync(process.env.INPUT_PATH), ".", false))();
