(async () => await require('@actions/artifact').create().downloadArtifact(process.env.INPUT_NAME, process.env.INPUT_PATH))();
