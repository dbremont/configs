#!/usr/bin/env bash
#
# -----------------------------------------------------------------------------
# Hook: Encoding Policy
# Stage: Pre-commit
#
# Purpose
#   Enforces text file encoding and line ending standards.
#
# Policy
#   Every staged text file must be:
#     - UTF-8 encoded (US-ASCII is accepted as a subset of UTF-8)
#     - Free of a UTF-8 byte-order mark (BOM)
#     - Using LF (Unix) line endings only
#
# Configuration
#   annotations.conf (FILES: text file patterns inspected)
#
# Resolution
#   Encoding : iconv -f <encoding> -t UTF-8 <file>
#   CRLF     : dos2unix <file>   (or: sed -i 's/\r$//' <file>)
#   BOM      : sed -i '1s/^\xEF\xBB\xBF//' <file>
#
# Exit Codes
#   0  All staged text files satisfy the policy.
#   1  One or more staged text files violate the policy.
# -----------------------------------------------------------------------------

set -euo pipefail

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HOOK_DIR/../annotations.conf"

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BOLD_RED='\033[1;31m'
NC='\033[0m'

STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM -- $FILES)

[[ -z "$STAGED_FILES" ]] && exit 0

BAD_ENCODING_FILES=()
BOM_FILES=()
CRLF_FILES=()

for file in $STAGED_FILES; do
    if [[ ! -f "$file" ]]; then
        echo -e "${YELLOW}⚠ Warning: Skipped (not in working tree): $file${NC}"
        continue
    fi

    # Encoding check (binary files are out of scope for this policy)
    ENCODING=$(file --mime-encoding -b "$file")
    if [[ "$ENCODING" != "utf-8" && "$ENCODING" != "us-ascii" ]]; then
        if [[ "$ENCODING" == "binary" ]]; then
            continue
        fi
        BAD_ENCODING_FILES+=("$file|$ENCODING")
    fi

    # BOM check (first three bytes must not be EF BB BF)
    HEADER=$(od -An -tx1 -N3 "$file" | tr -d ' \n')
    if [[ "$HEADER" == "efbbbf" ]]; then
        BOM_FILES+=("$file")
    fi

    # Line ending check (any carriage return means non-LF endings)
    if grep -q $'\r' "$file"; then
        CRLF_FILES+=("$file")
    fi
done

FAILED=0

if [[ ${#BAD_ENCODING_FILES[@]} -gt 0 ]]; then
    FAILED=1
    echo -e "${BOLD_RED}Invalid encoding (expected UTF-8):${NC}"
    echo "------------------------------------------------------------"
    for entry in "${BAD_ENCODING_FILES[@]}"; do
        echo -e "  - ${RED}${entry%%|*} (detected: ${entry##*|})${NC}"
    done
    echo
fi

if [[ ${#BOM_FILES[@]} -gt 0 ]]; then
    FAILED=1
    echo -e "${BOLD_RED}UTF-8 BOM detected:${NC}"
    echo "------------------------------------------------------------"
    for f in "${BOM_FILES[@]}"; do
        echo -e "  - ${RED}${f}${NC}"
    done
    echo
fi

if [[ ${#CRLF_FILES[@]} -gt 0 ]]; then
    FAILED=1
    echo -e "${BOLD_RED}CRLF line endings (expected LF):${NC}"
    echo "------------------------------------------------------------"
    for f in "${CRLF_FILES[@]}"; do
        echo -e "  - ${RED}${f}${NC}"
    done
    echo
fi

if [[ $FAILED -eq 1 ]]; then
    echo -e "${BOLD_RED}Commit rejected.${NC}"
    echo "Action required:"
    echo -e "  ${YELLOW}iconv -f <encoding> -t UTF-8 <file>${NC}      # fix encoding"
    echo -e "  ${YELLOW}dos2unix <file>${NC}                          # fix CRLF line endings"
    echo -e "  ${YELLOW}sed -i '1s/^\\xEF\\xBB\\xBF//' <file>${NC}       # strip BOM"
    echo
    exit 1
fi

echo -e "${GREEN}✓ Encoding Policy Passed${NC}"
exit 0
