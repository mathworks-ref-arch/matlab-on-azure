#!/usr/bin/env bash
#
# Copyright 2026 The MathWorks, Inc.
#
# Install a standalone Adoptium Temurin JRE and point MATLAB/Polyspace at it.

set -euo pipefail

# Configuration (overridable via environment for testing).
# Java 8 for consistency with the Parallel Server refarchs.
JAVA_VERSION="${JAVA_VERSION:-8}"
OS="${OS:-linux}"
ARCH="${ARCH:-x64}"
MATLAB_ROOT="${MATLAB_ROOT:-/usr/local/matlab}"
MATLAB_JRE_PATH="${MATLAB_JRE_PATH:-${MATLAB_ROOT}/sys/java/jre/glnxa64/}"

adoptium_asset_api_url() {
  echo "https://api.adoptium.net/v3/assets/latest/${JAVA_VERSION}/hotspot?architecture=${ARCH}&image_type=jre&os=${OS}&vendor=eclipse"
}

# curl that fails on HTTP errors and retries transient failures.
curl_retry() {
  curl --fail --show-error \
    --retry 5 --retry-connrefused --retry-delay 5 --max-time 300 "$@"
}

# Download the JRE archive, verify its checksum, and print the filename.
download_jre() {
  local metadata link checksum filename
  echo "Downloading JRE ${JAVA_VERSION} (${OS}/${ARCH})..." >&2

  # The assets API returns the download link and its SHA-256 in one response.
  metadata=$(curl_retry -Ls "$(adoptium_asset_api_url)")
  link=$(echo "${metadata}" | jq -r '.[0].binary.package.link')
  checksum=$(echo "${metadata}" | jq -r '.[0].binary.package.checksum')
  if [[ -z "${link}" || "${link}" == "null" ]]; then
    echo "ERROR: Adoptium API returned no download link for JRE ${JAVA_VERSION} (${OS}/${ARCH})" >&2
    return 1
  fi
  filename=$(curl_retry -OLs -w '%{filename_effective}' "${link}")

  echo "Verifying checksum..." >&2
  echo "${checksum}  ${filename}" | sha256sum -c --status
  echo "Checksum OK" >&2

  echo "${filename}"
}

# Extract the archive to the install dir and print that dir.
install_jre() {
  local filename="$1"
  local install_dir="/opt/java/${JAVA_VERSION}/jre"
  sudo rm -rf "${install_dir}"
  sudo mkdir -p "${install_dir}"
  sudo tar xzf "${filename}" -C "${install_dir}" --strip-components=1
  echo "${install_dir}"
}

# Symlink the standalone JRE over MATLAB's bundled one.
configure_matlab_jre() {
  local install_dir="$1"
  # Create the parent first: R2026b ships no bundled JRE tree to symlink over.
  sudo mkdir -p "${MATLAB_JRE_PATH}"
  sudo rm -rf "${MATLAB_JRE_PATH}/jre"
  sudo ln -s "${install_dir}" "${MATLAB_JRE_PATH}/jre"
}

# If Polyspace is present, symlink its bundled JRE to the standalone one.
configure_polyspace_jre() {
  local install_dir="$1"
  local polyspace_jre_path="${POLYSPACE_JRE_PATH:-/usr/local/polyspace/sys/java/jre/glnxa64/}"
  if [ -d "${polyspace_jre_path}" ]; then
    sudo rm -rf "${polyspace_jre_path}/jre"
    sudo ln -s "${install_dir}" "${polyspace_jre_path}/jre"
  fi
}

# Log the Temurin license terms and on-image license files.
print_license_info() {
  local install_dir="$1"
  local legal_base="${install_dir}/legal/java.base"

  echo "============================================================"
  echo "Adoptium Temurin JRE ${JAVA_VERSION} license information"
  echo "============================================================"
  echo "License: GNU General Public License, version 2, WITH the Classpath Exception"
  echo "SPDX-License-Identifier: GPL-2.0 WITH Classpath-exception-2.0"
  echo "Source: $(adoptium_asset_api_url)"
  echo

  if [ -f "${install_dir}/NOTICE" ]; then
    echo "----- NOTICE (bundled with the JRE) -----"
    cat "${install_dir}/NOTICE"
    echo
  fi

  echo "----- Full license text bundled on the image -----"
  local f
  for f in LICENSE ASSEMBLY_EXCEPTION ADDITIONAL_LICENSE_INFO; do
    if [ -f "${legal_base}/${f}" ]; then
      echo "  ${legal_base}/${f}"
    fi
  done
  echo

  if [ -d "${install_dir}/legal" ]; then
    echo "----- Third-party component licenses (under ${install_dir}/legal) -----"
    find "${install_dir}/legal" -type f \( -name '*.md' -o -name 'LICENSE' \) \
      | sort | sed "s|^${install_dir}/|  |"
    echo
  fi
  echo "============================================================"
}

main() {
  local filename install_dir
  filename="$(download_jre)"
  install_dir="$(install_jre "${filename}")"

  configure_matlab_jre "${install_dir}"
  configure_polyspace_jre "${install_dir}"

  echo "Adoptium JRE ${JAVA_VERSION} installed to ${install_dir}"
  "${install_dir}/bin/java" -version

  print_license_info "${install_dir}"

  sudo rm -f "${filename}"
}

# Only run main when executed directly, so the functions can be sourced in tests.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
