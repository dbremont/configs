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
#       [skipped under a non-UTF-8 local encoding policy]
#     - Using LF (Unix) line endings only
#
# Local Encoding Policy (.local)
#   A machine-local encoding override may be declared in:
#
#       <hooks dir>/.local
#
#   Format:
#       # Machine-local encoding policy
#       ENCODING=ISO-8859-1
#
#   When present, the declared encoding REPLACES the default UTF-8 policy:
#   only that encoding (plus US-ASCII as a subset) is accepted. Supported
#   values: UTF-8, ISO-8859-1, ISO-8859-15, WINDOWS-1252.
#   LF line endings are always enforced; the BOM check applies only to
#   UTF-8 policies.
#
#   .local is machine-local and MUST NOT be committed: it is git-ignored
#   and this hook rejects any commit that stages it.
#
# Configuration
#   annotations.conf (FILES: text file patterns inspected)
#   .local           (optional ENCODING override; hooks dir; never committed)
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

# --- Local encoding policy (.local, machine-local override) ------------------
LOCAL_POLICY_FILE="$HOOK_DIR/../.local"
LOCAL_ENCODING=""

if [[ -f "$LOCAL_POLICY_FILE" ]]; then
    LOCAL_ENCODING=$(sed -E 's/#.*//' "$LOCAL_POLICY_FILE" \
        | grep -E '^[[:space:]]*ENCODING[[:space:]]*=' \
        | tail -n 1 \
        | sed -E 's/^[[:space:]]*ENCODING[[:space:]]*=[[:space:]]*//; s/[[:space:]]+$//' || true)

    if [[ -z "$LOCAL_ENCODING" ]]; then
        echo -e "${BOLD_RED}Malformed local encoding policy (.local): expected ENCODING=<value>.${NC}"
        exit 1
    fi

    case "$(echo "$LOCAL_ENCODING" | tr '[:lower:]' '[:upper:]')" in
        ISO-8859-1)   ACCEPTED_ENCODINGS=(iso-8859-1 us-ascii) ;;
        ISO-8859-15)  ACCEPTED_ENCODINGS=(iso-8859-15 us-ascii) ;;
        WINDOWS-1252) ACCEPTED_ENCODINGS=(windows-1252 iso-8859-1 us-ascii) ;;
        UTF-8)        ACCEPTED_ENCODINGS=(utf-8 us-ascii) ;;
        *)
            echo -e "${BOLD_RED}Unsupported encoding in .local: ${LOCAL_ENCODING}${NC}"
            echo "Supported values: UTF-8, ISO-8859-1, ISO-8859-15, WINDOWS-1252"
            exit 1
            ;;
    esac
else
    ACCEPTED_ENCODINGS=(utf-8 us-ascii)
fi

# BOM is a UTF-8 concept; skip the check under a non-UTF-8 local policy.
BOM_CHECK=1
if [[ -n "$LOCAL_ENCODING" && "$(echo "$LOCAL_ENCODING" | tr '[:lower:]' '[:upper:]')" != "UTF-8" ]]; then
    BOM_CHECK=0
fi

# Backstop: the local policy file must never be committed.
if git diff --cached --name-only --diff-filter=ACM | grep -Eq '(^|/)\.local$'; then
    echo -e "${BOLD_RED}Commit rejected: .local is machine-local and must not be committed.${NC}"
    echo
    echo -e "Action required:"
    echo -e "  ${YELLOW}git restore --staged .local${NC}"
    echo
    exit 1
fi

STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM -- $FILES)

[[ -z "$STAGED_FILES" ]] && exit 0

if [[ -n "$LOCAL_ENCODING" ]]; then
    echo -e "${YELLOW}Local encoding policy: ${LOCAL_ENCODING} (.local)${NC}"
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
if [[ -n "$LOCAL_ENCODING" ]]; then
    EXPECTED_ENCODING_LABEL="${LOCAL_ENCODING} (local policy)"
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
