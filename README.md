# OpenCV-MLU Docker Images #

Build docker images for [OpenCV-MLU](https://github.com/Cambricon/opencv-mlu).

# Directory tree #

```bash
.
├── build-image-opencv-mlu.sh
├── load-image-opencv-mlu.sh
└── run-container-opencv-mlu.sh
```

# Clone #
```bash
git clone https://github.com/CambriconKnight/opencv-mlu-docker-image.git
```

# Build #
```bash
#编译 opencv-mlu 镜像
./build-image-opencv-mlu.sh
```

# Load #
```bash
#加载Docker镜像
./load-image-opencv-mlu.sh
```

# Run #
```bash
#启动Docker容器
./run-container-opencv-mlu.sh
```

# Test #
## Download opencv_extra
```bash
cd $WORK_DIR
PATH_WORK_TMP="opencv_extra"
if [ ! -d "${PATH_WORK_TMP}" ];then
    #git clone https://github.com/opencv/opencv_extra
    #下载opencv_extra 4.5.3版本
    wget -O opencv_extra.tar.gz https://github.com/opencv/opencv_extra/archive/refs/tags/4.5.3.tar.gz
    tar zxvf opencv_extra.tar.gz
    mv opencv_extra-4.5.3 opencv_extra
else
    echo "Directory($PATH_WORK_TMP): Exists!"
fi
```

## Set OPENCV_TEST_DATA_PATH
```bash
export OPENCV_TEST_DATA_PATH=$WORK_DIR/opencv_extra/testdata
```

## Test OpenCV-MLU
```bash
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
```
