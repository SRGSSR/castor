#!/bin/bash

function install_tools {
    curl -Ssf https://pkgx.sh | sh &> /dev/null
    set -a
    eval "$(pkgx +periphery)"
    set +a
}

install_tools

echo "Start checking dead code..."
mkdir -p .build
xcodebuild -scheme Castor -destination generic/platform=iOS -derivedDataPath ./.build/derived-data clean build &> /dev/null
periphery scan --retain-public --skip-build --index-store-path ./.build/derived-data/Index.noindex/DataStore/
xcodebuild -scheme Castor-demo -project ./Demo/Castor-demo.xcodeproj -destination generic/platform=iOS -derivedDataPath ./.build/derived-data clean build &> /dev/null
periphery scan --project ./Demo/Castor-demo.xcodeproj --schemes Castor-demo --targets Castor-demo --skip-build --index-store-path ./.build/derived-data/Index.noindex/DataStore/
echo "... done."