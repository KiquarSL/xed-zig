#!/system/bin/sh
set -e

if [ -z "$LOCAL" ]; then
    echo "ERROR: LOCAL variable not set"
    exit 1
fi

source "$LOCAL/bin/utils" 2>/dev/null || {
    echo "ERROR: Cannot source utils from $LOCAL/bin/utils"
    exit 1
}

# ============================================
# CONFIGURATION
# ============================================

LSP_DIR="$HOME/.lsp"
INSTALL_DIR_ZIG="$LSP_DIR/zig"

ZIG_VERSION="0.13.0"
ZLS_VERSION="$1"

if [ -z "$ZLS_VERSION" ]; then
    error "No ZLS version provided"
    exit 1
fi

# ============================================
# HELPERS
# ============================================

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

# ============================================
# ZIG INSTALL
# ============================================

install_zig() {
    info "Installing Zig ${ZIG_VERSION}..."

    local arch=$(get_arch)
    local url=$(get_zig_url "$arch")
    local tmp_dir=$(mktemp -d)

    apt install -y curl tar xz-utils 2>/dev/null || pkg install curl tar xz-utils 2>/dev/null

    curl -L "$url" | tar -xJ -C "$tmp_dir"

    mkdir -p "$INSTALL_DIR_ZIG"
    rm -rf "$INSTALL_DIR_ZIG"/*
    mv "$tmp_dir"/*/* "$INSTALL_DIR_ZIG/"

    rm -rf "$tmp_dir"
    echo "$ZIG_VERSION" > "$INSTALL_DIR_ZIG/version.txt"

    info "Zig installed to $INSTALL_DIR_ZIG"
}

# ============================================
# ZLS (LSP) INSTALL
# ============================================

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

# ============================================
# MAIN
# ============================================

case "$1" in
    --uninstall)
        info "Uninstalling Zig and ZLS..."
        rm -rf "$INSTALL_DIR_ZIG"
        info "Uninstalled successfully."
        exit 0
        ;;
    --update)
        info "Updating..."
        rm -rf "$INSTALL_DIR_ZIG"
        install_zig
        install_zls
        exit 0
        ;;
    *)
        if [ -n "$1" ] && [[ "$1" != --* ]]; then
            install_zig
            install_zls
        else
            install_zig
            install_zls
        fi
        exit 0
        ;;
esac