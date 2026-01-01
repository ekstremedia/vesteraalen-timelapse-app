#!/bin/bash
AVD_NAME="${1:-Pixel_9_Pro}"
~/Android/Sdk/emulator/emulator -avd "$AVD_NAME" -feature -Vulkan
