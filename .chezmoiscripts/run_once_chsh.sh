#!/bin/bash

if [ "$(command -v zsh)" ]; then
  # What shell is the user currently using?
  if [ "$(uname)" = "Darwin" ]; then
    myshell=$(basename "$(dscl . -read "${HOME}" UserShell | sed 's/UserShell: //')")
  else
    myshell=$(basename "$(grep """$(whoami)""" /etc/passwd | cut -f 7 -d :)")
  fi
  if [ "${myshell}" != "zsh" ]; then
    # Set zsh as default shell.
    echo Running sudo to change your shell to zsh.
    sudo chsh -s "$(which zsh)" "$(whoami)"
  fi
fi
