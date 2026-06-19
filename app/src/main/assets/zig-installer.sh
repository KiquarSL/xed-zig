#!/bin/bash
set -e

source "$LOCAL/bin/utils"

# CONFIGURATION

LSP_DIR="$HOME/.lsp"
INSTALL_DIR_ZIG="$LSP_DIR/zig"

ZIG_VERSION="0.13.0"  
ZLS_VERSION="$1"

# UTILS

get_arch() {
  case "$(uname -m)" in
    x86_64)   echo "x86_64" ;;
    aarch64|arm64) echo "aarch64" ;;
    *) error "Unsupported arch: $(uname -m)"; exit 1 ;;
  esac
}

get_zig_url() {
  local arch=$1
  echo "https://ziglang.org/download/${ZIG_VERSION}/zig-linux-${arch}-${ZIG_VERSION}.tar.xz"
}

get_zls_url() {
  local arch=$1
  echo "https://github.com/zigtools/zls/releases/download/${ZLS_VERSION}/zls-${arch}-linux.tar.xz"
}

# ZIG INSTALL

install_zig() {
  info "Installing Zig ${ZIG_VERSION}..."

  local arch=$(get_arch)
  local url=$(get_zig_url "$arch")
  local tmp_dir=$(mktemp -d)

  apt install -y curl tar xz-utils

  curl -L "$url" | tar -xJ -C "$tmp_dir"

  mkdir -p "$INSTALL_DIR_ZIG"
  mv "$tmp_dir"/*/* "$INSTALL_DIR_ZIG/"

  rm -rf "$tmp_dir"
  echo "$ZIG_VERSION" > "$INSTALL_DIR_ZIG/version.txt"

  info "Zig installed to $INSTALL_DIR_ZIG"
}

# ZLS (LSP) INSTALL

install_zls() {
  info "Installing ZLS ${ZLS_VERSION}..."

  local arch=$(get_arch)
  local url=$(get_zls_url "$arch")
  local tmp_dir=$(mktemp -d)

  curl -L "$url" | tar -xJ -C "$tmp_dir"

  mkdir -p "$INSTALL_DIR_ZIG/bin"
  mv "$tmp_dir"/zls "$INSTALL_DIR_ZIG/bin/zls"
  chmod +x "$INSTALL_DIR_ZIG/bin/zls"

  rm -rf "$tmp_dir"
  echo "$ZLS_VERSION" > "$INSTALL_DIR_ZIG/zls_version.txt"

  info "ZLS installed to $INSTALL_DIR_ZIG/bin/zls"
}

# MAIN

case "$1" in
  --install-zig)    install_zig ;;
  --install-zls)    install_zls ;;
  --all)            install_zig && install_zls ;;
  --uninstall)      rm -rf "$INSTALL_DIR_ZIG" ;;
  --update)         rm -rf "$INSTALL_DIR_ZIG" && install_zig && install_zls ;;
  *)
    echo "Usage: $0 [--install-zig | --install-zls | --all | --uninstall | --update]"
    ;;
esac