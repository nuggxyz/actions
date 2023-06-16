require("child_process").execSync(process.env.INPUT_AFTER || 'echo ""', {
	stdio: "inherit",
});
