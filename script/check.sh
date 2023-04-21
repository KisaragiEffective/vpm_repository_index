#!/bin/bash

set -exo

function die() {
  echo "Error:" "$@" >&2
  exit 1
}

data="$(readlink -e "$(dirname "$0")/../data.json")"

which jq || die "This shell script requires jq to be installed."

# JSON syntax check
jq <"$data" >/dev/null || die "Invalid JSON. Please see above error message."

# avoid directory traversal
if jq -r '.repository[] | .git_repository | .path[]' <"$data" | grep -E "(/\.\./|/\./)"; then
  die "Relative paths are not permitted"
fi

# Git repository check
tmp_tsv="$(mktemp)"
jq -r '.repository[] | .git_repository as $gi | select($gi != null) | .entry_git[] | [$gi, .commit_sha1_long, .path] | @tsv' \
  < "$data" > "$tmp_tsv"

git_repository_cache="$(mktemp -d)"
while read -r git_repository_entry; do
  {
    echo "Process: '${git_repository_entry}'"
    git_repo_url="$(echo "$git_repository_entry" | awk '{ print $1 }')"
    safe="$(echo "$git_repo_url" | sed -E 's![:+/]!%!g')"
    dist="$git_repository_cache/$safe"
    if [ ! -d "$dist" ]; then
      git clone "$git_repo_url" "$dist";
    fi
    cd "$dist" || die "Could not clone git repository, (processing $git_repo_url)";
    pin_revision="$(echo "$git_repository_entry" | awk '{ print $2 }')"
    relative_path="$(echo "$git_repository_entry" | awk '{ print $3 }')"
    git checkout "$pin_revision" || die "Could not checkout pinned revision $pin_revision (processing $git_repo_url)"
    repo_file="$dist$relative_path"
    if [ ! -f "$repo_file" ]; then
      die "Repository definition file could not be found in $repo_file at $pin_revision (processing $git_repo_url)"
    else
      jq < "$repo_file" || die "Repository definition file was malformed JSON. Please see above information."
    fi
  }
done < "$tmp_tsv"
rm "$tmp_tsv"

# duplicate check by repository URL
count="$(jq -r '[.repository[].entry] | length')"
count_uniq="$(jq -r '[.repository[].entry] | unique | length')"

if [ "$count" != "$count_uniq" ]; then
  die "Duplicated URL(s) are detected. This is not allowed."
fi

# protocol
vpm_repo_json_urls="$(jq -r '[.repository[].entry] | @tsv' < "$data")"

for vpm_repo_json_url in $vpm_repo_json_urls; do
  curl \
    -H "User-Agent: KisaragiEffective/vpm_repository_index_test/1.0" \
    -H "X-Kisaragi-GitHub-Repository: https://github.com/KisaragiEffective/vpm_repository_index" \
    -H "Accept: application/json" \
    -sSL \
    "$vpm_repo_json_url" \
      | jq || die "Repository definition file was malformed JSON (processing $vpm_repo_json_url)"
done
