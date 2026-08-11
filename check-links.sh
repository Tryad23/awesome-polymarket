#!/usr/bin/env bash
# Checks every link in README.md.
#
# Exits non-zero only for links that are definitively dead (404, 410, 451).
# Links that merely could not be verified (bot protection, rate limits,
# connection failures from a datacenter IP) are reported as warnings, because
# CI runners get blocked by hosts that work fine in a browser.
#
# Usage: ./check-links.sh [file]
set -uo pipefail

FILE="${1:-README.md}"
UA='Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36'

check() {
  local url="$1" code
  code=$(curl -sSL -o /dev/null -w '%{http_code}' -A "$UA" --max-time 25 --retry 1 "$url" 2>/dev/null)
  # A connection failure can be transient or IP-based. Try once more, HTTP/1.1.
  if [ "$code" = "000" ]; then
    code=$(curl -sSL -o /dev/null -w '%{http_code}' -A "$UA" --http1.1 --max-time 30 "$url" 2>/dev/null)
  fi
  case "$code" in
    2??|3??) return 0 ;;
    404|410|451) printf 'DEAD %s %s\n' "$code" "$url" ;;
    *) printf 'WARN %s %s\n' "${code:-000}" "$url" ;;
  esac
}
export -f check
export UA

urls=$(grep -o 'https\?://[^)]*' "$FILE" \
  | grep -v 'creativecommons\.org' \
  | sed 's/[.,]$//' \
  | sort -u)
total=$(printf '%s\n' "$urls" | wc -l | tr -d ' ')

echo "Checking $total links in $FILE ..."
results=$(printf '%s\n' "$urls" | xargs -P 12 -I{} bash -c 'check "$@"' _ {})

dead=$(printf '%s\n' "$results" | grep '^DEAD' || true)
warn=$(printf '%s\n' "$results" | grep '^WARN' || true)

if [ -n "$warn" ]; then
  echo
  echo "Could not verify (likely bot protection or rate limiting, check by hand):"
  printf '%s\n' "$warn" | sed 's/^WARN /  /'
fi

if [ -n "$dead" ]; then
  echo
  echo "Dead links, these must be fixed or removed:"
  printf '%s\n' "$dead" | sed 's/^DEAD /  /'
  exit 1
fi

echo
echo "No dead links."
