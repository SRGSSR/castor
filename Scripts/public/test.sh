#!/bin/bash

set -e

function install_tools {
    curl -Ssf https://pkgx.sh | sh &> /dev/null
    set -a
    eval "$(pkgx +ruby +bundle +xcodes)"
    set +a
}

install_tools

echo "Running unit tests..."
bundle config set path '.bundle'
bundle install
bundle exec fastlane test
echo "... done."