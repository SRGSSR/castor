#!/bin/bash

set -e

function install_tools {
    curl -Ssf https://pkgx.sh | sh &> /dev/null
    set -a
    eval "$(pkgx +ruby@3.3.0 +bundle)"
    set +a
}

install_tools

echo "Building demo..."
bundle config set path '.bundle'
bundle install
bundle exec fastlane build_demo
echo "... done."