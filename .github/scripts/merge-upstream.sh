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
# <upstream-remote> is a URL or the name of a configured remote.
#
# --keep-ours <path> keeps the current branch's copy of <path> in every merge,
# whether the merge changed it, conflicted on it, or left it alone. A conflict
# in a kept path does not count as a conflict. The option can be repeated.
# With it, every merge creates a merge commit, because a fast-forward cannot
# keep a path.
#
# Writes these step outputs to $GITHUB_OUTPUT:
#   conflict         true if a conflicting upstream commit was left unmerged
#   conflict_commit  full SHA of that commit (only when conflict=true)

set -euo pipefail

usage="usage: $0 [--keep-ours <path>]... <upstream-remote> <upstream-branch> <merge-message>"
KEEP_PATHS=()
while [[ ${1:-} == --keep-ours ]]; do
  KEEP_PATHS+=("${2:?${usage}}")
  shift 2
done
UPSTREAM_REMOTE=${1:?${usage}}
UPSTREAM_BRANCH=${2:?${usage}}
MERGE_MESSAGE=${3:?${usage}}

GITHUB_OUTPUT=${GITHUB_OUTPUT:-/dev/null}
GITHUB_STEP_SUMMARY=${GITHUB_STEP_SUMMARY:-/dev/null}

LOCAL_BRANCH=$(git branch --show-current)

git fetch "${UPSTREAM_REMOTE}" "${UPSTREAM_BRANCH}"
UPSTREAM_HEAD=$(git rev-parse FETCH_HEAD)

# Succeeds if $1 is a kept path.
is_kept() {
  local kept
  for kept in "${KEEP_PATHS[@]}"; do
    if [[ $1 == "${kept}" ]]; then
      return 0
    fi
  done
  return 1
}

# Succeeds if merging $1 into HEAD has no conflicts outside the kept paths.
# Sets the conflicts array to the paths that do conflict. Does not touch the
# index or work tree.
merges_cleanly() {
  local status=0 output path
  conflicts=()
  output=$(git merge-tree --write-tree --name-only --no-messages HEAD "$1") || status=$?
  case ${status} in
    0) return 0 ;;
    1) ;;
    *) echo "::error::git merge-tree failed with status ${status} for $1"; exit "${status}" ;;
  esac
  # The first line is the result tree ID, then one line per conflicted path.
  while IFS= read -r path; do
    if [[ -n ${path} ]] && ! is_kept "${path}"; then
      conflicts+=("${path}")
    fi
  done < <(tail -n +2 <<< "${output}")
  (( ${#conflicts[@]} == 0 ))
}

# Merges $1 into HEAD. Call it only after merges_cleanly "$1" succeeds.
merge_commit() {
  if (( ${#KEEP_PATHS[@]} == 0 )); then
    git merge -m "${MERGE_MESSAGE}" "$1"
    return
  fi
  # A conflict in a kept path stops the merge with a nonzero status, so check
  # for a merge in progress instead of trusting the status.
  local status=0 unmerged
  git merge --no-ff --no-commit "$1" || status=$?
  if ! git rev-parse -q --verify MERGE_HEAD > /dev/null; then
    # Nothing to commit: either $1 is already merged or git merge failed.
    if (( status == 0 )); then
      return 0
    fi
    echo "::error::git merge failed with status ${status} for $1"
    exit "${status}"
  fi
  git restore --source=HEAD --staged --worktree -- "${KEEP_PATHS[@]}"
  unmerged=$(git diff --name-only --diff-filter=U)
  if [[ -n ${unmerged} ]]; then
    echo "::error::Unexpected merge conflicts with $1:"$'\n'"${unmerged}"
    exit 1
  fi
  git commit -m "${MERGE_MESSAGE}"
}

if merges_cleanly "${UPSTREAM_HEAD}"; then
  merge_commit "${UPSTREAM_HEAD}"
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
  merge_commit "${commits[good]}"
fi

conflict_commit=${commits[bad]}
conflict_subject=$(git log -1 --format=%s "${conflict_commit}")
# Link to the commit on the upstream host, resolving a remote name to its URL.
upstream_url=$(git remote get-url "${UPSTREAM_REMOTE}" 2> /dev/null || echo "${UPSTREAM_REMOTE}")
conflict_url="${upstream_url%.git}/commit/${conflict_commit}"
remaining=$(( total - merged - 1 ))
merges_cleanly "${conflict_commit}" || true
conflicted_files=$(printf '%s\n' "${conflicts[@]}")
resolve_branch="merge-upstream-${conflict_commit:0:12}"
# GITHUB_SERVER_URL and GITHUB_REPOSITORY are set by GitHub Actions.
compare_url="${GITHUB_SERVER_URL:-https://github.com}/${GITHUB_REPOSITORY:-<owner>/<repo>}/compare/${LOCAL_BRANCH}...${resolve_branch}?expand=1"

kept_note=""
keep_step=""
if (( ${#KEEP_PATHS[@]} > 0 )); then
  printf -v kept_args ' %q' "${KEEP_PATHS[@]}"
  kept_note=$'\n\n'"Not listed:${kept_args}, where the \`${LOCAL_BRANCH}\` copy is always kept."
  keep_step="# Keep the ${LOCAL_BRANCH} copy of${kept_args}:"$'\n'"git restore --source=HEAD --staged --worktree --${kept_args}"$'\n'
fi

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
\`\`\`${kept_note}

To resolve, merge only that commit on a new branch:

\`\`\`sh
git fetch origin ${LOCAL_BRANCH}
git checkout -b ${resolve_branch} origin/${LOCAL_BRANCH}
git fetch ${UPSTREAM_REMOTE} ${UPSTREAM_BRANCH}
git merge -m "${MERGE_MESSAGE}" ${conflict_commit}
${keep_step}# Fix the conflicts, then:
git add <files>
git commit --no-edit
git push origin ${resolve_branch}
\`\`\`

Then [open a pull request](${compare_url}) into \`${LOCAL_BRANCH}\` for review.
Merge it with **Create a merge commit**. Squash or rebase would drop the
upstream commit from the history of \`${LOCAL_BRANCH}\`, so later runs would
treat it as unmerged.
EOF
)
if (( remaining > 0 )); then
  report+=$'\n\n'"After the pull request is merged, re-run this workflow to merge the remaining ${remaining} upstream commits."
fi

echo "${report}"
echo "${report}" >> "${GITHUB_STEP_SUMMARY}"
