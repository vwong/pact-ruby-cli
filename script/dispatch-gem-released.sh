#!/bin/sh

# Script to trigger release of gem via the pact-foundation/release-gem action
# Requires a Github API token with repo scope stored in the
# environment variable GITHUB_TOKEN

: "${GITHUB_TOKEN:?Please set environment variable GITHUB_TOKEN}"

if [ -n "$1" ]; then
  name="\"${1}\""
else
  name="null"
fi

if [ -n "$2" ]; then
  version="\"${2}\""
else
  version="null"
fi

if [ -n "$3" ]; then
  increment="\"${3}\""
else
  increment="null"
fi

repository_slug=$(git remote get-url origin | cut -d':' -f2 | sed 's/\.git//')

output=$(curl -v https://api.github.com/repos/${repository_slug}/dispatches \
      -H 'Accept: application/vnd.github+json' \
      -H "Authorization: Bearer $GITHUB_TOKEN" \
      -d "{\"event_type\": \"gem-released\", \"client_payload\": {\"name\": ${name}, \"version\" : ${version}, \"increment\" : ${increment}}}" 2>&1)

if  ! echo "${output}" | grep "HTTP\/.* 204" > /dev/null; then
  echo "$output" | sed  "s/${GITHUB_TOKEN}/********/g"
  echo "Failed to trigger release"
  exit 1
else
  echo "Release workflow triggered"
fi

echo "See https://github.com/${repository_slug}/actions?query=workflow%3A%22Release%22"
