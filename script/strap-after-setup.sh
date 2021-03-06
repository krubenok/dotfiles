#!/bin/zsh
# Run by Strap after installing Brewfile dependencies

[ $(uname -s) = "Darwin" ] && export MACOS=1 && export UNIX=1
[ $(uname -s) = "Linux" ] && export LINUX=1 && export UNIX=1
uname -s | grep -q "_NT-" && export WINDOWS=1


cd $(dirname $0)/..

if [ "$SHELL" != "/bin/zsh" ]
then
  chsh -s /bin/zsh krubenok
fi

script/extract-onepassword-secrets.sh
script/node.sh

if [ $MACOS ]
  then
  script/dock.sh
  script/macos.sh
  # Check and install any remaining software updates.
  logn "Checking for software updates:"
  if softwareupdate -l 2>&1 | grep $Q "No new software available."; then
    logk
  else
    echo
    log "Installing software updates:"
    if [ -z "$STRAP_CI" ]; then
      sudo_askpass softwareupdate --install --all
      xcode_license
    else
      echo "Skipping software updates for CI"
    fi
    logk
  fi
  fi