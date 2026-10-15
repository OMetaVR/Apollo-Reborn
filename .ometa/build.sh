#!/usr/bin/env bash
# Same as upstream's release-ipa-variants.yml: rootful + rootless .debs and the six IPA variants.
source "$PIPELINE/lib/helpers.sh"

sudo xcode-select -s /Applications/Xcode_26.0.1.app
setup_theos "" 9bc73406cf80b711ef4d02c15ff1dedc4478a275   # upstream's pinned Theos

log "Rootful .deb"
make package FINALPACKAGE=1
ROOTFUL=$(ls -1t packages/*.deb | head -1)
cp "$ROOTFUL" "$OUT/"
ROOTFUL="$OUT/$(basename "$ROOTFUL")"

log "Rootless .deb"
make clean
make package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=rootless
ROOTLESS=$(ls packages/*-arm64.deb 2>/dev/null || ls packages/*_iphoneos-arm64.deb | head -1)
cp "$ROOTLESS" "$OUT/$(basename "${ROOTLESS%.deb}")_rootless.deb"

install_cyan refs/tags/v1.4.4
brew install xcodegen

log "IPA variants"
bash ./scripts/build_release_variants.sh --ipa "$BASE_IPA" --deb "$ROOTFUL" --output-dir "$RUNNER_TEMP/variants"
bash ./scripts/validate_release_variants.sh "$RUNNER_TEMP/variants"
cp "$RUNNER_TEMP"/variants/*.ipa "$OUT/"
