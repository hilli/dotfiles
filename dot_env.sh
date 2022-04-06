# Determine the Linux distribution and version that is being run.
#
# Check for GNU/Linux distributions
if [ -f /etc/SuSE-release ]; then
	DISTRIBUTION="suse"
elif [ -f /etc/UnitedLinux-release ]; then
	DISTRIBUTION="united"
elif [ -f /etc/debian_version ]; then
	DISTRIBUTION="debian"
elif [ -f /etc/gentoo-release ]; then
	DISTRIBUTION="gentoo"
elif [ -f /etc/redhat-release ]; then
	a=$(grep -i 'red.*hat.*enterprise.*linux' /etc/redhat-release)
	if test $? = 0; then
		DISTRIBUTION=rhel
	else
		a=$(grep -i 'red.*hat.*linux' /etc/redhat-release)
		if test $? = 0; then
			DISTRIBUTION=rh
		else
			a=$(grep -i 'cern.*e.*linux' /etc/redhat-release)
			if test $? = 0; then
				DISTRIBUTION=cel
			else
				a=$(grep -i 'scientific linux cern' /etc/redhat-release)
				if test $? = 0; then
					DISTRIBUTION=slc
				else
					DISTRIBUTION="unknown"
				fi
			fi
		fi
	fi
else
	DISTRIBUTION=$(uname)
fi

# OS X specifics
if [ "$(uname)" = "Darwin" ]; then
	export LC_CTYPE=en_US.UTF-8
	export EDITOR='code --wait'

	ARCH="$(uname -m)"

	if [ $ARCH = "x86_64" ]; then
		export PATH=/usr/local/texlive/2008/bin/universal-darwin:$PATH
		export MANPATH=/usr/local/git/man:$MANPATH
		export MANPATH=/opt/local/share/man:$MANPATH
		export PATH=/opt/local/bin:/opt/local/sbin:$PATH
		# homebrew installed node.js
		export NODE_PATH=/usr/local/lib/node
		# OVFTool to path
		export PATH=$PATH:/Applications/VMware\ Fusion.app/Contents/Library/VMware\ OVF\ Tool
	fi

	if [ $ARCH = "arm64" ]; then
		export MANPATH=/opt/homebrew/manpages:/opt/homebrew/share/man:$MANPATH
		export PATH=/opt/homebrew/bin:/opt/homebrew/sbin:$PATH
	fi

	export PACKER_CACHE_DIR=~/.packer_cache

	# Homebrew installed bash completions
	[ "$SHELL" = '/bin/bash' ] && source /usr/local/etc/bash_completion.d/*
	[ "$SHELL" = '/bin/bash' ] && source /usr/local/etc/bash_completion.d/*
	export HOMEBREW_CASK_OPTS="--appdir=/Applications"
	if [ -f $(brew --prefix)/etc/bash_completion.d/aptly ]; then
		source $(brew --prefix)/etc/bash_completion.d/aptly
	fi

	# Use VirtualBox as default provider even though Fusion is installed
	export VAGRANT_DEFAULT_PROVIDER=virtualbox

	# ChefDK
	if [ -d /opt/chefdk/bin ]; then
		export PATH=/opt/chefdk/bin:$PATH
	fi
	# RBENV in /usr/local
	if [ -d /usr/local/rbenv ]; then
		export RBENV_ROOT=/usr/local/rbenv
	fi

	# Swift
	if [ -f ~/.swiftenv/bin/swiftenv ]; then
		export SWIFTENV_ROOT="$HOME/.swiftenv"
		export PATH="$SWIFTENV_ROOT/bin:$PATH"
		eval "$(swiftenv init -)"
	fi

	# Shut up Catalina bash warning
	export BASH_SILENCE_DEPRECATION_WARNING=1

	# 1Password
	eval "$(op completion zsh)"
	compdef _op op

# End Darwin
elif [ "$(uname)" = "Linux" ]; then

	#export LANG=da_DK
	export LANG=en_US.utf8
	export LANGUAGE=en_US:en
	export LC_COLLATE=en_US.utf8
	export LC_CTYPE=en_US.utf8
	export LC_MESSAGES=en_US.utf8
	export LC_MONETARY=en_US.utf8
	export LC_NUMERIC=en_US.utf8
	export LC_TIME=en_US.utf8
	export LESSCHARSET="utf-8"
	export GEM_PRIVATE_KEY='/home/hilli/.gem/gem-private_key.pem'
	export GEM_CERTIFICATE_CHAIN='/home/hilli/.gem/gem-public_cert.pem'
	export TERM="xterm-256color"

	# Set Gnome terminal tab name
	export PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\007"'

	export PATH=$PATH:$HOME/bin
	export GPG_TTY=$(tty)

	# Tell Lynx to use my own cfg
	export LYNX_CFG=~/.lynx.cfg

	if [ "${DISTRIBUTION}" = "gentoo" ]; then
		export EDITOR=/usr/bin/vim
		export MOZ_PRINTER_NAME='lp'
	fi
fi

# General settings with brew installed
if [ "$(command -v brew)" ]; then
	export PATH=$(brew --prefix)/bin:$(brew --prefix)/sbin:~/bin:$PATH
	# Include homebrew completions; https://formulae.brew.sh/formula/zsh-completions
	export FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
	# nvm
	if [ "$(command -v nvm)" ]; then
		export NVM_DIR="$HOME/.nvm"
		[ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && source "$(brew --prefix)/opt/nvm/nvm.sh"                                       # This loads nvm
		[ -s "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" ] && source "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" # This loads nvm bash_completion
	fi
fi

# chezmoi generated command completions
export FPATH=${FPATH}:${HOME}/.local/share/site-functions

# Set timestamps in .bash_history
export HISTTIMEFORMAT="%F %T "
export PATH=$PATH:/usr/local/bin:~/bin:/opt/local/bin:/opt/local/sbin
export RI="--format ansi --width 132"
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# golang
export GOPATH=$HOME/.go
export PATH=$PATH:$GOPATH/bin

# Regain SSH_AUTH_SOCK in screens
# http://blog.shanemeyers.com/2010/09/14/ssh-agent-in-gnu-screen/
if ! [ -S $SSH_AUTH_SOCK ]; then
	# delete old/lingering agent files
	for i in $(find /tmp/ssh-* -maxdepth 2 -name agent\* -user $USER 2>/dev/null); do
		if ! [ -S $i ]; then
			rm $i
		fi
	done
	unset i
	# set agent string
	#SSH_AUTH_SOCK="`find /tmp/ssh-* -maxdepth 2 -name agent\* -user $USER 2>/dev/null  | head -n1`"
	SSH_AUTH_SOCK="$(ls -tl /tmp/ssh-*/agent* | grep $USER | awk '{print $9}' | head -n1)"
	echo "Set SSH_AUTH_SOCK to $SSH_AUTH_SOCK"
