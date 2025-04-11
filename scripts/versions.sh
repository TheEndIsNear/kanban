#!/bin/bash

set -x 

version_output=$(cat ./.tool-versions)

ELIXIR_VERSION=$(echo "$version_output"  \
	         | grep 'elixir' \
		 | cut -d' ' -f2 \
		 | cut -d'-' -f1)

ERLANG_VERSION=$(echo "$version_output" | grep 'erlang' | cut -d' ' -f2)

{
	echo "ELIXIR_VERSION=${ELIXIR_VERSION}";
	echo "ERLANG_VERSION=${ERLANG_VERSION}";
} >> "$GITHUB_ENV"
