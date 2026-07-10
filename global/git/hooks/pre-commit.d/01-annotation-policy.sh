#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Hook: Annotation Policy
# Stage: Pre-commit
#
# Purpose
#   Enforces the repository annotation policy.
#
# Policy
#   Annotations classified as BLOCK must not appear in staged source files.
#
# Configuration
#   annotations.conf
# -----------------------------------------------------------------------------

set -euo pipefail

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HOOK_DIR/../annotations.conf"

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
BOLD_RED='\033[1;31m'
NC='\033[0m'

STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM -- $FILES)

[[ -z "$STAGED_FILES" ]] && exit 0

FAILED=0

check_annotations() {
    local LEVEL="$1"
    local ANNOTATIONS="$2"
    local COLOR="$3"

    [[ -z "$ANNOTATIONS" ]] && return

    local PATTERN
    PATTERN=$(printf "%s\n" $ANNOTATIONS | paste -sd'|' -)

    local MATCHES
    MATCHES=$(grep -HnE "$PATTERN" $STAGED_FILES || true)

    if [[ -n "$MATCHES" ]]; then
        echo -e "${COLOR}${LEVEL}${NC}"
        echo "------------------------------------------------------------"
        echo "$MATCHES"
        echo

        if [[ "$LEVEL" == "BLOCKING ANNOTATIONS" ]]; then
            FAILED=1
        fi
    fi
}

echo
echo "Annotation Policy"
echo "============================================================"
echo

check_annotations "BLOCKING ANNOTATIONS" "$BLOCK" "$BOLD_RED"
check_annotations "WARNINGS"             "$WARN"  "$YELLOW"
check_annotations "INFORMATION"          "$INFO"  "$BLUE"

if [[ $FAILED -eq 1 ]]; then
    echo -e "${BOLD_RED}Commit rejected.${NC}"
    echo "Resolve all blocking annotations before committing."
    exit 1
fi

echo -e "${GREEN}✓ Annotation Policy Passed${NC}"
exit 0