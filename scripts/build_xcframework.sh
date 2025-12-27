#!/bin/bash

# define constants
FRAMEWORK_NAME="ZarliSDKSwift"
OUTPUT_DIR="build"

# clean up previous build
rm -rf $OUTPUT_DIR
mkdir -p $OUTPUT_DIR

echo "🚀 Building for iOS Device..."
xcodebuild archive \
  -scheme $FRAMEWORK_NAME \
  -destination "generic/platform=iOS" \
  -archivePath "$OUTPUT_DIR/ios_devices.xcarchive" \
  -sdk iphoneos \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

echo "🚀 Building for iOS Simulator..."
xcodebuild archive \

  -scheme $FRAMEWORK_NAME \
  -destination "generic/platform=iOS Simulator" \
  -archivePath "$OUTPUT_DIR/ios_simulators.xcarchive" \
  -sdk iphonesimulator \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

# Manually move PrivacyInfo.xcprivacy to root of Framework if it exists in a bundle
# This ensures it looks like a standard binary framework distribution
find "$OUTPUT_DIR" -name "PrivacyInfo.xcprivacy" | while read manifest; do
    framework_dir=$(dirname $(dirname "$manifest"))
    # Check if we are inside a .bundle inside a .framework
    if [[ "$framework_dir" == *.framework ]]; then
        echo "🚚 Moving $manifest to $framework_dir/"
        cp "$manifest" "$framework_dir/"
    fi
done

echo "📦 Creating XCFramework..."
xcodebuild -create-xcframework \
  -framework "$OUTPUT_DIR/ios_devices.xcarchive/Products/Library/Frameworks/$FRAMEWORK_NAME.framework" \
  -framework "$OUTPUT_DIR/ios_simulators.xcarchive/Products/Library/Frameworks/$FRAMEWORK_NAME.framework" \
  -output "$OUTPUT_DIR/$FRAMEWORK_NAME.xcframework"

echo "✅ Build Complete!"
echo "XCFramework is located at: $OUTPUT_DIR/$FRAMEWORK_NAME.xcframework"

# Check for Privacy Manifest
echo "🔍 Checking for Privacy Manifest..."
if [ -f "$OUTPUT_DIR/$FRAMEWORK_NAME.xcframework/ios-arm64/$FRAMEWORK_NAME.framework/PrivacyInfo.xcprivacy" ]; then
    echo "✅ PrivacyInfo.xcprivacy found in iOS Device slice."
else
    echo "⚠️ PrivacyInfo.xcprivacy NOT found in iOS Device slice. Please check 'Copy Bundle Resources' build phase."
fi
