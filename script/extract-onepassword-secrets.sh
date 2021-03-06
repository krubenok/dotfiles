#!/bin/bash
set -e

if ! [ -d ~/.gnupg ] || ! [ -d ~/.ssh ]
then
  echo "Run script/setup first!" >&2
  exit 1
fi

onepassword_login() {
  if ! command -v op >/dev/null
  then
    echo "Install op first!" >&2
    exit 1
  fi

  # shellcheck disable=SC2154
  if [ -z "$OP_SESSION_my" ]
  then
    echo "Logging into 1Password..."
    eval "$(op signin my.1password.com kyle@rubenok.ca)"
  fi
}

onepassword_get() {
  if [ -f "$HOME/$2" ]
  then
    echo "$2 already exists."
    return
  fi
  echo "Extracting $2..."
  onepassword_login
  op get document "$1" > "$HOME/$2"
  chmod 600 "$HOME/$2"
}

# Document UUID for my SSH Key
onepassword_get 52xpxlf7rjeyhhhrfzsmlvo4ye .ssh/id_rsa

# Document UUID for my SSH Config File
onepassword_get lu7oti5ff5e2jofhcvtppdmto4 .ssh/config

# Document UUID for my GPG Private Key
onepassword_get kc4e6223xbd4ne4hoe6blrtxeu .gnupg/kyle@rubenok.ca.private.gpg

# Document UUID for my Work GPG Private Key
onepassword_get 4opqwamwyffgbb4jue42kgqqrm .gnupg/work-private.gpg

if ! [ -f "$HOME/.secrets" ]
then
  echo "Extracting secrets..."
  if ! command -v jq >/dev/null
  then
    echo "Install jq first!" >&2
    exit 1
  fi
  onepassword_login
  GITHUB_TOKEN=$(op get item bwfxkn3fdvcrpn4dqxdlbl4sju | jq -r '.details.sections[0].fields[1].v')
  cat > "$HOME/.secrets" <<EOF
export GITHUB_TOKEN=$GITHUB_TOKEN
EOF
  chmod 600 "$HOME/.secrets"
fi

echo "Storing SSH keys in keychain..."
ssh-add -K

echo "Setting up GPG..."
if ! command -v gpg >/dev/null
then
    echo "Install GPG first!" >&2
    exit 1
fi

chmod 700 ~/.gnupg
gpg --import ~/.gnupg/kyle@rubenok.ca.public.gpg \
             ~/.gnupg/kyle@rubenok.ca.private.gpg

gpg --import ~/.gnupg/work-public.gpg \
             ~/.gnupg/work-private.gpg