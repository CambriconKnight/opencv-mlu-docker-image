#include <fstream>
#include <sstream>
#include <iostream>

#include <opencv2/dnn.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/highgui.hpp>

#include "common.hpp"

#define USE_MULTI_BATCH

std::string keys =
    "{ help  h          | | Print help message. }"
    "{ initial_width    | 0 | Preprocess input image by initial resizing to a specific width.}"
    "{ initial_height   | 0 | Preprocess input image by initial resizing to a specific height.}"
    "{ thr              | .5 | Confidence threshold. }"
    "{ input i          | | Path to input image or video file. Skip this argument to capture frames from a camera.}"
    "{ classes          | | Optional path to a text file with names of classes. }";

using namespace cv;
using namespace dnn;

std::string model_uri = "http://video.cambricon.com/models/MLU270/Primary_Detector/ssd/vgg16_ssd_b4c4_bgra_mlu270.cambricon";
std::string input_file = "../data/test.mp4";
Size model_input_size(300, 300);

using Object = std::tuple<int, float, Rect>;
std::vector<std::string> classes;

void drawPred(int classId, float conf, int left, int top, int right, int bottom, Mat& frame);
std::vector<std::vector<Object>> readObjects4N(const Mat& prob, Size img_size, float thr);
std::vector<Object> readObjects(const Mat& prob, Size img_size, float thr);

int main(int argc, char** argv)
{
    CommandLineParser parser(argc, argv, keys);

    parser = CommandLineParser(argc, argv, keys);
    parser.about("Use this script to run MLU-accelerated deep learning networks using OpenCV.");
    if (argc == 1 || parser.has("help"))
    {
        parser.printMessage();
        return 0;
    }

    int rszWidth = parser.get<int>("initial_width");
    int rszHeight = parser.get<int>("initial_height");
    float thr = parser.get<float>("thr");

    // Open file with classes names.
    if (parser.has("classes"))
    {
        std::string file = parser.get<String>("classes");
        std::ifstream ifs(file.c_str());
        if (!ifs.is_open())
            CV_Error(Error::StsError, "File " + file + " not found");
        std::string line;
        while (std::getline(ifs, line))
        {
            classes.push_back(line);
        }
    }

    if (!parser.check())
    {
        parser.printErrors();
        return 1;
    }

    //! [Read and initialize network]
    Net net = readNetFromCambriconModel(model_uri);

    // Create a window
    static const std::string kWinName = "MLU-accelerated deep learning detection in OpenCV";
    namedWindow(kWinName, WINDOW_NORMAL);

    //! [Open a video file or an image file or a camera stream]
    VideoCapture cap;
    cap.open(input_file);
    //if (parser.has("input"))
    //    cap.open(parser.get<String>("input"));
    //else
    //    cap.open(0);
    //! [Open a video file or an image file or a camera stream]

    // Process frames.
    Mat frame, blob;
    while (waitKey(1) < 0)
    {
        cap >> frame;
        if (frame.empty())
        {
            waitKey();
            break;
        }

        if (rszWidth != 0 && rszHeight != 0)
        {
            resize(frame, frame, Size(rszWidth, rszHeight));
        }

        cvtColor(frame, frame, COLOR_BGR2BGRA);

        std::vector<Mat> frames(4, frame);
        //! [Create a 4D blob from a frame]
        blobFromImages(frames, blob, 1.0, model_input_size, Scalar(), false, false, CV_8U);

        //! [Set input blob]
        net.setInput(blob);
        //! [Set input blob]
        //! [Make forward pass]
        Mat prob = net.forward();
        //! [Make forward pass]

        // Put efficiency information.
        std::vector<double> layersTimes;
        double freq = getTickFrequency() / 1000;
        double t = net.getPerfProfile(layersTimes) / freq;
        std::string label = format("Inference time: %.2f ms", t);
        putText(frame, label, Point(0, 15), FONT_HERSHEY_SIMPLEX, 0.5, Scalar(0, 255, 0));

    #ifdef USE_MULTI_BATCH
        std::vector<std::vector<Object>> objs = readObjects4N(prob, frame.size(), thr);
        for (size_t idn = 0; idn < objs.size(); ++idn)
        {
            std::vector<Object> recN = objs[idn];
            for (size_t idx = 0; idx < recN.size(); ++idx)
            {
                Rect& box = std::get<2>(recN[idx]);
                std::cout << "std::get<0>(recN[idx]): [" << std::get<0>(recN[idx]) \
                        << "] ; box.x: [" << box.x << "] ; box.y: [" << box.y \
                        << "] ; box.x + box.width: [" <<  box.x + box.width \
                        << "] ; box.y + box.height: [" << box.y + box.height << "] ;" << std::endl;
                drawPred(std::get<0>(recN[idx]), std::get<1>(recN[idx]), box.x, box.y,
                        box.x + box.width, box.y + box.height, frame);
            }
        }
    #else
        std::vector<Object> objs = readObjects(prob, frame.size(), thr);

        for (size_t idx = 0; idx < objs.size(); ++idx)
        {
            Rect& box = std::get<2>(objs[idx]);
            std::cout << "std::get<0>(objs[idx]): [" << std::get<0>(objs[idx]) \
                        << "] ; box.x: [" << box.x << "] ; box.y: [" << box.y \
                        << "] ; box.x + box.width: [" <<  box.x + box.width \
                        << "] ; box.y + box.height: [" << box.y + box.height << "] ;" << std::endl;
            drawPred(std::get<0>(objs[idx]), std::get<1>(objs[idx]), box.x, box.y,
                     box.x + box.width, box.y + box.height, frame);
        }
    #endif

        imshow(kWinName, frame);
    }
    return 0;
}

