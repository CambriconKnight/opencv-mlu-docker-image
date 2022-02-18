#!/bin/bash
set -e
# -------------------------------------------------------------------------------
# Filename:     build-opencv-mlu.sh
# UpdateDate:   2022/02/08
# Description:  Build opencv-mlu.
# Example:      ./build-opencv-mlu.sh
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
#Font color
none="\033[0m"
green="\033[0;32m"
red="\033[0;31m"
yellow="\033[1;33m"
white="\033[1;37m"
#ENV
PATH_WORK="opencv-mlu"
WORK_DIR="/root/opencv-mlu"
DIR_PATCH_OPENCV="opencv-mlu-rel-r0.2.0"
FILENAME_PATCH_OPENCV="$DIR_PATCH_OPENCV.tar.gz"
FILENAME_OPENCV="opencv-4.5.3.tar.gz"
FILENAME_FFMPEG_MLU="ffmpeg-mlu-master20220209.tar.gz"
FILENAME_EASYDK="easydk-master20220209.tar.gz"
#############################################################
# 1. Compile and install FFmpeg-MLU
## 1.1. Download FFmpeg-MLU
cd $WORK_DIR
PATH_WORK_TMP="ffmpeg-mlu"
if [ -f "${FILENAME_FFMPEG_MLU}" ];then
    echo -e "${green}File(${FILENAME_FFMPEG_MLU}): Exists!${none}"
    # $FILENAME_FFMPEG_MLU 压缩包中已经包含了ffmpeg-mlu补丁 + ffmpeg4.2
    tar zxvf $FILENAME_FFMPEG_MLU
else
    echo -e "${red}File(${FILENAME_FFMPEG_MLU}): Not exist!${none}"
    echo -e "${yellow}1.Please download ${FILENAME_FFMPEG_MLU} from FTP(ftp://download.cambricon.com:8821/***)!${none}"
    echo -e "${yellow}  For further information, please contact us.${none}"
    echo -e "${yellow}2.Copy the dependent packages(${FILENAME_FFMPEG_MLU}) into the directory!${none}"
    echo -e "${yellow}  eg:cp -v ./dependent_files/${FILENAME_FFMPEG_MLU} ./${PATH_WORK}${none}"
    echo -e "${green}3.Downloading automatically......${none}"

    if [ ! -d "${PATH_WORK_TMP}" ];then
        git clone https://github.com/Cambricon/ffmpeg-mlu
    else
        echo "Directory($PATH_WORK_TMP): Exists!"
    fi

    ## 1.2. Download FFmpeg
    pushd $PATH_WORK_TMP
    git clone https://gitee.com/mirrors/ffmpeg.git -b release/4.2 --depth=1
    popd

    ## 1.3 Patch
    pushd $PATH_WORK_TMP/ffmpeg
    git apply ../ffmpeg4.2_mlu.patch
    popd
fi

## 1.4. 设置环境变量
export NEUWARE_HOME=/usr/local/neuware
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${NEUWARE_HOME}/lib64

## 1.5. 编译FFmpeg-MLU
pushd $PATH_WORK_TMP/ffmpeg
./configure  --enable-gpl \
                --extra-cflags="-I${NEUWARE_HOME}/include" \
                --extra-ldflags="-L${NEUWARE_HOME}/lib64" \
                --extra-libs="-lcncodec -lcnrt -ldl -lcndrv" \
                --enable-ffplay \
                --enable-ffmpeg \
                --enable-mlumpp \
                --enable-gpl \
                --enable-version3 \
                --enable-nonfree \
                --disable-static \
                --enable-shared \
                --disable-debug \
                --enable-stripping \
                --enable-optimizations \
                --enable-avresample
make -j4 && make install
popd

## 1.6. 编译FFmpeg-mlu依赖库
### a.建议系统中没有原生FFmpeg,或已卸载其他版本的FFmpeg
### b.建议将FFmpeg—MLU直接安装到系统目录下
### 1.6.1. 安装完成cncv库(拷贝cncv安装包到当前目录下)
#dpkg -i cncv_0.4.602-1.ubuntu18.04_amd64.deb
### 1.6.2. 编译mlu_op算子
mkdir -pv $PATH_WORK_TMP/mlu_op/build
pushd $PATH_WORK_TMP/mlu_op/build
cmake .. && make -j4
popd
### 1.6.3. 拷贝libeasyOP.so 到NEUWARE_HOME路径下
cp -rvf $PATH_WORK_TMP/mlu_op/lib/libeasyOP.so ${NEUWARE_HOME}/lib64
ls -lh ${NEUWARE_HOME}/lib64/libeasyOP.so
echo -e "${green}[Build ${PATH_WORK_TMP}... Done] ${none}"

#############################################################
# 2. Compile and install EasyDK
## 2.1. Download EasyDK
cd $WORK_DIR
PATH_WORK_TMP="easydk"
if [ -f "${FILENAME_EASYDK}" ];then
    echo -e "${green}File(${FILENAME_EASYDK}): Exists!${none}"
    tar zxvf $FILENAME_EASYDK
