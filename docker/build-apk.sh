#!/usr/bin/env bash
#
# 在容器内构建 影视TV APK。
# 用法（宿主机）：
#   docker run --rm -v "$PWD":/project -w /project totootao/tv-build build-apk.sh [leanback|mobile]
#
# 前置条件（需自行提供，未纳入 Git）：
#   1) app/libs/lib-*.aar   配套播放器依赖
#   2) 仓库根目录 local.properties，包含：
#        sdk.dir=<Android SDK 路径，容器内为 /opt/android-sdk>
#        storeFile=<keystore 绝对路径>
#        keyAlias=<别名>
#        storePassword=<密码>
set -euo pipefail

FLAVOR="${1:-leanback}"

echo "==> 使用 JAVA_HOME=${JAVA_HOME}"
echo "==> 使用 ANDROID_HOME=${ANDROID_HOME}"
java -version 2>&1 | head -1
sdkmanager --version 2>/dev/null || true

echo "==> 开始构建 ${FLAVOR} Release APK"
./gradlew --no-daemon ":app:assemble${FLAVOR^}Release"

echo "==> 构建完成，产物位于 Release/apk/"
ls -R Release/apk 2>/dev/null || true
