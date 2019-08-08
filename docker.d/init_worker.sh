#!/bin/bash
set -e

# == START: this is what we need to configure ==
test $JWT_USER
test $JWT_SECRET
# == END:   this is what we need to configure ==

case $ENV in
  dev)
    export AMO_SERVER="https://addons.allizom.org"
    ;;
  fake-prod|prod)
    export AMO_SERVER="https://addons.mozilla.org"
    ;;
  *)
    exit 1
    ;;
esac

case $COT_PRODUCT in
  firefox)
    ;;
  *)
    exit 1
    ;;
esac