else
    echo -e "${red}File(${FILENAME_EASYDK}): Not exist!${none}"
    echo -e "${yellow}1.Please download ${FILENAME_EASYDK} from FTP(ftp://download.cambricon.com:8821/***)!${none}"
    echo -e "${yellow}  For further information, please contact us.${none}"
    echo -e "${yellow}2.Copy the dependent packages(${FILENAME_EASYDK}) into the directory!${none}"
    echo -e "${yellow}  eg:cp -v ./dependent_files/${FILENAME_EASYDK} ./${PATH_WORK}${none}"
    echo -e "${green}3.Downloading automatically......${none}"

    if [ ! -d "${PATH_WORK_TMP}" ];then
        git clone https://github.com/Cambricon/easydk
    else
        echo "Directory($PATH_WORK_TMP): Exists!"
    fi
fi

pushd $PATH_WORK_TMP
#find . -name ".git" | xargs rm -Rf
# check
if [ -d "build" ];then
    echo -e "${green}[Directory(build): Exists! Delete build and rebuild...] ${none}"
    rm -rvf build
fi
popd

# build easydk
mkdir -pv $PATH_WORK_TMP/build
pushd $PATH_WORK_TMP/build
# easydk必须安装在${NEUWARE_HOME}路径
#cmake .. \
#        -DBUILD_SAMPLES=ON \
#        -DBUILD_TESTS=OFF \
#        -DWITH_BANG=ON \
#        -DWITH_TRACKER=ON \
#        -DWITH_INFER=ON \
#        -DWITH_CODEC=ON \
#        -DCNIS_WITH_PYTHON_API=OFF \
#        -DCMAKE_INSTALL_PREFIX=${NEUWARE_HOME}

cmake .. \
        -DBUILD_SAMPLES=OFF \
        -DBUILD_TESTS=OFF \
        -DWITH_BANG=ON \
        -DWITH_TRACKER=ON \
        -DWITH_INFER=ON \
        -DWITH_CODEC=ON \
        -DCNIS_WITH_PYTHON_API=OFF \
        -DCMAKE_INSTALL_PREFIX=${NEUWARE_HOME}

make -j4 && make install \
    && ls -lh ${NEUWARE_HOME}/lib64 \
    && echo -e "${green}[Build ${PATH_WORK_TMP}... Done] ${none}"
popd

#############################################################
# 3. Compile and install OpenCV-MLU
## 注：OpenCV-MLU基于OpenCV 4.5.3版本，其他版本不保证兼容。
## 3.1. 下载OpenCV-MLU
#下载OpenCV-MLU
#从官方提供的FTP账户下载最新版本的OpenCV-MLU压缩包&解压
if [ -f "${FILENAME_PATCH_OPENCV}" ];then
    echo -e "${green}File(${FILENAME_PATCH_OPENCV}): Exists!${none}"
    tar zxvf $FILENAME_PATCH_OPENCV
else
    echo -e "${red}File(${FILENAME_PATCH_OPENCV}): Not exist!${none}"
    echo -e "${yellow}1.Please download ${FILENAME_PATCH_OPENCV} from FTP(ftp://download.cambricon.com:8821/***)!${none}"
    echo -e "${yellow}  For further information, please contact us.${none}"
    echo -e "${yellow}2.Copy the dependent packages(${FILENAME_PATCH_OPENCV}) into the directory!${none}"
    echo -e "${yellow}  eg:cp -v ./dependent_files/${FILENAME_PATCH_OPENCV} ./${PATH_WORK}${none}"
    exit -1
fi
mv $DIR_PATCH_OPENCV opencv-mlu
cd opencv-mlu
#下载OpenCV 4.5.3版本源码 FILENAME_OPENCV
if [ -f "${FILENAME_OPENCV}" ];then
    echo -e "${green}File(${FILENAME_OPENCV}): Exists!${none}"
    #tar zxvf $FILENAME_OPENCV
else
    echo -e "${red}File(${FILENAME_OPENCV}): Not exist!${none}"
    echo -e "${yellow}1.Please download ${FILENAME_OPENCV} from FTP(ftp://download.cambricon.com:8821/***)!${none}"
    echo -e "${yellow}  For further information, please contact us.${none}"
    echo -e "${yellow}2.Copy the dependent packages(${FILENAME_OPENCV}) into the directory!${none}"
    echo -e "${yellow}  eg:cp -v ./dependent_files/${FILENAME_OPENCV} ./${PATH_WORK}${none}"

    echo -e "${green}3.Downloading automatically......${none}"
    wget -O opencv-4.5.3.tar.gz https://github.com/opencv/opencv/archive/refs/tags/4.5.3.tar.gz
fi

tar zxvf $FILENAME_OPENCV
mv opencv-4.5.3 opencv
cd opencv
# 如果opencv-mlu是git仓库，也可以使用 git apply ../opencv-mlu.patch
patch -p1 -i ../opencv-mlu.patch

## 3.2. 编译OpenCV-MLU
mkdir build && cd build
cmake -DWITH_FFMPEG=ON \
        -DCMAKE_BUILD_TYPE=RELEASE \
        -DCMAKE_INSTALL_PREFIX=/usr/local/opencv-4.5.3 ..
make -j4 && make install
ls -lh /root/opencv-mlu/opencv-mlu/opencv/build/bin
ls -lh /usr/local/opencv-4.5.3
echo -e "${green}[Build & Install OpenCV-MLU... Done] ${none}"
cd $WORK_DIR

#############################################################
# 4.Test OpenCV-MLU
#./test-opencv-mlu.sh