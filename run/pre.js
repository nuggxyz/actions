require("child_process").execSync(process.env.INPUT_BEFORE || 'echo ""', {
	stdio: "inherit",
});
