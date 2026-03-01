#!/usr/bin/env bash

# install mise if not already installed
if ! command -v mise &> /dev/null; then
    echo "Mise not found, installing..."
    curl -fsSL https://mise.sh/install | sh
    export PATH="$HOME/.mise/bin:$PATH"
else
    echo "Mise is already installed."
fi

mise trust && mise install
