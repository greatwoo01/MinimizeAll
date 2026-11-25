#!/usr/bin/env bash
# run.sh — 构建并运行 MinimizeAll（菜单栏常驻）
#   ./run.sh          # release
#   ./run.sh debug    # debug
#   ./run.sh build    # 只构建不运行
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

MODE="${1:-release}"

case "$MODE" in
  release)   CONFIG="release" ;;
  debug)     CONFIG="debug" ;;
  build)     ./build.sh release; exit 0 ;;
  *)
    echo "用法: $0 [release|debug|build]" >&2
    exit 1
    ;;
esac

BIN=".build/$CONFIG/MinimizeAll"

if [ ! -x "$BIN" ]; then
  echo "⚠ 未找到 $BIN，先构建…"
  ./build.sh "$CONFIG"
fi

echo "▶ 启动 MinimizeAll ($CONFIG)"
"$BIN"
