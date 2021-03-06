#!/bin/sh


if ! command -v brew >/dev/null
  then
    echo "Install brew first!" >&2
    exit 1
  fi

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash

nvm install --lts --latest-npm