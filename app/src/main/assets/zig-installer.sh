#!/bin/sh
set -e

source "$LOCAL/bin/utils" 2>/dev/null 

# CONFIGURATION

INSTALL_DIR_ZIG="$LOCAL/bin"

LSP_DIR_ZLS="$HOME/.lsp/zig"

ZIG_VERSION="0.13.0"
ZLS_VERSION="$1"

if [ -z "$ZLS_VERSION" ]; then
    error "No ZLS version provided"
    exit 1
fi

# HELPERS

get_arch() {
    case "$(uname -m)" in
        x86_64)
            echo "x86_64"
            ;;
        aarch64|arm64)
            echo "aarch64"
            ;;
        armv7l|arm)
            echo "armv7l"
            ;;
        *)
            error "Unsupported architecture: $(uname -m)"
            exit 1
            ;;
    esac
}

get_zig_url() {
    local arch="$1"
    echo "https://ziglang.org/download/${ZIG_VERSION}/zig-linux-${arch}-${ZIG_VERSION}.tar.xz"
}

get_zls_url() {
    local arch="$1"
    echo "https://github.com/zigtools/zls/releases/download/${ZLS_VERSION}/zls-${arch}-linux.tar.xz"
}

# ZIG INSTALL

install_zig() {
    info "Installing Zig ${ZIG_VERSION}..."

    local arch=$(get_arch)
    local url=$(get_zig_url "$arch")
    local tmp_dir=$(mktemp -d)

    apt install -y curl tar xz-utils 2>/dev/null || pkg install curl tar xz-utils 2>/dev/null

    curl -L "$url" | tar -xJ -C "$tmp_dir"

    mkdir -p "$INSTALL_DIR_ZIG"
    rm -rf "$INSTALL_DIR_ZIG/zig" 2>/dev/null || true
    mv "$tmp_dir"/* "$INSTALL_DIR_ZIG/zig"

    rm -rf "$tmp_dir"
    echo "$ZIG_VERSION" > "$INSTALL_DIR_ZIG/zig/version.txt"

    chmod +x "$INSTALL_DIR_ZIG/zig/zig"

    info "Zig installed to $INSTALL_DIR_ZIG/zig"
}

# ZLS (LSP) INSTALL

install_zls() {
    info "Installing ZLS ${ZLS_VERSION}..."

    local arch=$(get_arch)
    local url=$(get_zls_url "$arch")
    local tmp_dir=$(mktemp -d)

    curl -L "$url" | tar -xJ -C "$tmp_dir"

    mkdir -p "$LSP_DIR_ZLS/bin"
    mv "$tmp_dir"/zls "$LSP_DIR_ZLS/bin/zls"
    chmod +x "$LSP_DIR_ZLS/bin/zls"

    rm -rf "$tmp_dir"
    echo "$ZLS_VERSION" > "$LSP_DIR_ZLS/zls_version.txt"

    info "ZLS installed to $LSP_DIR_ZLS/bin/zls"
}

# MAIN

case "$1" in
    --uninstall)
        info "Uninstalling Zig and ZLS..."
        rm -rf "$INSTALL_DIR_ZIG/zig"
        rm -rf "$LSP_DIR_ZLS"
        info "Uninstalled successfully."
        exit 0
        ;;
    --update)
        info "Updating..."
        rm -rf "$INSTALL_DIR_ZIG/zig"
        rm -rf "$LSP_DIR_ZLS"
        install_zig
        install_zls
        exit 0
        ;;
    *)
        install_zig
        install_zls
		
        if ! grep -q "export PATH=\$PATH:\$LOCAL/bin/zig" ~/.bashrc; then
            echo "export PATH=\$PATH:\$LOCAL/bin/zig" >> ~/.bashrc
        fi
        if ! grep -q "export PATH=\$PATH:\$HOME/.lsp/zig/bin" ~/.bashrc; then
            echo "export PATH=\$PATH:\$HOME/.lsp/zig/bin" >> ~/.bashrc
        fi

        info "All done! Restart your terminal or run: source ~/.bashrc"
        exit 0
        ;;
esac