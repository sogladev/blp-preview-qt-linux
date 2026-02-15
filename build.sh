#!/usr/bin/env bash
set -e

echo "=== Building BLP Image Format Plugin ==="
echo ""

# Check for warcraft-rs
if ! command -v warcraft-rs &> /dev/null; then
    echo "⚠ Warning: warcraft-rs not found!"
    echo "The plugin requires warcraft-rs to convert BLP images."
    echo "Install it with: cargo install warcraft-rs"
    echo ""
fi

# Build Qt6 plugin
echo "1. Building Qt6 plugin..."
mkdir -p build
cd build
cmake ..
make -j$(nproc)

# Create dist directory and copy built files
echo "2. Preparing distribution files..."
cd ..
mkdir -p dist
cp build/libblp.so dist/
cp blp.json dist/
cp blp-mime.xml dist/
cp blp.thumbnailer dist/

echo ""
echo "=== Build Complete! ==="
echo ""
echo "Distribution files ready in: dist/"
echo "  • libblp.so (Qt6 plugin)"
echo "  • blp.json (plugin metadata)"
echo "  • blp-mime.xml (MIME type definition)"
echo "  • blp.thumbnailer (thumbnail generator)"
echo ""
echo "Next step: Run ./install.sh to install system-wide"
