<p align="center">
    <a href="https://gitee.com/cambriconknight/opencv-mlu-docker-image">
        <h1 align="center">OpenCV-MLU环境搭建与验证</h1>
    </a>
</p>

# 1. 概述

本工具集主要基于Docker容器进行[OpenCV-MLU](https://github.com/Cambricon/opencv-mlu)环境搭建与验证。力求压缩寒武纪OpenCV-MLU环境搭建与功能验证的时间成本, 以便快速上手寒武纪OpenCV-MLU。

*本工具集仅用于个人学习，打通流程； 不对效果负责，不承诺商用。*

**说明:**

基于寒武纪® MLU硬件平台，寒武纪 OpenCV-MLU 已实现部分MLU硬件加速的特性，如 AI推理、视频编解码和通用算子计算等。

## 1.1. 硬件环境准备

| 名称            | 数量       | 备注                |
| :-------------- | :--------- | :------------------ |
| 开发主机/服务器 | 一台       |主流配置即可；电源功率大于500W；PCIe Gen.3 x16 |
| MLU270-F4/S4    | 一套       |使用板卡自带的8pin连接器连接主机电源|

## 1.2. 软件环境准备

| 名称                   | 版本/文件                                    | 备注            |
| :-------------------- | :-------------------------------             | :--------------- |
| Linux OS              | Ubuntu16.04/Ubuntu18.04/CentOS7   | 宿主机操作系统   |
| Driver_MLU270         | neuware-mlu270-driver-dkms_4.9.8_all.deb    | [手动下载](ftp://username@download.cambricon.com:8821/product/GJD/MLU270/1.7.604/Ubuntu16.04/Driver/neuware-mlu270-driver-dkms_4.9.8_all.deb)   |
| CNToolkit_MLU270      | cntoolkit_1.7.5-1.ubuntu16.04_amd64.deb   | [手动下载](ftp://username@download.cambricon.com:8821/product/GJD/MLU270/1.7.604/Ubuntu16.04/CNToolkit/cntoolkit_1.7.5-1.ubuntu16.04_amd64.deb)   |
| CNCV_MLU270           | cncv_0.4.602-1.ubuntu16.04_amd64.deb    | [手动下载](ftp://username@download.cambricon.com:8821/product/GJD/MLU270/1.7.604/Ubuntu16.04/CNCV/cncv_0.4.602-1.ubuntu16.04_amd64.deb)   |
| FFmpeg-MLU            | FFmpeg-MLU   | 自动[下载](https://github.com/Cambricon/ffmpeg-mlu)    |
| FFmpeg                | FFmpeg   | 自动[下载](https://gitee.com/mirrors/ffmpeg.git)    |
| EasyDK                | EasyDK   | 自动[下载](https://github.com/Cambricon/easydk)   |
| OpenCV-MLU-PATCH      | opencv-mlu-rel-r0.2.0.tar.gz   | [手动下载](ftp://username@download.cambricon.com:8821/download/opencv-mlu/opencv-mlu-rel-r0.2.0.tar.gz)    |
| OpenCV                | opencv-4.5.3.tar.gz   | 自动[下载](https://github.com/opencv/opencv/archive/refs/tags/4.5.3.tar.gz) |
| OpenCV-Extra          | opencv_extra-4.5.3.tar.gz   | 自动[下载](https://github.com/opencv/opencv_extra/archive/refs/tags/4.5.3.tar.gz)  |

*以上软件包涉及FTP手动下载的,可下载到本地[dependent_files](./dependent_files)目录下,方便对应以下步骤中的提示操作。*

## 1.3. 资料下载

Ubuntu16.04: http://mirrors.aliyun.com/ubuntu-releases/16.04

Ubuntu18.04: http://mirrors.aliyun.com/ubuntu-releases/18.04

MLU开发文档: https://developer.cambricon.com/index/document/index/classid/3.html

Neuware SDK: https://cair.cambricon.com/#/home/catalog?type=SDK%20Release

其他开发资料, 可前往[寒武纪开发者社区](https://developer.cambricon.com)注册账号按需下载。也可在官方提供的专属FTP账户指定路径下载。

# 2. Structure

*当前仓库默认基于Docker 进行OpenCV-MLU 环境搭建与验证。按照以下章节步骤即可快速实现OpenCV-MLU环境搭建与验证*

```bash
.
├── build-image-opencv-mlu.sh           #此脚本用于编译Docker 镜像用于搭建OpenCV-MLU 环境
├── clean.sh                            #清理Build出来的临时目录或文件,包括镜像文件,已加载的镜像,已加载的容器等
├── dependent_files                     #此目录用于存储OpenCV-MLU 环境搭建与验证所依赖的文件
│   └── README.md
├── docker                              #此目录主要用于存储编译Docker 镜像及验证OpenCV-MLU 所需依赖文件
│   ├── build-opencv-mlu.sh             #此脚本用于编译OpenCV-MLU 及相关依赖项, 也可用于裸机下环境搭建
│   ├── clean.sh                        #清理当前目录下新编译生存的Docker 镜像文件
│   ├── Dockerfile.16.04                #用于编译Docker 镜像的Dockerfile 文件
│   ├── pip.conf                        #切换python的pip源
│   ├── pre_packages.sh                 #安装基于操作系统所需依赖包, 也可用于裸机下环境搭建
│   ├── sources_16.04.list              #Ubuntu16.04 sources文件
│   └── test-opencv-mlu.sh              #此脚本用于测试验证OpenCV-MLU各模块: 测试Resize/CVTColor算子、H264/HEVC编码器和解码器、DNN模块
├── env.sh                              #用于设置全局环境变量
├── load-image-opencv-mlu.sh            #加载Docker 镜像
├── README.md                           #README
├── run-container-opencv-mlu.sh         #启动Docker 容器
├── save-image-opencv-mlu.sh            #导出镜像文件，实现镜像内容持久化
├── sync.sh                             #同步[dependent_files] 到临时目录[opencv-mlu]
└── test                                #测试OpenCV-MLU 相关功能目录
    ├── data                            #测试数据
    ├── dnn                             #测试DNN
    ├── easydk                          #测试EasyDK
    ├── README.md                       #测试说明
    └── video                           #测试视频编解码
```

*如需在裸机HOST上进行环境搭建, 也可以利用[docker](./docker)目录以下脚本实现快速搭建。*

```bash
.
├── docker
│   ├── build-opencv-mlu.sh             #此脚本用于编译OpenCV-MLU 及相关依赖项, 也可用于裸机下环境搭建
│   ├── pre_packages.sh                 #安装基于操作系统所需依赖包, 也可用于裸机下环境搭建
│   ├── sources_16.04.list              #Ubuntu16.04 sources文件
│   └── test-opencv-mlu.sh              #此脚本用于测试验证OpenCV-MLU各模块: 测试Resize/CVTColor算子、H264/HEVC编码器和解码器、DNN模块
```

# 3. Clone
```bash
git clone https://github.com/CambriconKnight/opencv-mlu-docker-image.git
```

# 4. Build
```bash
#编译 opencv-mlu 镜像
./build-image-opencv-mlu.sh
```

# 5. Load
```bash
#加载Docker镜像
./load-image-opencv-mlu.sh
```

# 6. Run
```bash
#启动Docker容器
./run-container-opencv-mlu.sh
```

# 7.Test
```bash
#执行测试脚本
./test-opencv-mlu.sh
```
