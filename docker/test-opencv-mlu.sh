#!/bin/bash
set -e
# -------------------------------------------------------------------------------
# Filename:     test-opencv-mlu.sh
# UpdateDate:   2022/02/08
# Description:  Test OpenCV-MLU.
# Example:      ./test-opencv-mlu.sh
# Depends:
#               Driver(ftp://username@download.cambricon.com:8821/product/GJD/MLU270/1.7.604/Ubuntu16.04/Driver/neuware-mlu270-driver-dkms_4.9.8_all.deb)
#               CNToolkit(ftp://username@download.cambricon.com:8821/product/GJD/MLU270/1.7.604/Ubuntu16.04/CNToolkit/cntoolkit_1.7.5-1.ubuntu16.04_amd64.deb)
#               CNCV(ftp://username@download.cambricon.com:8821/product/GJD/MLU270/1.7.604/Ubuntu16.04/CNCV/cncv_0.4.602-1.ubuntu16.04_amd64.deb)
#               FFmpeg-MLU(https://github.com/Cambricon/ffmpeg-mlu)
#               FFmpeg(https://gitee.com/mirrors/ffmpeg.git -b release/4.2 --depth=1)
#               EasyDK(https://github.com/Cambricon/easydk)
#               OpenCV-MLU-PATCH(https://github.com/Cambricon/opencv-mlu)
#               OpenCV-4.5.3(https://github.com/opencv/opencv/tree/4.5.3)
#               OpenCV-Extra(https://github.com/opencv/opencv_extra)
# Notes:
# -------------------------------------------------------------------------------
WORK_DIR="/root/opencv-mlu"
DIR_PATCH_OPENCV_EXTRA="opencv_extra-4.5.3"
FILENAME_PATCH_OPENCV_EXTRA="$DIR_PATCH_OPENCV_EXTRA.tar.gz"
#############################################################
# 4.Test OpenCV-MLU
## 4.1. Download opencv_extra
cd $WORK_DIR
PATH_WORK_TMP="opencv_extra"
if [ ! -f "${FILENAME_PATCH_OPENCV_EXTRA}" ];then
    #git clone https://github.com/opencv/opencv_extra
    #下载opencv_extra 4.5.3版本
    wget -O $FILENAME_PATCH_OPENCV_EXTRA https://github.com/opencv/opencv_extra/archive/refs/tags/4.5.3.tar.gz
else
    echo "File(${FILENAME_PATCH_OPENCV_EXTRA}): Exists!"
    tar zxvf $FILENAME_PATCH_OPENCV_EXTRA
    if [ -d "${PATH_WORK_TMP}" ];then rm -rvf $PATH_WORK_TMP; fi
    mv $DIR_PATCH_OPENCV_EXTRA $PATH_WORK_TMP
fi

## 4.2. set OPENCV_TEST_DATA_PATH
export OPENCV_TEST_DATA_PATH=$WORK_DIR/$PATH_WORK_TMP/testdata

## 4.3 运行 MLU 模块测试
cd $WORK_DIR/opencv-mlu/opencv/build/bin
./opencv_test_core --gtest_filter=*Mlu*
#测试resize和cvtColor算子
./opencv_test_cnimgproc
#测试h264编码器和解码器
./opencv_test_videoio --gtest_filter=videoio_ffmpeg.parallel_mlu_h264
#测试hevc编码器和解码器
./opencv_test_videoio --gtest_filter=videoio_ffmpeg.parallel_mlu_hevc
#测试dnn模块
./opencv_test_dnn --gtest_filter=*MLU*
echo -e "\033[0;32m[Test OpenCV-MLU... Done] \033[0m"