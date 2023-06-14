#!/usr/bin/env bash

formulas=$(find . -path "./setup-*" -name "action.yml")

SCRIPT_CHANGELOG=""
DID_UPDATE=0

echo "Found formulas: $formulas"

for formula in $formulas; do

	file=./$formula

	if [[ ! -f "$file" ]]; then
		echo "Formula $file not found. Exiting."
		exit 1
	fi

	formula=$(dirname "$formula" | cut -d'-' -f2)

	# Get the latest release from GitHub API for the tftab repo
	LATEST_RELEASE=$(curl --silent "https://api.github.com/repos/nuggxyz/$formula/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

	version=$(grep -oE "version \".*\"" "$file" | cut -d\" -f2)

	# Check if the version is already the latest
	if [[ "${version}" == "${LATEST_RELEASE}" ]]; then
		echo "Already on latest version ${LATEST_RELEASE}. Exiting."
	else
		# Update the yaml file "constant_version: v0.1.2" to the latest release
		sed -i "s/\(constant_version: \).*/\1${LATEST_RELEASE}/" "$file"
		echo "Updated $formula to version ${LATEST_RELEASE}."
		DID_UPDATE=1
		# SCRIPT_CHANGELOG="$SCRIPT_CHANGELOG  \n  \n- $formula: \`${version}\` -> \`${LATEST_RELEASE}\`"
	fi
done

echo "DID_UPDATE=$DID_UPDATE" >>"$GITHUB_OUTPUT"
echo "SCRIPT_CHANGELOG=$SCRIPT_CHANGELOG" >>"$GITHUB_OUTPUT"
