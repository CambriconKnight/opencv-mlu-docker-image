#!/bin/bash
set -e
# -------------------------------------------------------------------------------
# Filename:    test.sh
# Revision:    1.0.0
# Date:        2022/02/18
# Description: test
# Example:
# Depends:
# Notes:
# -------------------------------------------------------------------------------
#test
# 1. apt-get install libgtk2.0-dev pkg-config
# 2. rebuild opencv
./dnn_test --gtest_filter=*MLU*
