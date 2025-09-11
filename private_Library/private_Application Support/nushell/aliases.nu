# Brew maint

def brewski [] {
  brew update
  brew upgrade --greedy
  brew cleanup
  brew doctor
}

def dkwhois [domain: string] {
  whois -h whois.dk-hostmaster.dk " --show-handles --charset=utf-8 ($domain)"
}

# Generate an UUID
def uuidgen [] { ^uuidgen | tr A-F a-f }


# ls long
alias ll = ls -l

# ls all long
alias la = ls -la

# Git: status
alias g = git status

# Git: checkout
alias gco = git checkout

# Git: pull
alias gl = git pull

# Git: push
alias gp = git push

# Git: diff
alias gd = git diff

# Git: branches
def gb [] {
  git branch | lines
}

# Git: Add changed files with message
def gg [...message: string] {
  let msg = $message | str join " "
  git commit -am $msg
}
 
# Git: Delete merged branches
def git_clean_merged_branches [] {
  git branch --merged | lines | where ($it != "* master" and $it != "* main") | each {|br| git branch -D ($br | str trim) } | str trim
}

# Git: Show files changed in current PR
alias git_pr_changed_files = gh pr diff --name-only

# The mac version of open (shadowed by the build-in open)
alias mac-open = /usr/bin/open
