#!/usr/bin/env bash

current_version="$1"
filename_prefix="$2"
input_version="$3"
draft_release_tag="$4"

is_raw="0"
check_version="1"

# If a version number is given, use it as current version
if [ -n "$input_version" ]; then
	current_version="$input_version"

	# If the version number doesn't match the pattern vX.Y.Z, assume it's raw
	if ! echo "$current_version" | grep -qE "^v[0-9]+\.[0-9]+\.[0-9]+$"; then
		is_raw="1"
	fi
fi

# If an input version isn't provided and a buildrc-override file exists, use it
if [ -z "$input_version" ] && [ -f "$BUILDRC_EXEC_OVERRIDE" ]; then
	echo "Override artifact found - using in place of $current_version 🔶"
	mkdir -p temp
	check_version="0"
	cp "$BUILDRC_EXEC_OVERRIDE" "$BUILDRC_PATH_DIR/buildrc"
else
	# Mapping environment variables to usable variables
	declare -A arch_map=(["X64"]="amd64" ["arm"]="armv7" ["arm64"]="arm64")
	declare -A os_map=(["Linux"]="linux" ["MacOS"]="darwin" ["Darwin"]="darwin" ["Windows"]="windows")

	arch=${arch_map["$RUNNER_ARCH"]}
	os=${os_map["$RUNNER_OS"]}

	# Check if the architecture and OS are supported
	[[ -z "$arch" ]] && echo "Unsupported architecture" && exit 1
	[[ -z "$os" ]] && echo "Unsupported OS" && exit 1

	# If draft_release_tag is an empty string, use current_version
	if [ -z "$draft_release_tag" ]; then
		tag_to_check="$current_version"
	else
		# If draft_release_tag is not empty, use draft_release_tag
		tag_to_check="$draft_release_tag"
	fi

	# If an override artifact isn't found, download the necessary files
	artifact_name="$filename_prefix$os-$arch.tar.gz"
	echo "Override artifact not found. Downloading from GitHub release [tag:$tag_to_check] [artifact:$artifact_name] [version:$current_version] 🔷"
	gh release download "$tag_to_check" -p "$artifact_name" --repo nuggxyz/buildrc --dir "$RUNNER_TEMP" --clobber || exit 1
	tar -xzf "$RUNNER_TEMP/$artifact_name" -C "$RUNNER_TEMP" || exit 1
	cp "$RUNNER_TEMP/$filename_prefix$os-$arch" "$BUILDRC_PATH_DIR/buildrc"
fi

echo "Running buildrc load ▶️"
chmod +x "$BUILDRC_PATH_DIR/buildrc"
"$BUILDRC_PATH_DIR/buildrc" load || exit 1
echo "buildrc load successful ✅"

if [ "$check_version" == "1" ]; then
	echo "Checking buildrc version 🔄"

	if [ "$is_raw" == "1" ]; then
		echo "Checking raw version"
		actual_version=$("$BUILDRC_PATH_DIR/buildrc" version --raw --quiet)
	else
		echo "Checking semver version"
		actual_version=$("$BUILDRC_PATH_DIR/buildrc" version --quiet)
	fi

	# strip the v from the version number
	want=${current_version#"v"}

	# If the actual version doesn't match the expected version, throw an error
	if [ "$actual_version" != "$want" ]; then
		echo "buildrc version mismatch - wanted $want but got $actual_version"
		exit 1
	fi

	echo "buildrc version check successful ✅ - $actual_version"
fi
echo "Checking buildrc version 🔄"
