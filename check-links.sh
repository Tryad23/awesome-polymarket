#!/usr/bin/env bash
# Checks every link in README.md and reports the ones that do not resolve.
# Usage: ./check-links.sh [file]
set -uo pipefail

FILE="${1:-README.md}"
UA='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36'

# Hosts that answer 403 to scripted requests but are fine in a browser.
SOFT_BLOCK='npmjs\.com|dune\.com'

check() {
  local url="$1" code
  code=$(curl -sSL -o /dev/null -w '%{http_code}' -A "$UA" --max-time 25 --retry 1 "$url" 2>/dev/null)
  case "$code" in
    200|301|302|307|308|429) return 0 ;;
    403) [[ "$url" =~ $SOFT_BLOCK ]] && return 0 ;;
  esac
  printf '%s  %s\n' "${code:-000}" "$url"
}
export -f check
export UA SOFT_BLOCK

echo "Checking links in $FILE ..."
grep -o 'https\?://[^)]*' "$FILE" \
  | grep -v 'creativecommons\.org\|mirrors\.creativecommons\.org' \
  | sed 's/[.,]$//' \
  | sort -u \
  > /tmp/awesome-polymarket-urls.$$

total=$(wc -l < /tmp/awesome-polymarket-urls.$$)
bad=$(xargs -P 12 -I{} bash -c 'check "$@"' _ {} < /tmp/awesome-polymarket-urls.$$)
rm -f /tmp/awesome-polymarket-urls.$$

if [ -z "$bad" ]; then
  echo "All $total links resolved."
  exit 0
fi

echo
echo "$total links checked, the following need review:"
echo "$bad"
exit 1
