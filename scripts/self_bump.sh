#!/usr/bin/env bash

# Check if the version is supplied
if [ -z "$1" ]; then
	echo "Error: No version supplied"
	exit 1
fi

latest=$1

# find any cases of "nuggxyz/actions/*@v*" and replace with "nuggxyz/actions/*@latest"
formulas=$(find . -path "./*/action.yml" -name "action.yml")

# Check if any action.yml files were found
if [ -z "$formulas" ]; then
	echo "Error: No action.yml files were found"
	exit 1
fi

echo "Found formulas: $formulas"

for formula in $formulas; do
	found=$(grep -oE "nuggxyz/actions/.*@v[0-9]+" "$formula")

	# Check if any matches were found
	if [ -z "$found" ]; then
		echo "Warning: No matches found in $formula"
	else
		for f in $found; do
			echo "Found $f"
			sed -i "" "s/$f/nuggxyz/actions@${latest}/" "$formula"
		done
	fi
done
