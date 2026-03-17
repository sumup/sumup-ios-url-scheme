#!/usr/bin/env bash

set -euo pipefail

repo_root="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1
  /bin/pwd -P
)"

cd "$repo_root"

tmp_dir="$(mktemp -d /tmp/sumup-clang-format-check.XXXXXX)"
trap 'rm -rf "$tmp_dir"' EXIT

status=0

while IFS= read -r file; do
  tmp_file="$tmp_dir/$(basename "$file")"
  xcrun clang-format "$file" >"$tmp_file"
  if ! cmp -s "$file" "$tmp_file"; then
    echo "Formatting mismatch: $file" >&2
    status=1
  fi
done < <(git ls-files 'SMPPaymentSampleApp/*.h' 'SMPPaymentSampleApp/*.m')

exit "$status"
