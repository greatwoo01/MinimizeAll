#!/usr/bin/env bash
# package.sh — 打包成 .app 并做 ad-hoc 签名
#   ./package.sh    # 生成 dist/MinimizeAll.app
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

./build.sh release

APP_NAME="MinimizeAll"
APP_DIR="dist/${APP_NAME}.app"
BIN=".build/release/${APP_NAME}"

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

cp "$BIN" "$APP_DIR/Contents/MacOS/$APP_NAME"
chmod +x "$APP_DIR/Contents/MacOS/$APP_NAME"

cp Info.plist "$APP_DIR/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleExecutable $APP_NAME" "$APP_DIR/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.greatwoo01.${APP_NAME}" "$APP_DIR/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleName $APP_NAME" "$APP_DIR/Contents/Info.plist"

# ad-hoc 签名（本机运行够用；分发给他人需 Developer ID + notarize）
codesign --force --deep --sign - "$APP_DIR"

echo "✓ 已打包: $APP_DIR"
echo "  本机运行: open $APP_DIR"
