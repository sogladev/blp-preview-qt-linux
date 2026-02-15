#!/usr/bin/env bash

set -e

echo "=== BLP Image Format Plugin Installer ==="
echo ""

# Check for warcraft-rs
if ! command -v warcraft-rs &> /dev/null; then
    echo "❌ Error: warcraft-rs not found!"
    echo "The plugin requires warcraft-rs to convert BLP images."
    echo ""
    echo "Install it with:"
    echo "  cargo install warcraft-rs"
    exit 1
fi

# Check if warcraft-rs is in a standard system location
WARCRAFT_RS_PATH=$(which warcraft-rs)
if [[ "$WARCRAFT_RS_PATH" == "$HOME/.cargo/bin/warcraft-rs" ]]; then
    echo "⚠ Warning: warcraft-rs is in ~/.cargo/bin"
    echo "   GUI applications may not find it when opening files via double-click."
    echo ""
    echo "   Recommend creating a system symlink:"
    echo "   sudo ln -s ~/.cargo/bin/warcraft-rs /usr/local/bin/warcraft-rs"
    echo ""
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

echo "Installing BLP support..."
echo ""

# Check if dist/ exists and has the plugin
if [ ! -f "dist/libblp.so" ]; then
    echo "❌ Error: dist/libblp.so not found!"
    echo "Please run ./build.sh first to build the plugin."
    exit 1
fi

# Detect Qt plugins directory
QT_PLUGINS_DIR="/usr/lib64/qt6/plugins/imageformats"
if [ ! -d "/usr/lib64/qt6" ]; then
    # Try alternative location
    QT_PLUGINS_DIR="/usr/lib/x86_64-linux-gnu/qt6/plugins/imageformats"
    if [ ! -d "/usr/lib/x86_64-linux-gnu/qt6" ]; then
        echo "❌ Qt6 plugins directory not found!"
        echo "Please ensure Qt6 development packages are installed:"
        echo "  Fedora: sudo dnf install qt6-qtbase-devel"
        echo "  Ubuntu: sudo apt install qt6-base-dev"
        exit 1
    fi
fi

echo "1. Installing Qt6 plugin..."
sudo mkdir -p "$QT_PLUGINS_DIR"
sudo cp dist/libblp.so "$QT_PLUGINS_DIR/"
sudo cp dist/blp.json "$QT_PLUGINS_DIR/"
sudo chmod 644 "$QT_PLUGINS_DIR/blp.json"
sudo chmod 755 "$QT_PLUGINS_DIR/libblp.so"
echo "   ✓ Installed to $QT_PLUGINS_DIR"

echo "2. Installing MIME type definition..."
sudo mkdir -p /usr/share/mime/packages
sudo cp dist/blp-mime.xml /usr/share/mime/packages/
echo "2a. Updating MIME database... May take a moment..."
sudo update-mime-database /usr/share/mime 2>/dev/null || true
echo "   ✓ MIME type registered"

echo "3. Installing thumbnailer..."
sudo mkdir -p /usr/share/thumbnailers
sudo cp dist/blp.thumbnailer /usr/share/thumbnailers/
echo "   ✓ Thumbnailer installed"

echo ""
echo "=== Installation Complete! ==="
echo ""
echo "BLP files will now:"
echo "  • Open in Gwenview"
echo "  • Show thumbnails in Dolphin"
echo "  • Be recognized as image/x-blp MIME type"
echo ""
echo "You may need to:"
echo "  • Restart Dolphin: killall dolphin && dolphin &"
echo "  • Clear thumbnail cache: rm -rf ~/.cache/thumbnails/*"
echo ""
echo "Test with: gwenview texture.blp"
