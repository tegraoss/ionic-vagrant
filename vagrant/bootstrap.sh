#!/bin/bash
# Ubuntu Developer Script For Ionic Framework
# Created by Nic Raboy
# http://www.nraboy.com
#
#
# Downloads and configures the following:
#
#   Java JDK
#   Apache Ant
#   Android
#   NPM
#   Apache Cordova
#   Ionic Framework
#   Gradle

INSTALL_PATH=/opt
ANDROID_SDK_PATH=/opt/android-sdk
NODE_PATH=/opt/node
GRADLE_PATH=/opt/gradle

ANDROID_SDK_X86="http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz"
NODE_X86="https://nodejs.org/download/release/v4.2.4/node-v4.2.4-linux-x86.tar.gz"
GRADLE_ALL="https://services.gradle.org/distributions/gradle-2.9-all.zip"
PLATFORM_TOOLS="https://dl-ssl.google.com/android/repository/platform-tools_r23.0.1-linux.zip"
RULES_FILE="https://raw.githubusercontent.com/M0Rf30/android-udev-rules/master/ubuntu/51-android.rules"

# Update all Ubuntu software repository lists
apt-get update
apt-get upgrade -y
apt-get -y install default-jdk ant unzip

cd /tmp

echo "Configure android rules"
curl "$RULES_FILE" > "/etc/udev/rules.d/51-android.rules"
chmod a+r /etc/udev/rules.d/51-android.rules

echo "Downloading dependencies"
wget -q -c "$NODE_X86" -O "nodejs.tgz" --no-check-certificate
wget -q -c "$ANDROID_SDK_X86" -O "android-sdk.tgz" --no-check-certificate
wget -q -c "$GRADLE_ALL" -O "gradle.zip" --no-check-certificate
wget -q -c "$PLATFORM_TOOLS" -O "platform_tools.zip" --no-check-certificate

tar zxf "nodejs.tgz" -C "$INSTALL_PATH"
tar zxf "android-sdk.tgz" -C "$INSTALL_PATH"
unzip "gradle.zip"
mv "gradle-2.9" "$INSTALL_PATH"
unzip "platform_tools.zip"

mv "$INSTALL_PATH/android-sdk-linux" "$INSTALL_PATH/android-sdk"
mv "platform-tools" "$INSTALL_PATH/android-sdk"
mv "$INSTALL_PATH/node-v4.2.4-linux-x86" "$INSTALL_PATH/node"
mv "$INSTALL_PATH/gradle-2.9" "$INSTALL_PATH/gradle"

# Add Android and NPM paths to the profile to preserve settings on boot
echo "export PATH=\$PATH:$ANDROID_SDK_PATH/tools" >> "/etc/profile"
echo "export PATH=\$PATH:$ANDROID_SDK_PATH/platform-tools" >> "/etc/profile"
echo "export PATH=\$PATH:$NODE_PATH/bin" >> "/etc/profile"
echo "export PATH=\$PATH:$GRADLE_PATH/bin" >> "/etc/profile"

# Add Android and NPM paths to the temporary user path to complete installation
export PATH=$PATH:$ANDROID_SDK_PATH/tools
export PATH=$PATH:$ANDROID_SDK_PATH/platform-tools
export PATH=$PATH:$NODE_PATH/bin
export PATH=$PATH:$GRADLE_PATH/bin

# Set JAVA_HOME based on the default OpenJDK installed
export JAVA_HOME="$(find /usr -type l -name 'default-java')"
if [ "$JAVA_HOME" != "" ]; then
    echo "export JAVA_HOME=$JAVA_HOME" >> "/etc/profile"
fi

# Install Apache Cordova and Ionic Framework
npm install -g cordova
npm install -g ionic

#Build tools
echo y | $ANDROID_SDK_PATH/tools/android update sdk --all --filter android-22,build-tools-22.0.1 --no-ui

#Permissions
chown root:root "$INSTALL_PATH/android-sdk" -R
chmod 777 "$INSTALL_PATH/android-sdk" -R
chmod 777 "$INSTALL_PATH/node" -R
chmod 777 "$INSTALL_PATH/gradle" -R

# Clean up any files that were downloaded from the internet
rm "/tmp/android-sdk.tgz"
rm "/tmp/nodejs.tgz"
rm "/tmp/gradle.zip"
rm "/tmp/platform_tools.zip"
