#!/bin/bash
# Misc aliases

# Git
## Fix oh-my-zsh git plugin
#unalias gg
#unalias gga

alias ungit="find . -name '.git' -exec rm -rf {} \;"
alias gb='git branch'
alias gba='git branch -a'
alias gc='git commit -v'
alias gca='git commit -v -a'
# Commit pending changes and quote all args as message
function gg() {
  git commit -v -a -m "$*"
}
alias gco='git checkout '
alias gd='git diff'
alias gdm='git diff master'
alias gl='git pull'
alias gnp="git-notpushed"
alias gp='git push'
alias gst='git status'
alias gt='git status'
alias g='git status'
alias eg='subl .git/config'
alias gbd='git branch -D'
# Git clone from GitHub
function gch() {
  git clone git://github.com/$USER/$1.git
}
function gitgrep() {
  git rev-list --all | xargs git grep $@
}
alias git_clean_merged_branches='git branch --merged | egrep -v "(^\*|master)" | xargs git branch -d'
# Setup a tracking branch from [remote] [branch_name]
function gbt() {
  git branch --track $2 $1/$2 && git checkout $2
}
# Quickly clobber a file and checkout
function grf() {
  rm $1
  git checkout $1
}

# Run mutt under plain xterm TERM type
alias mutt='TERM=xterm mutt'

# Run irssi in screen type term so scrooling works in tmux
alias irssi='TERM=screen-256color irssi'

alias beep='echo -en "\007"'

if [ "${DISTRIBUTION}" = "Darwin" ]; then
  alias topc='top -o cpu'
  alias flushdns='dscacheutil -flushcache'
  # Quick way to rebuild the Launch Services database and get rid
  # # of duplicates in the Open With submenu.
  alias fixopenwith='/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user'
  # alias ls='exa --git'

  function notify() {
    osascript -e "display notification \"$*\" with title \"Shell notification\""
  }

  # iTerm name tab function
  function nametab() { echo -ne "\033]0;"$@"\007"; }
  # Homebrew
  alias brewski='brew update && brew upgrade && brew cleanup; brew doctor'
  # TailScale
  alias tailscale=/Applications/Tailscale.app/Contents/MacOS/Tailscale

  alias npm-vpn-off="osascript -e 'tell application \"Viscosity\" to disconnect \"npm\"'"
  alias npm-vpn-on="osascript -e 'tell application \"Viscosity\" to connect \"npm\"'"
  alias npm-staging-vpn-off="osascript -e 'tell application \"Viscosity\" to disconnect \"npm-staging\"'"
  alias npm-staging-vpn-on="osascript -e 'tell application \"Viscosity\" to connect \"npm-staging\"'"
  alias vpn-dev="open https://fido-challenger.githubapp.com/auth/vpn-devvpn && osascript -e 'tell application \"Viscosity\" to connect \"github-iad-devvpn\"'"

  alias secpass_save='function _secpass_save(){ security add-generic-password -a hilli -s $1 -w $2 };_secpass_save'
  alias secpass_lookup='function _secpass_lookup(){ security find-generic-password -a hilli -s $1 -w };_secpass_lookup'
fi

if [ "${DISTRIBUTION}" = "debian" ]; then
  alias open="gnome-open"
fi

if [ "$(uname)" = "Linux" ]; then
  # Add some color when using GNU ls
  alias d="ls --color"
  alias ls="ls --color=auto"
  alias ll="ls --color -l"
fi

alias rssh="ssh -t -o RemoteCommand='sudo su -'"
alias pssh="ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no"

function dkwhois() {
  whois -h whois.dk-hostmaster.dk " --show-handles --charset=utf-8 $1"
}

# Docker
# http://kartar.net/2014/03/some-useful-docker-bash-functions-and-aliases/
# Remove all stopped containvers
alias drm="docker rm \$(docker ps -q -a)"
# Remove all non-used images
alias dri="docker rmi \$(docker images -q)"
# Run image in interactive container
alias dki="docker run -t -i -P"
function dcontext() {
  echo "Setting docker context to"
  if [ -z "$1" ]; then
    docker context use default
  else
    docker context use "$1"
  fi
}

alias myip="dig +short myip.opendns.com @resolver1.opendns.com"

# Clever auto checkout of your most used repos
# Uses grealpath from coreutils (brew install coreutils && brew link coreutils)
if [ -f /usr/bin/realpath ]; then
  alias grealpath="realpath -s"
fi
function cd() {
  GITHUB_ROOT="$HOME/github"
  NPM_ROOT="$HOME/npm"
  if [[ "$1" == "-P" ]]; then
    builtin cd -P "$1" || return
  fi
  if [[ "$1" == "-" ]]; then
    builtin cd - || return
    return
  fi
  dir="$(grealpath -m "${1:-$HOME}")"
  if [[ "$dir" = $GITHUB_ROOT/* ]]; then
    repo="${dir#$GITHUB_ROOT/}"
    repo_dir="$GITHUB_ROOT/${repo%%/*}"
    [[ -d "$repo_dir" ]] || git clone "https://github.com/github/$repo" "$repo_dir"
  fi
  if [[ "$dir" = $NPM_ROOT/* ]]; then
    repo="${dir#$NPM_ROOT/}"
    repo_dir="$NPM_ROOT/${repo%%/*}"
    [[ -d "$repo_dir" ]] || git clone "https://github.com/npm/$repo" "$repo_dir"
  fi
  builtin cd "$dir"
}

## Use SvelteKit to bootstrap a new svelte project and kickstart it.
function svelte-me() {
  npm init svelte@next "$1"
  cd "$1" || exit
  npm install
  git init
  git add -A
  git commit -m "Initial commit"
  code .
  npm run dev -- --open
}

function colormap() {
  for i in {0..255}; do
    printf "\x1b[38;5;${i}mcolour${i}\n"
  done
}

function cscode() {
  if [ -z "$1" ]; then
    echo "Usage: cscode -r github_repo_name [-b branch_name]"
    return
  fi
  csname="$(gh cs create $@)"
  gh cs code -c $csname
}

alias listening_on_my_mac="netstat -an -ptcp | grep LISTEN"

function nibbles() {
  if [ ! -f "${GOPATH}/bin/nibbles" ]; then
    go install github.com/gophun/nibbles@latest
  else
    $GOPATH/bin/nibbles
  fi
}

# Useful for accessing keychain when working remotely
alias keychain_login="security -v unlock-keychain ~/Library/Keychains/login.keychain-db"

# 1Password CLI
alias oplogin="eval \$(op signin --account my)"
