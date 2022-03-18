// This file is part of OpenCV project.
// It is subject to the license terms in the LICENSE file found in the top-level directory
// of this distribution and at http://opencv.org/license.html.
//
// Copyright (C) [2021] by Cambricon, Inc. All rights reserved.
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

#include <opencv2/videoio.hpp>
#include <iostream>

using namespace cv;

int main(int argc, char** argv) {
    if (argc != 2)
    {
        std::cout << "Usage: " << argv[0] << " video-file" << std::endl;
        return -1;
    }

    VideoCapture capture;
    /* set decoder end device id */
    std::vector<int> vc_params = {CAP_PROP_MLU_DEVICE_ID, 0, CAP_PROP_MLU_ENABLE, 1};
    capture.open(argv[1], CAP_FFMPEG, vc_params);
    if (!capture.isOpened())
    {
        std::cout << "Read video Failed !" << std::endl;
        return -1;
    }

    int type = static_cast<int>(capture.get(CAP_PROP_FOURCC));
    Size dst_size = Size((int)capture.get(CAP_PROP_FRAME_WIDTH), (int)capture.get(CAP_PROP_FRAME_HEIGHT));
    double fps = capture.get(CAP_PROP_FPS);
    std::cout << "fps is: " << fps << std::endl;

    /* set encoder and device id */
    std::vector<int> vw_params = {VIDEOWRITER_PROP_MLU_DEVICE_ID, 0, VIDEOWRITER_PROP_MLU_ENABLE, 1};
    VideoWriter writer("./out.avi", CAP_FFMPEG, type, fps, dst_size, vw_params);

    Mat frame;
    std::string out_name;
    while (capture.read(frame))
    {
        writer.write(frame);
    }

    capture.release();
    writer.release();

    return 0;
}
