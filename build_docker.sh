#!/usr/bin/env bash

docker buildx build --platform="linux/amd64" --rm -t mlgo:latest .
