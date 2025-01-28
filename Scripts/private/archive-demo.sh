#!/bin/bash

set -e

function install_tools {
    curl -Ssf https://pkgx.sh | sh &> /dev/null
    set -a
    eval "$(pkgx +bundle)"
    set +a
}

install_tools

echo "Archiving demo..."
bundle config set path '.bundle'
bundle install
bundle exec fastlane archive_demo
echo "... done."