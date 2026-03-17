#!/usr/bin/env bash

set -euo pipefail

repo_root="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1
  /bin/pwd -P
)"

cd "$repo_root"

git ls-files 'SMPPaymentSampleApp/*.h' 'SMPPaymentSampleApp/*.m' \
  | while IFS= read -r file; do
      xcrun clang-format -i "$file"
    done
