FROM golang:1.9.1-alpine3.6

# Install OpenCV
RUN echo -e '@edgunity http://nl.alpinelinux.org/alpine/edge/community\n\
@edge http://nl.alpinelinux.org/alpine/edge/main\n\
@testing http://nl.alpinelinux.org/alpine/edge/testing\n\
@community http://dl-cdn.alpinelinux.org/alpine/edge/community'\
  >> /etc/apk/repositories

RUN apk add --update --no-cache \
      build-base \
      openblas-dev \
      unzip \
      wget \
      cmake \
      libtbb@testing  \
      libtbb-dev@testing   \
      libjpeg  \
      libjpeg-turbo-dev \
      libpng-dev \
      jasper-dev \
      tiff-dev \
      libwebp-dev \
      clang-dev \
      linux-headers

ENV CC /usr/bin/clang
ENV CXX /usr/bin/clang++

ENV OPENCV_VERSION=3.3.0

RUN mkdir /opt && cd /opt && \
  wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip && \
  unzip ${OPENCV_VERSION}.zip && \
  rm -rf ${OPENCV_VERSION}.zip

RUN mkdir -p /opt/opencv-${OPENCV_VERSION}/build && \
  cd /opt/opencv-${OPENCV_VERSION}/build && \
  cmake \
  -D CMAKE_BUILD_TYPE=RELEASE \
  -D CMAKE_INSTALL_PREFIX=/usr/local \
  -D WITH_FFMPEG=NO \
  -D WITH_IPP=NO \
  -D WITH_OPENEXR=NO \
  -D WITH_TBB=YES \
  -D BUILD_EXAMPLES=NO \
  -D BUILD_ANDROID_EXAMPLES=NO \
  -D INSTALL_PYTHON_EXAMPLES=NO \
  -D BUILD_DOCS=NO \
  -D BUILD_opencv_python2=NO \
  -D BUILD_opencv_python3=NO \
  .. && \
  make VERBOSE=1 && \
  make && \
  make install && \
  rm -rf /opt/opencv-${OPENCV_VERSION}

# Add the watchdog
RUN apk --no-cache add curl \ 
    && echo "Pulling watchdog binary from Github." \
    && curl -sSL https://github.com/openfaas/faas/releases/download/0.6.9/fwatchdog > /usr/bin/fwatchdog \
    && chmod +x /usr/bin/fwatchdog \
    && apk del curl --no-cache

WORKDIR /go/src/handler
COPY . .

# Flags for GoCV
ENV CC=""
ENV CXX=""
ENV CGO_CPPFLAGS="-I/usr/local/include"
ENV CGO_CXXFLAGS="--std=c++1z"
ENV CGO_LDFLAGS="-L/usr/local/lib -lopencv_features2d -lopencv_core -lopencv_videoio -lopencv_imgproc -lopencv_highgui -lopencv_imgcodecs -lopencv_objdetect -lopencv_calib3d -lopencv_video"

RUN env

RUN go build -o handler .

FROM alpine:3.6

RUN echo -e '@edgunity http://nl.alpinelinux.org/alpine/edge/community\n\
@edge http://nl.alpinelinux.org/alpine/edge/main\n\
@testing http://nl.alpinelinux.org/alpine/edge/testing\n\
@community http://dl-cdn.alpinelinux.org/alpine/edge/community'\
  >> /etc/apk/repositories

RUN apk --no-cache add ca-certificates libstdc++ libjpeg libtbb@testing libpng jasper-libs tiff openblas libwebp

# Add non root user
RUN addgroup -S app && adduser -S -g app app
RUN mkdir -p /home/app
RUN chown app /home/app

# Copy OpenCV Libs
COPY --from=0 /usr/local/lib /usr/local/lib
COPY --from=0 /usr/local/include /usr/local/include

WORKDIR /home/app
COPY --from=0 /go/src/handler/cascades   ./cascades
COPY --from=0 /go/src/handler/handler    .
COPY --from=0 /usr/bin/fwatchdog         .

RUN chown -R app ./cascades

USER app

ENV CGO_CPPFLAGS="-I/usr/local/include"
ENV CGO_CXXFLAGS="--std=c++1z"
ENV CGO_LDFLAGS="-L/usr/local/lib -lopencv_features2d -lopencv_core -lopencv_videoio -lopencv_imgproc -lopencv_highgui -lopencv_imgcodecs -lopencv_objdetect -lopencv_calib3d -lopencv_video"
ENV fprocess="./handler"

CMD ["./fwatchdog"]
