#!/usr/bin/env bash
# build.sh — 构建 MinimizeAll
#   ./build.sh                # Release 构建（默认）
#   ./build.sh debug          # Debug 构建
#   ./build.sh clean          # 清理产物
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

MODE="${1:-release}"

case "$MODE" in
  release)
    echo "▶ swift build -c release"
    swift build -c release
    ;;
  debug)
    echo "▶ swift build"
    swift build
    ;;
  clean)
    echo "▶ swift package clean + rm -rf .build"
    swift package clean 2>/dev/null || true
    rm -rf .build
    ;;
  *)
    echo "用法: $0 [release|debug|clean]" >&2
    exit 1
    ;;
esac

echo "✓ 构建完成"
