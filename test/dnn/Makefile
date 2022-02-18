
CFLAGS=-I /usr/local/neuware/include/ -I /usr/local/opencv-4.5.3/include/opencv4/ -I /usr/local/include -g  -std=c++11
CXXFLAGS=$(CFLAGS)

LDFALGS=-L /usr/local/neuware/lib64 -L /usr/local/opencv-4.5.3/lib -L /usr/local/lib

CXX=g++

SRCS=$(wildcard ./*.cpp)
OBJS=$(SRCS:%.cpp=%.o)

TARGET=dnn_test

all:$(TARGET)
#$(CXX) -o $@ $(OBJS) $(LDFALGS) -lopencv_core -lopencv_highgui -lopencv_imgproc -lopencv_videoio -lopencv_dnn
$(TARGET):$(OBJS)
	$(CXX) -o $@ $(OBJS) $(LDFALGS) -lopencv_core -lopencv_highgui -lopencv_imgproc -lopencv_videoio -lopencv_dnn

clean:
	rm  -f $(TARGET) $(OBJS)


