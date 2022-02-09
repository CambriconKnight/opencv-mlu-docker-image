<p align="center">
    <a href="https://gitee.com/cambriconknight/opencv-mlu-docker-image">
        <h1 align="center">OpenCV-MLU环境搭建与验证</h1>
    </a>
</p>

[TOC]

# 1. 概述

本工具集主要基于Docker容器进行[OpenCV-MLU](https://github.com/Cambricon/opencv-mlu)环境搭建与验证。力求压缩寒武纪OpenCV-MLU环境搭建与功能验证的时间成本, 以便快速上手寒武纪OpenCV-MLU。

*本工具集仅用于个人学习，打通流程； 不对效果负责，不承诺商用。*

说明: 基于寒武纪® MLU硬件平台，寒武纪 OpenCV-MLU 实现MLU硬件加速的特性，如 AI推理、视频编解码和通用算子计算等。

## 1.1. 硬件环境准备

| 名称            | 数量       | 备注                |
| :-------------- | :--------- | :------------------ |
| 开发主机/服务器 | 一台       |主流配置即可；电源功率大于500W；PCIe Gen.3 x16 |
| MLU270-F4/S4    | 一套       |使用板卡自带的8pin连接器连接主机电源|

## 1.2. 软件环境准备

| 名称                   | 版本/文件                                    | 备注            |
| :-------------------- | :-------------------------------             | :--------------- |
| Linux OS              | Ubuntu16.04/Ubuntu18.04/CentOS7              | 宿主机操作系统   |
| Driver_MLU270         | neuware-mlu270-driver-aarch64-4.9.8.tar.gz   | 官方FTP[下载](ftp://download.cambricon.com:8821/product/GJD/MLU270/1.7.602/Ubuntu18.04/Driver/neuware-mlu270-driver-dkms_4.9.5_all.deb)   |
| CNToolkit_MLU270      | cntoolkit_1.7.5-1.ubuntu18.04_amd64.deb      | 官方FTP[下载](ftp://sdgsxxjt@download.cambricon.com:8821/product/GJD/MLU270/1.7.602/Ubuntu18.04/CNToolkit/cntoolkit_1.7.5-1.ubuntu18.04_amd64.deb)   |
| CNCV_MLU270           | cncv_0.4.602-1.ubuntu18.04_amd64.deb         | 官方FTP[下载](ftp://sdgsxxjt@download.cambricon.com:8821/product/GJD/MLU270/1.7.602/Ubuntu18.04/CNCV/cncv_0.4.602-1.ubuntu18.04_amd64.deb)   |
| FFmpeg-MLU            | FFmpeg-MLU                                   | 官方[下载](https://github.com/Cambricon/ffmpeg-mlu)   |
| FFmpeg                | FFmpeg                                       | 官方[下载](https://gitee.com/mirrors/ffmpeg.git)   |
| EasyDK                | EasyDK                                       | 官方[下载](https://github.com/Cambricon/easydk)   |
| OpenCV-MLU-PATCH      | opencv-mlu-rel-r0.2.0.tar.gz                 | 官方[下载](ftp://download.cambricon.com:8821/download/opencv-mlu/opencv-mlu-rel-r0.2.0.tar.gz)   |
| OpenCV                | opencv-4.5.3.tar.gz                          | 官方GitHub [下载](https://github.com/opencv/opencv/archive/refs/tags/4.5.3.tar.gz) |
| OpenCV-Extra          | opencv_extra-4.5.3.tar.gz                    | 官方GitHub [下载](https://github.com/opencv/opencv_extra/archive/refs/tags/4.5.3.tar.gz) |

## 1.3. 资料下载

Ubuntu16.04: http://mirrors.aliyun.com/ubuntu-releases/16.04

Ubuntu18.04: http://mirrors.aliyun.com/ubuntu-releases/18.04

MLU开发文档: https://developer.cambricon.com/index/document/index/classid/3.html

Neuware SDK: https://cair.cambricon.com/#/home/catalog?type=SDK%20Release

其他开发资料, 可前往[寒武纪开发者社区](https://developer.cambricon.com)注册账号按需下载。也可在官方提供的专属FTP账户指定路径下载。

# 2. Clone
```bash
git clone https://github.com/CambriconKnight/opencv-mlu-docker-image.git
```

# 3. Build
```bash
#编译 opencv-mlu 镜像
./build-image-opencv-mlu.sh
```

# 4. Load
```bash
#加载Docker镜像
./load-image-opencv-mlu.sh
```

# 5. Run
```bash
#启动Docker容器
./run-container-opencv-mlu.sh
```

# 6.Test
```bash
#执行测试脚本
./test-opencv-mlu.sh
```
