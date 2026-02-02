#!/bin/bash

set -e

function usage {
    echo
    echo "Usage: $0 -c [nightly | release]"
    echo
    exit 1
}

function install_tools {
    curl -Ssf https://pkgx.sh | sh &> /dev/null
    set -a
    eval "$(pkgx +ruby@3.3.0 +bundle +magick)"
    set +a
}

while getopts c: OPT; do
    case "$OPT" in
        c)
            CONFIGURATION=$OPTARG
            ;;
        *)
            usage
            ;;
    esac
done

if [[ $CONFIGURATION != "nightly" && $CONFIGURATION != "release" ]]; then
    usage
fi

install_tools

echo -e "Delivering demo $CONFIGURATION build"
bundle config set path '.bundle'
bundle install
pkgx +rsvg-convert bundle exec fastlane "deliver_demo_${CONFIGURATION}"
echo "... done."
