#!/bin/bash

set -e

function install_tools {
    brew install pkgx &> /dev/null
    set -a;
    eval "$(pkgx +ruby@3.3.0 +bundle +xcodes)"
    set +a
}

install_tools

echo "Running unit tests..."
bundle config set path '.bundle'
bundle install
bundle exec fastlane test
echo "... done."
