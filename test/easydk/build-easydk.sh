#!/bin/bash
set -e
# -------------------------------------------------------------------------------
# Filename:     build-easydk.sh
# UpdateDate:   2022/02/08
# Description:  Build opencv-mlu.
# Example:      ./build-opencv-mlu.sh
# Depends:
#               Driver(ftp://username@download.cambricon.com:8821/product/GJD/MLU270/1.7.604/Ubuntu16.04/Driver/neuware-mlu270-driver-dkms_4.9.8_all.deb)
#               CNToolkit(ftp://username@download.cambricon.com:8821/product/GJD/MLU270/1.7.604/Ubuntu16.04/CNToolkit/cntoolkit_1.7.5-1.ubuntu16.04_amd64.deb)
#               CNCV(ftp://username@download.cambricon.com:8821/product/GJD/MLU270/1.7.604/Ubuntu16.04/CNCV/cncv_0.4.602-1.ubuntu16.04_amd64.deb)
#               OpenCV-4.5.3(https://github.com/opencv/opencv/tree/4.5.3)
#               EasyDK(https://github.com/Cambricon/easydk)
# Notes:
# -------------------------------------------------------------------------------
CMD_TIME=$(date +%Y%m%d%H%M%S.%N) # eg:20190402230402.403666251
#Font color
none="\033[0m"
green="\033[0;32m"
red="\033[0;31m"
yellow="\033[1;33m"
white="\033[1;37m"
#ENV
DIR_EASYDK="easydk-master"
FILENAME_EASYDK="$DIR_EASYDK.tar.gz"
#############################################################
## 1. 设置环境变量
export NEUWARE_HOME=/usr/local/neuware
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${NEUWARE_HOME}/lib64
#############################################################
# 2. Compile and install EasyDK
## 2.1. Download EasyDK
PATH_WORK_TMP="easydk"
if [ -f "${FILENAME_EASYDK}" ];then
    echo -e "${green}File(${FILENAME_EASYDK}): Exists!${none}"
    tar zxvf $FILENAME_EASYDK
    # check
    if [ -d "$PATH_WORK_TMP" ];then
        echo -e "${green}[Directory($PATH_WORK_TMP): Exists! Delete $PATH_WORK_TMP and Decompress...] ${none}"
        rm -rf $PATH_WORK_TMP
    fi
    mv $DIR_EASYDK $PATH_WORK_TMP
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
# check
if [ -d "/usr/local/neuware/include/cnis" ];then
    echo -e "${green}[Directory(/usr/local/neuware/include/cnis): Exists! Delete Install and ReInstall...] ${none}"
    mv -v /usr/local/neuware/include/cnis /usr/local/neuware/include/cnis-$CMD_TIME
fi

pushd $PATH_WORK_TMP
#find . -name ".git" | xargs rm -Rf
# check
if [ -d "build" ];then
    echo -e "${green}[Directory(build): Exists! Delete build and rebuild...] ${none}"
    rm -rf build
fi
popd

# build easydk
mkdir -pv $PATH_WORK_TMP/build
pushd $PATH_WORK_TMP/build
# easydk必须安装在${NEUWARE_HOME}路径
cmake .. \
        -DBUILD_SAMPLES=ON \
        -DBUILD_TESTS=OFF \
        -DWITH_BANG=ON \
        -DWITH_TRACKER=ON \
        -DWITH_INFER=ON \
        -DWITH_CODEC=ON \
        -DCNIS_WITH_PYTHON_API=OFF \
        -DCMAKE_INSTALL_PREFIX=${NEUWARE_HOME}

#cmake .. \
#        -DBUILD_SAMPLES=OFF \
#        -DBUILD_TESTS=OFF \
#        -DWITH_BANG=ON \
#        -DWITH_TRACKER=ON \
#        -DWITH_INFER=ON \
#        -DWITH_CODEC=ON \
#        -DCNIS_WITH_PYTHON_API=OFF \
#        -DCMAKE_INSTALL_PREFIX=${NEUWARE_HOME}

make -j4 && make install \
    && ls -lh ${NEUWARE_HOME}/lib64 \
    && echo -e "${green}[Build ${PATH_WORK_TMP}... Done] ${none}"
popd
