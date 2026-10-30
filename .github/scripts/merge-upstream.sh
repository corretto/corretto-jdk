#!/usr/bin/env bash
#
# Merges an upstream branch into the current branch.
#
# If the full merge conflicts, this script finds the longest prefix of the
# upstream first-parent history that merges cleanly, merges it, and reports
# the commit right after it, which conflicts. Whoever resolves the conflict
# then has to merge only that one commit by hand. A conflict that a later
# upstream commit cancels (for example a backout) is inside the clean prefix,
# so it never needs a manual merge.
#
# Writes these step outputs to $GITHUB_OUTPUT:
#   conflict         true if a conflicting upstream commit was left unmerged
#   conflict_commit  full SHA of that commit (only when conflict=true)

set -euo pipefail

usage="usage: $0 <upstream-remote-url> <upstream-branch> <merge-message>"
UPSTREAM_REMOTE=${1:?${usage}}
UPSTREAM_BRANCH=${2:?${usage}}
MERGE_MESSAGE=${3:?${usage}}

GITHUB_OUTPUT=${GITHUB_OUTPUT:-/dev/null}
GITHUB_STEP_SUMMARY=${GITHUB_STEP_SUMMARY:-/dev/null}

LOCAL_BRANCH=$(git branch --show-current)

git fetch "${UPSTREAM_REMOTE}" "${UPSTREAM_BRANCH}"
UPSTREAM_HEAD=$(git rev-parse FETCH_HEAD)

# Succeeds if merging $1 into HEAD has no conflicts. Does not touch the index
# or work tree.
merges_cleanly() {
  local status=0
  git merge-tree --write-tree HEAD "$1" > /dev/null || status=$?
  case ${status} in
    0) return 0 ;;
    1) return 1 ;;
    *) echo "::error::git merge-tree failed with status ${status} for $1"; exit "${status}" ;;
  esac
}

if merges_cleanly "${UPSTREAM_HEAD}"; then
  git merge -m "${MERGE_MESSAGE}" "${UPSTREAM_HEAD}"
  echo "conflict=false" >> "${GITHUB_OUTPUT}"
  exit 0
fi

# Upstream commits not yet merged, oldest first. --first-parent keeps merge
# commits from upstream stabilization branches as single steps.
mapfile -t commits < <(git rev-list --first-parent --reverse "HEAD..${UPSTREAM_HEAD}")
total=${#commits[@]}

# Scan back from the newest commit for the newest one that merges cleanly. A
# binary search would be faster but can stop at an earlier conflict that a
# later commit cancels. The last commit is UPSTREAM_HEAD, which conflicts, so
# the scan starts one before it. good=-1 stands for HEAD itself: no upstream
# commit merges cleanly.
good=$(( total - 2 ))
while (( good >= 0 )) && ! merges_cleanly "${commits[good]}"; do
  good=$(( good - 1 ))
done
bad=$(( good + 1 ))

merged=$(( good + 1 ))
if (( merged > 0 )); then
  echo "Merging ${merged} of ${total} upstream commits, up to ${commits[good]}"
  git merge -m "${MERGE_MESSAGE}" "${commits[good]}"
fi

conflict_commit=${commits[bad]}
conflict_subject=$(git log -1 --format=%s "${conflict_commit}")
conflict_url="${UPSTREAM_REMOTE%.git}/commit/${conflict_commit}"
remaining=$(( total - merged - 1 ))
# --name-only prints the result tree ID on the first line, then one line per
# conflicted path.
conflicted_files=$(git merge-tree --write-tree --name-only --no-messages HEAD "${conflict_commit}" | tail -n +2 || true)

{
  echo "conflict=true"
  echo "conflict_commit=${conflict_commit}"
} >> "${GITHUB_OUTPUT}"

echo "::error title=Merge conflict with ${UPSTREAM_BRANCH}::Upstream commit ${conflict_commit} (${conflict_subject}) conflicts with ${LOCAL_BRANCH}. See the job summary for how to resolve it."

report=$(cat <<EOF
## Upstream merge conflict

Merged ${merged} of ${total} new commits from \`${UPSTREAM_REMOTE} ${UPSTREAM_BRANCH}\` into \`${LOCAL_BRANCH}\`.
The next commit conflicts and has to be merged by hand:

[\`${conflict_commit:0:12}\`](${conflict_url}) ${conflict_subject}

Conflicted files:

\`\`\`
${conflicted_files}
\`\`\`

To resolve, merge only that commit:

\`\`\`sh
git checkout ${LOCAL_BRANCH}
git pull --ff-only origin ${LOCAL_BRANCH}
git fetch ${UPSTREAM_REMOTE} ${UPSTREAM_BRANCH}
git merge -m "${MERGE_MESSAGE}" ${conflict_commit}
# Fix the conflicts, then:
git add <files>
git commit --no-edit
git push origin ${LOCAL_BRANCH}
\`\`\`
EOF
)
if (( remaining > 0 )); then
  report+=$'\n\n'"Then re-run this workflow to merge the remaining ${remaining} upstream commits."
fi

echo "${report}"
echo "${report}" >> "${GITHUB_STEP_SUMMARY}"
