#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/sass/dart-sass-embedded"
TOOL_NAME="dart-sass-embedded"
TOOL_TEST="dart-sass-embedded --version"

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

curl_opts=(-fsSL)

# NOTE: You might want to remove this if dart-sass-embedded is not hosted on GitHub releases.
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

get_platform() {
  local platform

  case "$(uname | tr '[:upper:]' '[:lower:]')" in
  darwin) platform="macos" ;;
  linux) platform="linux" ;;
  windows) platform="windows" ;;
  *)
    fail "Platform '$(uname)' not supported!"
    ;;
  esac

  echo -n $platform
}

get_arch() {
  local arch

  case "$(uname -m)" in
  x86_64 | amd64) arch="x64" ;;
  i686 | i386) arch="ia32" ;;
  armv6l | armv7l) arch="arm" ;;
  aarch64 | arm64) arch="arm64" ;;
  *)
    fail "Arch '$(uname -m)' not supported!"
    ;;
  esac

  echo -n $arch
}

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
	git ls-remote --tags --refs "$GH_REPO" |
		grep -o 'refs/tags/.*' | cut -d/ -f3- |
		sed 's/^v//' # NOTE: You might want to adapt this sed to remove non-version strings from tags
}

list_all_versions() {
	list_github_tags
}

download_release() {
	local version filename url
	version="$1"
	filename="$2"
	arch="$(get_arch)"
  platform="$(get_platform)"

	# Example:
	# https://github.com/sass/dart-sass-embedded/releases/download/1.62.1/sass_embedded-1.62.1-linux-x64.tar.gz
	url="$GH_REPO/releases/download/${version}/sass_embedded-${version}-${platform}-${arch}.tar.gz"

	echo "* Downloading $TOOL_NAME release $version..."
	curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="${3%/bin}/bin"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	(
		mkdir -p "$install_path"
		cp -r "$ASDF_DOWNLOAD_PATH"/* "$install_path"

		local tool_cmd
		tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
		test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}
