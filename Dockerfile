# 影视TV (FongMi/TV) Android 构建环境镜像
#
# 用途：在容器内提供完整、可复现的 APK 构建工具链，
#       免去在本地逐一安装 JDK / Android SDK / Python 的麻烦。
# 说明：本项目 Release 构建还需要未入库的配套 AAR（app/libs/lib-*.aar）
#       以及签名用的 local.properties，请挂载到工作区后使用（见 build-apk.sh）。
#
# 基础镜像：Ubuntu 22.04（自带 Python 3.10，满足 Chaquopy buildPython 要求）
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64 \
    ANDROID_HOME=/opt/android-sdk \
    ANDROID_SDK_ROOT=/opt/android-sdk \
    ANDROID_CMDLINE_TOOLS=/opt/android-sdk/cmdline-tools/latest \
    GRADLE_USER_HOME=/root/.gradle \
    PATH=/opt/android-sdk/cmdline-tools/latest/bin:/opt/android-sdk/platform-tools:/usr/lib/jvm/java-21-openjdk-amd64/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# 1) 系统依赖：JDK 21 + Python 3.10 + 构建工具
RUN apt-get update && apt-get install -y --no-install-recommends \
        openjdk-21-jdk-headless \
        python3 \
        python3-venv \
        python3-dev \
        python3-pip \
        unzip \
        curl \
        wget \
        git \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && update-alternatives --set java /usr/lib/jvm/java-21-openjdk-amd64/bin/java

# 2) Android command-line tools
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools \
    && wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O /tmp/cmdline-tools.zip \
    && unzip -q /tmp/cmdline-tools.zip -d ${ANDROID_HOME}/cmdline-tools \
    && mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest \
    && rm -f /tmp/cmdline-tools.zip

# 3) 接受许可并安装编译所需的 SDK 组件
#    compileSdk/targetSdk = 37，AGP 9.3.1 需要 build-tools >= 35.0.0
RUN yes | sdkmanager --sdk_root=${ANDROID_HOME} --licenses > /dev/null \
    && sdkmanager --sdk_root=${ANDROID_HOME} \
        "platform-tools" \
        "platforms;android-37" \
        "build-tools;35.0.0"

# 4) 构建辅助脚本（在挂载的源码目录内执行 gradle 打包）
COPY docker/build-apk.sh /usr/local/bin/build-apk.sh
RUN chmod +x /usr/local/bin/build-apk.sh

WORKDIR /project

CMD ["build-apk.sh"]
