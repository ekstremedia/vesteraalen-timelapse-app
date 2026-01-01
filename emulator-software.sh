#!/bin/bash
AVD_NAME="${1:-Pixel_9_Pro}"
~/Android/Sdk/emulator/emulator -avd "$AVD_NAME" -gpu swiftshader_indirect -no-snapshot -no-audio -no-boot-anim
