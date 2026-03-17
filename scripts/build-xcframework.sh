#!/usr/bin/env bash

set -euo pipefail

repo_root="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1
  /bin/pwd -P
)"

source_framework="$repo_root/SMPPayment.framework"
output_xcframework="${1:-$repo_root/SMPPayment.xcframework}"
work_dir="$(mktemp -d /tmp/smp-xcframework.XXXXXX)"
trap 'rm -rf "$work_dir"' EXIT

cat <<'EOF'
Building a legacy XCFramework wrapper around SMPPayment.framework.
Note: the bundled binary does not include an arm64 simulator slice, so the
generated XCFramework supports device builds and x86_64 simulator builds only.
Prefer the source-based Swift Package target for modern integrations.
EOF

create_framework_layout() {
  local destination="$1"

  mkdir -p "$destination/Headers" "$destination/Modules"
  cp "$source_framework/Versions/A/Headers/"*.h "$destination/Headers/"
  cat >"$destination/Headers/SMPPayment.h" <<'EOF'
#import <Foundation/Foundation.h>
#import "SMPPaymentRequest.h"
#import "SMPSkipScreenOptions.h"
EOF
  cat >"$destination/Modules/module.modulemap" <<'EOF'
framework module SMPPayment {
  umbrella header "SMPPayment.h"
  export *
  module * { export * }
}
EOF
  cat >"$destination/Info.plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>SMPPayment</string>
  <key>CFBundleIdentifier</key>
  <string>com.sumup.SMPPayment</string>
  <key>CFBundleName</key>
  <string>SMPPayment</string>
  <key>CFBundlePackageType</key>
  <string>FMWK</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
</dict>
</plist>
EOF
}

ios_framework="$work_dir/ios/SMPPayment.framework"
sim_framework="$work_dir/sim/SMPPayment.framework"

create_framework_layout "$ios_framework"
create_framework_layout "$sim_framework"

lipo "$source_framework/SMPPayment" -extract armv7 -extract arm64 -output "$ios_framework/SMPPayment"
lipo "$source_framework/SMPPayment" -extract x86_64 -output "$sim_framework/SMPPayment"

rm -rf "$output_xcframework"
xcodebuild -create-xcframework \
  -framework "$ios_framework" \
  -framework "$sim_framework" \
  -output "$output_xcframework"

echo "Created $output_xcframework"
