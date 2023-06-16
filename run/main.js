require("child_process").execSync(process.env.INPUT_NOW || 'echo ""', {
	stdio: "inherit",
});
