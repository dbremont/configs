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
#     - Encoded per the active encoding policy (default: UTF-8;
#       US-ASCII is accepted as a subset of the policy encoding)
#     - Free of a UTF-8 byte-order mark (BOM)
#       [skipped under a non-UTF-8 repository encoding policy]
#     - Using LF (Unix) line endings only
#
# Per-Repository Configuration (hooks.encoding)
#   Each repository may declare its own encoding policy in its local git
#   config, i.e. the .git/config of the repo in which the git command is
#   executed:
#
#       git config --local hooks.encoding ISO-8859-1
#
#   When present, the declared encoding REPLACES the default UTF-8 policy:
#   only that encoding (plus US-ASCII as a subset) is accepted. Supported
#   values: UTF-8, ISO-8859-1, ISO-8859-15, WINDOWS-1252.
#   LF line endings are always enforced; the BOM check applies only to
#   UTF-8 policies.
#
#   Only the repository-local config (.git/config) is honored; global
#   (~/.gitconfig) and system config are intentionally ignored. Repos
#   without this key are held to the default UTF-8 policy.
#
# Configuration
#   annotations.conf (FILES: text file patterns inspected)
#   hooks.encoding   (optional per-repo encoding override; .git/config)
#
# Resolution
#   Encoding : iconv -f <encoding> -t <policy encoding> <file>
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

# --- Per-repository encoding policy (hooks.encoding, .git/config) ------------
POLICY_ENCODING="$(git config --local --get hooks.encoding || true)"

if [[ -n "$POLICY_ENCODING" ]]; then
    case "$(echo "$POLICY_ENCODING" | tr '[:lower:]' '[:upper:]')" in
        ISO-8859-1)   ACCEPTED_ENCODINGS=(iso-8859-1 us-ascii) ;;
        ISO-8859-15)  ACCEPTED_ENCODINGS=(iso-8859-15 us-ascii) ;;
        WINDOWS-1252) ACCEPTED_ENCODINGS=(windows-1252 iso-8859-1 us-ascii) ;;
        UTF-8)        ACCEPTED_ENCODINGS=(utf-8 us-ascii) ;;
        *)
            echo -e "${BOLD_RED}Unsupported hooks.encoding in repository config: ${POLICY_ENCODING}${NC}"
            echo "Supported values: UTF-8, ISO-8859-1, ISO-8859-15, WINDOWS-1252"
            exit 1
            ;;
    esac
else
    ACCEPTED_ENCODINGS=(utf-8 us-ascii)
fi

# BOM is a UTF-8 concept; skip the check under a non-UTF-8 policy.
BOM_CHECK=1
if [[ -n "$POLICY_ENCODING" && "$(echo "$POLICY_ENCODING" | tr '[:lower:]' '[:upper:]')" != "UTF-8" ]]; then
    BOM_CHECK=0
fi

STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM -- $FILES)

[[ -z "$STAGED_FILES" ]] && exit 0

if [[ -n "$POLICY_ENCODING" ]]; then
    echo -e "${YELLOW}Repository encoding policy: ${POLICY_ENCODING} (hooks.encoding)${NC}"
    echo
fi

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
    if [[ "$ENCODING" == "binary" ]]; then
        continue
    fi
    ACCEPTED_REGEX=$(IFS='|'; echo "${ACCEPTED_ENCODINGS[*]}")
    if [[ ! "$ENCODING" =~ ^($ACCEPTED_REGEX)$ ]]; then
        BAD_ENCODING_FILES+=("$file|$ENCODING")
    fi

    # BOM check (first three bytes must not be EF BB BF)
    if [[ $BOM_CHECK -eq 1 ]]; then
        HEADER=$(od -An -tx1 -N3 "$file" | tr -d ' \n')
        if [[ "$HEADER" == "efbbbf" ]]; then
            BOM_FILES+=("$file")
        fi
    fi

    # Line ending check (any carriage return means non-LF endings)
    if grep -q $'\r' "$file"; then
        CRLF_FILES+=("$file")
    fi
done

FAILED=0

EXPECTED_ENCODING_LABEL="UTF-8"
if [[ -n "$POLICY_ENCODING" ]]; then
    EXPECTED_ENCODING_LABEL="${POLICY_ENCODING} (hooks.encoding)"
fi

if [[ ${#BAD_ENCODING_FILES[@]} -gt 0 ]]; then
    FAILED=1
    echo -e "${BOLD_RED}Invalid encoding (expected ${EXPECTED_ENCODING_LABEL}):${NC}"
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
    echo -e "  ${YELLOW}iconv -f <encoding> -t <policy encoding> <file>${NC}   # fix encoding"
    echo -e "  ${YELLOW}dos2unix <file>${NC}                                   # fix CRLF line endings"
    echo -e "  ${YELLOW}sed -i '1s/^\\xEF\\xBB\\xBF//' <file>${NC}                # strip BOM"
    echo
    exit 1
fi

echo -e "${GREEN}✓ Encoding Policy Passed${NC}"
exit 0
