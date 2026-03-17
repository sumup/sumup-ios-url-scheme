#!/usr/bin/env bash

set -euo pipefail

repo_root="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1
  /bin/pwd -P
)"
cd "$repo_root"

assert_contains() {
  local file="$1"
  local pattern="$2"

  if ! rg --fixed-strings --quiet "$pattern" "$file"; then
    echo "Expected to find '$pattern' in $file" >&2
    exit 1
  fi
}

readme="README.md"
header="SMPPayment.framework/Versions/A/Headers/SMPPaymentRequest.h"
source_header="Sources/SMPPayment/include/SMPPaymentRequest.h"
binary="SMPPayment.framework/SMPPayment"

assert_contains "$readme" 'sumupmerchant://pay/1.0'
assert_contains "$readme" '`affiliate-key`'
assert_contains "$readme" '`callbacksuccess`'
assert_contains "$readme" '`callbackfail`'
assert_contains "$readme" '`foreign-tx-id`'
assert_contains "$readme" '`skip-screen-success`'
assert_contains "$readme" '`smp-status`'
assert_contains "$readme" '`smp-tx-code`'

assert_contains "$header" 'SMPPaymentRequestKeyStatus'
assert_contains "$header" 'SMPPaymentRequestKeyTransactionCode'
assert_contains "$header" 'SMPPaymentRequestKeyForeignTransactionID'
assert_contains "$header" 'paymentRequestWithAmount:'
assert_contains "$header" 'canOpenSumUpMerchantApp'
assert_contains "$header" 'showSumUpMerchantInAppStore'
assert_contains "$header" 'openSumUpMerchantApp'
assert_contains "$header" 'urlToLaunchSumupMerchantApp'

assert_contains "$source_header" 'SMPPaymentRequestKeyStatus'
assert_contains "$source_header" 'SMPPaymentRequestKeyTransactionCode'
assert_contains "$source_header" 'SMPPaymentRequestKeyForeignTransactionID'
assert_contains "$source_header" 'paymentRequestWithAmount:'
assert_contains "$source_header" 'canOpenSumUpMerchantApp'
assert_contains "$source_header" 'showSumUpMerchantInAppStore'
assert_contains "$source_header" 'openSumUpMerchantApp'
assert_contains "$source_header" 'urlToLaunchSumupMerchantApp'

nm_output="$(mktemp)"
trap 'rm -f "$nm_output"' EXIT
nm -gU "$binary" >"$nm_output"

assert_contains "$nm_output" '_OBJC_CLASS_$_SMPPaymentRequest'
assert_contains "$nm_output" '_SMPPaymentRequestKeyStatus'
assert_contains "$nm_output" '_SMPPaymentRequestKeyTransactionCode'
assert_contains "$nm_output" '_SMPPaymentRequestKeyForeignTransactionID'

echo "Compatibility contract checks passed."