fi

# Homebrew
# export HOMEBREW_GITHUB_API_TOKEN="$(skate get HOMEBREW_GITHUB_API_TOKEN)"

# rbenv
if [ -d $HOME/.rbenv ]; then
	export PATH="${HOME}/.rbenv/shims:${PATH}"
fi
if [ "$(command -v rbenv)" ]; then
	eval "$(rbenv init -)"
fi

# iTerm2
[[ ${TERM_PROGRAM} == "iTerm.app" ]] && source "${HOME}/.iterm2_shell_integration.zsh" || true
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh" || true

# direnv helper to setup local ENV pr dir
# http://www.futurile.net/2016/02/03/automating-environment-setup-with-direnv/
if [ "$SHELL" = "/bin/bash" ]; then
	eval "$(direnv hook bash)"
elif [ "$SHELL" = "/bin/zsh" ]; then
	eval "$(direnv hook zsh)"
fi

# HomeAssistant
# export HASS_TOKEN="$(security find-generic-password -s HASS_TOKEN -w)"
# export HASS_SERVER="$(security find-generic-password -s HASS_SERVER -w)"
# hass-cli disabled for now while I find a generic password store.

# Tesla API tokens (Publicly available)
export TESLA_CLIENT_ID="e4a9949fcfa04068f59abb5a658f2bac0a3428e4652315490b659d5ab3f35a9e"
export TESLA_CLIENT_SECRET="c75f14bbadc8bee3a7594412c31416f8300256d7668ea7e6e7f06727bfb9d220"

# Autoload node version based on .node-version files
if [ "$(command -v nvm)" ]; then
	[[ -s "$HOME/.zsh-auto-node-version" ]] && source "$HOME/.zsh-auto-node-version"
fi

# fd Options https://github.com/sharkdp/fd
# FD_OPTIONS="--follow --exclude .git --exclude node_modules --exclude .gitmodules --exclude .hg --exclude .hgignore --exclude .hg_archival.txt --exclude .bzr --exclude .bzrignore --exclude .bzr-archival.txt --exclude .svn --exclude .svnignore --exclude .hgignore --exclude .gitignore --exclude .git-archival.txt"
FD_OPTIONS="--follow --exclude .git --exclude node_modules"

# Load fzf
[ -f "${HOME}/.fzf/fzf.zsh" ] && source "${HOME}/.fzf/fzf.zsh"

# fzf Options https://github.com/junegunn/fzf
export FZF_DEFAULT_OPTS="--no-mouse --height 50% --reverse --multi --inline-info --preview='[[ \$(file --mime {}) =~ binary ]] && echo {} is a binary file || (bat --style=numbers --color=always {} || cat {}) 2> /dev/null | head -300' --preview-window='right:hidden:wrap' --bind='f3:execute(bat --style=numbers {} || less -f {}),f2:toggle-preview,ctrl-d:half-page-down,ctrl-u:half-page-up,ctrl-a:select-all+accept,ctrl-y:execute-silent(echo {+} | pbcopy)'"
export FZF_DEFAULT_COMMAND="git ls-files --cached --others --exclude-standard | fd --type f --type -1 $FD_OPTIONS"
export FZF_CTRL_T_COMMAND="fd $FD_OPTIONS"
export FZF_ALT_C_COMMAND="fd --type d $FD_OPTIONS"
export BAT_PAGER="less -R"

# Multiple kube configs
if [ -e ~/.kube/kube_env.sh ]; then
	source ~/.kube/kube_env.sh
fi

# StarShip prompt
export STARSHIP_CONFIG=~/.starship.toml
eval "$(starship init zsh)"
