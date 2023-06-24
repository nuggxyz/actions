#!/usr/bin/env bash

# Check if the version is supplied
if [ -z "$1" ]; then
	echo "Error: No version supplied"
	exit 1
fi

latest=$1

# find any cases of "nuggxyz/actions/*@v*" and replace with "nuggxyz/actions/*@latest"
formulas=$(find . \( -path "./*/action.yml" -o -path "./.github/workflows/*.yaml" \) -name "*.y*ml")

# Check if any action.yml files were found
if [ -z "$formulas" ]; then
	echo "Error: No action.yml files were found"
	exit 1
fi

echo "Found formulas: $formulas"

for formula in $formulas; do

	found=$(grep -oE "nuggxyz/actions/.*@v[0-9\.]+" "$formula")

	for f in $found; do
		echo "Found $f"
		action_name=$(echo $f | grep -oE "nuggxyz/actions/[a-zA-Z_-]+")
		if [[ "$OSTYPE" == "linux-gnu"* ]]; then
			# Linux
			sed -i "s#${f}#${action_name}@${latest}#" "$formula"
		elif [[ "$OSTYPE" == "darwin"* ]]; then
			# Mac OSX
			sed -i "" "s#${f}#${action_name}@${latest}#" "$formula"
		fi
	done
done