void drawPred(int classId, float conf, int left, int top, int right, int bottom, Mat& frame)
{
    rectangle(frame, Point(left, top), Point(right, bottom), Scalar(0, 255, 0));

    std::string label = format("%.2f", conf);
    if (!classes.empty())
    {
        CV_Assert((classId - 1) < (int)classes.size());
        label = classes[classId - 1] + ": " + label;
    }

    int baseLine;
    Size labelSize = getTextSize(label, FONT_HERSHEY_SIMPLEX, 0.5, 1, &baseLine);

    top = max(top, labelSize.height);
    rectangle(frame, Point(left, top - labelSize.height),
              Point(left + labelSize.width, top + baseLine), Scalar::all(255), FILLED);
    putText(frame, label, Point(left, top), FONT_HERSHEY_SIMPLEX, 0.5, Scalar());
}

inline float clip(float x) { return x < 0 ? 0 : (x > 1 ? 1 : x); }

std::vector<Object> readObjects(const Mat& prob, Size img_size, float thr)
{
    std::vector<Object> objs;
    const float* res = prob.ptr<float>();
    int obj_cnt = res[0];
    res += 64;
    for (int idx = 0; idx < obj_cnt; ++idx)
    {
        int class_id = res[7 * idx + 1];
        float confidence = res[7 * idx + 2];
        if (thr > 0.f && confidence < thr) continue;
        float l = clip(res[7 * idx + 3]);
        float r = clip(res[7 * idx + 5]);
        float t = clip(res[7 * idx + 4]);
        float b = clip(res[7 * idx + 6]);

        Rect roi;
        roi.x = l * img_size.width;
        roi.y = t * img_size.height;
        roi.width = (r - l) * img_size.width;
        roi.height = (b - t) * img_size.height;
        objs.emplace_back(class_id, confidence, roi);
    }
    return objs;
}

std::vector<std::vector<Object>> readObjects4N(const Mat& prob, Size img_size, float thr)
{
    std::vector<std::vector<Object>> batch_objs;
    const float* base = prob.ptr<float>();
    int n = prob.size[0];
    int h = prob.size[1];
    int w = prob.size[2];
    int c = prob.size[3];
    size_t step_size = h * w * c;

    for (int b_idx = 0; b_idx < n; ++b_idx) {
      std::vector<Object> objs;
      const float* res = base + b_idx * step_size;
      int obj_cnt = res[0];
      res += 64;
      for (int idx = 0; idx < obj_cnt; ++idx)
      {
          int class_id = res[7 * idx + 1];
          float confidence = res[7 * idx + 2];
          if (thr > 0.f && confidence < thr) continue;
          float l = clip(res[7 * idx + 3]);
          float r = clip(res[7 * idx + 5]);
          float t = clip(res[7 * idx + 4]);
          float b = clip(res[7 * idx + 6]);

          Rect roi;
          roi.x = l * img_size.width;
          roi.y = t * img_size.height;
          roi.width = (r - l) * img_size.width;
          roi.height = (b - t) * img_size.height;
          objs.emplace_back(class_id, confidence, roi);
      }
      batch_objs.emplace_back(std::move(objs));
    }
    return batch_objs;
}