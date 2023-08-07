#!/usr/bin/env bash

# this handles the setup actions, but we could handle others too with different logic

setups=$(find . -path "./setup-*" -name "action.yml")

SCRIPT_CHANGELOG=""

echo "Found setups: $setups"

COMMIT_MESSAGE=""

for setup in $setups; do

	file=./$setup

	if [[ ! -f "$file" ]]; then
		echo "Formula $file not found. Exiting."
		exit 1
	fi

	setup=$(dirname "$setup" | cut -d'-' -f2)

	# Get the latest release from GitHub API for the tftab repo
	LATEST_RELEASE=$(curl --silent "https://api.github.com/repos/walteh/$setup/releases/latest" | jq -r '.tag_name')

	version=$(grep -oE "auto_version: .*" "$file" | cut -d' ' -f2)

	# Check if the version is already the latest
	if [[ "${version}" == "${LATEST_RELEASE}" ]]; then
		echo "Already on latest version ${LATEST_RELEASE}. Exiting."
	else
		# Update the yaml file "auto_version: v0.1.2" to the latest release
		sed -i "s/\(auto_version: \).*/\1${LATEST_RELEASE}/" "$file"
		echo "Updated $setup to version ${LATEST_RELEASE}."
		if [ -z "$COMMIT_MESSAGE" ]; then
			COMMIT_MESSAGE="$setup to ${LATEST_RELEASE}"
		else
			COMMIT_MESSAGE="$COMMIT_MESSAGE, $setup to ${LATEST_RELEASE}"
		fi
	fi
done

{
	echo "COMMIT_MESSAGE=$COMMIT_MESSAGE"
	echo "DID_UPDATE=$DID_UPDATE"
	echo "SCRIPT_CHANGELOG=$SCRIPT_CHANGELOG"
} >>"$GITHUB_OUTPUT"
