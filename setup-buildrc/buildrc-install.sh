#!/usr/bin/env bash

auto_version="$1"
file_name_prefix="$2"
INPUT_VERSION="$3"
prerelease_id="$4"

check_raw="0"
check_version="1"
# Step 1: Check for buildrc-override
if [ -n "$INPUT_VERSION" ]; then
	auto_version="$INPUT_VERSION"
	# if the version is not in the format v0.1.2, then we assume it is a raw version
	if ! echo "$auto_version" | grep -qE "^v[0-9]+\.[0-9]+\.[0-9]+$"; then
		check_raw="1"
	fi
fi
echo "Checking for buildrc-override... at $BUILDRC_EXEC_OVERRIDE"
if [ -z "$INPUT_VERSION" ] && [ -f "$BUILDRC_EXEC_OVERRIDE" ]; then
	echo "override artifact found - using in place of $auto_version 🔶"
	mkdir -p temp
	check_version="0"
	cp "$BUILDRC_EXEC_OVERRIDE" "$BUILDRC_PATH_DIR/buildrc"
else
	case "$RUNNER_ARCH" in
	X64) arch="amd64" ;;
	arm) arch="armv7" ;;
	arm64) arch="arm64" ;;
	*) echo "Unsupported architecture" && exit 1 ;;
	esac
	case "$RUNNER_OS" in
	Linux) os="linux" ;;
	MacOS) os="darwin" ;;
	Darwin) os="darwin" ;;
	Windows) os="windows" ;;
	*) echo "Unsupported is" && exit 1 ;;
	esac
	smp_os_arch="$os-$arch"
	os_arch_pattern="$file_name_prefix$smp_os_arch.tar.gz"
	echo "override artifact not found. downloading from GitHub releases... $os_arch_pattern $auto_version 🔷"
	if [ -z "$prerelease_id" ]; then
		echo "release[$auto_version] found - downloading release artifact $os_arch_pattern"
		gh release download "$auto_version" -p "$os_arch_pattern" --repo nuggxyz/buildrc --dir "$wrk_dir" --clobber
	else
		echo "prerelease_id[$prerelease_id] found - downloading prerelease artifact $os_arch_pattern"
		gh release download "$prerelease_id" -p "$os_arch_pattern" --repo nuggxyz/buildrc --dir "$wrk_dir" --clobber
	fi
	wrk_dir="$RUNNER_TEMP/setup-buildrc-wrk"
	tar -xzf "$wrk_dir/$os_arch_pattern" -C "$wrk_dir"
	cp "$wrk_dir/$file_name_prefix$smp_os_arch" "$BUILDRC_PATH_DIR/buildrc"
fi

echo "running buildrc load ▶️"
chmod +x "$BUILDRC_PATH_DIR/buildrc"
"$BUILDRC_PATH_DIR/buildrc" load
echo "buildrc load successful ✅"

if [ "$check_version" == "1" ]; then
	echo "checking buildrc version 🔄"
	if [ "$check_raw" == "1" ]; then
		echo "checking raw version"
		got=$("$wrk_dir/$file_name_prefix$smp_os_arch" version --raw --quiet)
		want="$auto_version"
	else
		echo "checking semver version"
		got=$("$BUILDRC_PATH_DIR/buildrc" version --quiet)
		want="$auto_version"
	fi
	if [ "$got" != "$want" ]; then
		echo "buildrc version mismatch - wanted $want but got $got"
		exit 1
	fi
	echo "buildrc version check successful ✅ - $got"
fi
echo "checking buildrc version 🔄"
