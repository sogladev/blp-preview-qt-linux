#!/usr/bin/env bash

echo "=== BLP Image Format Plugin Uninstaller ==="
echo ""

# Detect Qt plugins directory
QT_PLUGINS_DIR="/usr/lib64/qt6/plugins/imageformats"
if [ ! -d "/usr/lib64/qt6" ]; then
    QT_PLUGINS_DIR="/usr/lib/x86_64-linux-gnu/qt6/plugins/imageformats"
fi

echo "Removing BLP support..."
echo ""

# Remove Qt6 plugin
if [ -f "$QT_PLUGINS_DIR/libblp.so" ]; then
    echo "1. Removing Qt6 plugin..."
    sudo rm -f "$QT_PLUGINS_DIR/libblp.so"
    sudo rm -f "$QT_PLUGINS_DIR/blp.json"
    echo "   ✓ Plugin removed"
else
    echo "1. Qt6 plugin not found (already removed)"
fi

# Remove MIME type
if [ -f "/usr/share/mime/packages/blp-mime.xml" ]; then
    echo "2. Removing MIME type definition..."
    sudo rm -f /usr/share/mime/packages/blp-mime.xml
    sudo update-mime-database /usr/share/mime 2>/dev/null || true
    echo "   ✓ MIME type removed"
else
    echo "2. MIME type not found (already removed)"
fi

# Remove thumbnailer
if [ -f "/usr/share/thumbnailers/blp.thumbnailer" ]; then
    echo "3. Removing thumbnailer..."
    sudo rm -f /usr/share/thumbnailers/blp.thumbnailer
    echo "   ✓ Thumbnailer removed"
else
    echo "3. Thumbnailer not found (already removed)"
fi

# Remove old Rust binary if it exists (from previous version)
if [ -f "/usr/local/bin/blp-imageformat" ]; then
    echo "4. Removing old blp-imageformat binary..."
    sudo rm -f /usr/local/bin/blp-imageformat
    echo "   ✓ Old binary removed"
else
    echo "4. Old binary not found (already removed)"
fi

echo ""
echo "=== Uninstallation Complete! ==="
echo ""
echo "BLP support has been removed from your system."
echo ""
echo "Note: You may want to clear thumbnail cache:"
echo "  rm -rf ~/.cache/thumbnails/*"
echo ""
echo "To reinstall later, run: ./install.sh"
