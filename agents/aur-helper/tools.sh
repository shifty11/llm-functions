#!/usr/bin/env bash
set -e

# @env LLM_OUTPUT=/dev/stdout The output path

# @cmd Search for installed packages using pacman
# @option --query! The query to search for. If not provided, all installed packages will be shown.
search_pacman() {
    if ! pacman -Q "$argc_query" > "$LLM_OUTPUT" 2>/dev/null; then
        echo "No packages found matching '$argc_query'" > "$LLM_OUTPUT"
        exit 0
    fi
}

# @cmd Search for packages in the AUR
# @option --query! The query to search for. If not provided, all packages in the AUR will be shown.
search_aur() {
    encoded_query="$(jq -nr --arg q "$argc_query" '$q|@uri')"
    url="https://aur.archlinux.org/rpc/v5/search/$encoded_query"
    curl -fsSL "$url" | jq '.results[] | {
        name: .Name,
        version: .Version,
        description: .Description,
        maintainer: .Maintainer,
        votes: .NumVotes,
        popularity: .Popularity,
        url: .URL,
        last_modified: .LastModified,
        out_of_date: .OutOfDate
    }' >> "$LLM_OUTPUT"
}

eval "$(argc --argc-eval "$0" "$@")"
