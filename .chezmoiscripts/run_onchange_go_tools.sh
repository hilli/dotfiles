#!/bin/bash
if [ "$(command -v go)" ]; then
  echo Installing go tools
  go install golang.org/x/review/git-codereview@latest
fi
