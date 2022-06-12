#!/bin/bash
if [ "$(command -v go)" ]; then
  echo Installing go tools
  go install golang.org/x/review/git-codereview@latest
  go install github.com/bufbuild/buf/cmd/buf@latest
  go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest
  go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
  go install github.com/bufbuild/connect-go/cmd/protoc-gen-connect-go@latest
fi
