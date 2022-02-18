
寒武纪<sup>®</sup> OpenCV-MLU
====================================

基于寒武纪<sup>®</sup> MLU硬件平台，寒武纪 OpenCV-MLU 实现MLU硬件加速的特性，如 AI推理、视频编解码和通用算子计算等

## 必备条件 ##

- 支持的操作系统如下：
   - Ubuntu
   - Centos
   - Debian
- 寒武纪MLU驱动:
   - neuware-driver-4.9.x
- 寒武纪MLU SDK:
   - cntookit-1.7.x
   - CNCV-0.4.302 / 0.4.602 / 0.4.702
   - [FFmpeg-MLU（可选）](https://github.com/Cambricon/ffmpeg-mlu) 1.6.0版本及以上
   - [EasyDK（可选）](https://github.com/Cambricon/easydk) 3.0.0版本及以上

## 安装 OpenCV-MLU ##
1. 编译及安装FFmpeg-MLU（可选项，使用MLU硬件加速videoio模块）

   OpenCV需要链接FFmpeg动态库，详细编译安装过程请参考[FFmpeg-MLU指导手册](https://github.com/Cambricon/ffmpeg-mlu/blob/master/README.md);

   **notice:**
   1. *建议系统中没有原生FFmpeg,或已卸载其他版本的FFmpeg*
   2. *建议将FFmpeg—MLU直接安装到系统目录下*

2. 编译及安装EasyDK（可选项，使用MLU硬件加速dnn模块）

   OpenCV dnn模块依赖EasyDK中infer_server部分，详细编译配置请参考[EasyDK用户手册](https://github.com/Cambricon/easydk/blob/master/docs/release_document/3.0.0/Cambricon-EasyDK-User-Guide-CN-v3.0.0.pdf)。
   ```bash
   cd easydk
   mkdir build && cd build
   # easydk必须安装在${NEUWARE_HOME}路径
   cmake .. \
         -DBUILD_SAMPLES=OFF \
         -DWITH_BANG=OFF \
         -DWITH_TRACKER=OFF \
         -DWITH_INFER=OFF \
         -DWITH_CODEC=OFF \
         -DCMAKE_INSTALL_PREFIX=${NEUWARE_HOME}
   make -j
   make install
   ```

   - MLU200系列使用cnrt后端，需要关闭编译选项 `-DCNIS_USE_MAGICMIND=OFF`。
   - MLU300系列使用Magicmind后端，需要增加编译选项 `-DCNIS_USE_MAGICMIND=ON`。

3. 编译及安装OpenCV-MLU:
   OpenCV-MLU基于OpenCV 4.5.3版本，其他版本不保证兼容。

   ```bash
   export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$NEUWARE_HOME/lib64
   # ffmpeg-mlu默认安装在/usr/local，假如未卸载系统库，则需要指定pkg-config配置文件路径
   export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
   # 假设OpenCV源码已放置于opencv-mlu目录下
   cd opencv-4.5.3
   # 如果opencv是git仓库，也可以使用 git apply ../opencv-mlu.patch
   patch -p1 -i ../opencv-mlu.patch
   mkdir build && cd build
   cmake .. \
         -DWITH_FFMPEG=ON \
         -DCMAKE_BUILD_TYPE=RELEASE \
         -DCMAKE_INSTALL_PREFIX=/usr/local/opencv-4.5.3
   make -j && make install
   ```

4. 运行 MLU 模块测试：
   ```bash
   cd build/bin
   ./opencv_test_core --gtest_filter=*Mlu*
   #测试resize和cvtColor算子
   ./opencv_test_cnimgproc
   #测试h264编码器和解码器
   ./opencv_test_videoio --gtest_filter=videoio_ffmpeg.parallel_mlu_h264
   #测试hevc编码器和解码器
   ./opencv_test_videoio --gtest_filter=videoio_ffmpeg.parallel_mlu_hevc
   #测试dnn模块
   ./opencv_test_dnn --gtest_filter=*MLU*
   ```

## 编解码API开发说明 ##
**编码**
- OpenCV-MLU 硬件编码器集成于 OpenCV cv::VideoWriter 中，使用方法与社区原生OpenCV中 cv::VideoWriter 使用方式一致
   - 通过设置 VIDEOWRITER_PROP_MLU_DEVICE_ID 的值来设置硬件 mlu id
   - 通过设置 VIDEOWRITER_PROP_MLU_ENABLE 的值来设置是否启用硬件编码器

**解码**
- OpenCV-MLU 硬件解码器集成于 OpenCV cv::VideoCapture 中，使用方法与社区原生 OpenCV中 cv::VideoCapture 使用方式一致
- OpmeCV-MLU 中新增硬件后处理功能，即：解码后硬件做convert或resize and convert操作
   - 通过设置 CAP_PROP_MLU_DEVICE_ID 的值来设置硬件 mlu id
   - 通过设置 CAP_PROP_MLU_ENABLE 的值来设置是否启用硬件解码器
   - 通过设置 CAP_PROP_MLU_POSTPROC 的值来设置是否启用解码后处理模块
   - 通过设置 CAP_PROP_MLU_DST_FRAME_WIDTH 的值来设置后处理后输出图像的宽
   - 通过设置 CAP_PROP_MLU_DST_FRAME_HEIGHT 的值来设置后处理后输出图像的高

   **usage**
   - 不设置 CAP_PROP_MLU_POSTPROC，则使用原生方法
   - 设置 CAP_PROP_MLU_POSTPROC，但不设置 CAP_PROP_MLU_DST_FRAME_WIDTH和CAP_PROP_MLU_DST_FRAME_HEIGHT，则使用硬件convert后处理操作
   - 设置 CAP_PROP_MLU_POSTPROC ，也设置 CAP_PROP_MLU_DST_FRAME_WIDTH和CAP_PROP_MLU_DST_FRAME_HEIGHT，则使用硬件 resize and convert后处理操作

## CV算子使用说明 ##
- 算子基于 `cn::MluMat` 数据结构进行计算， `cn::MluMat` 存放设备内存，使用方式与 `Mat` 相似
- 在操作硬件资源前（如下所示），需要先绑定设备到当前线程（ `cn::setDevice(device_id)` ）
   - 创建 `cn::MluMat`
   - 创建 `cn::TaskQueue`
   - 调用MLU硬件加速的CV算子API
- MLU硬件加速API在命名空间cn中，与社区原生API命名一致，在末尾多了一个默认参数，`TaskQueue& tq = TaskQueue::null()`
   - 当 `TaskQueue` 是null时，API同步执行，与原生API表现一致
   - 当 `TaskQueue` 不是null时，API异步执行，函数返回时不保证任务已完成，读取结果前需要调用 `TaskQueue::waitForCompletion()` 同步设备
   - 相同 `TaskQueue` 中的任务串行执行，不同 `TaskQueue` 中的任务并行执行
   - 不同线程使用同一个 `TaskQueue` 是未定义行为

## dnn模块使用说明 ##
- 调用 `cv::dnn::readNetFromCambriconModel` 接口加载由寒武纪框架生成的AOT模型
- OpenCV不支持ARGB、ABGR格式图像，生成AOT模型时需指定其它输入格式
- 模型输入输出shape不可变（包括n维度）
- 限于dnn模块架构，模型输入仅支持host内存，NCHW格式数据，可通过原生接口 `cv::dnn::blobFromImages` 获取图像预处理后的输入数据
- 输入数据的类型由模型决定（支持32F、8U；要求输入16F的模型需要使用32F数据，forward时自动转换至16F）
- 仅支持同步调用MLU加速推理
- 不支持多个线程forward同一个Network

## Opencv-MLU sample ##

参见 `opencv-mlu/samples/mlu` 和 `opencv-mlu/samples/dnn/object_detection_mlu.cpp` 。
