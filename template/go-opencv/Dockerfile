FROM nicholasjackson/go-opencv:1.9.1

# Add the watchdog
RUN apk --no-cache add curl curl-dev \
    && echo "Pulling watchdog binary from Github." \
    && curl -g https://github.com/openfaas/faas/releases/download/0.6.9/fwatchdog > /usr/bin/fwatchdog \
    && chmod +x /usr/bin/fwatchdog \
    && apk del curl curl-dev --no-cache

WORKDIR /go/src/handler
COPY . .

# Flags for GoCV
ENV CC=""
ENV CXX=""
ENV CGO_CPPFLAGS="-I/usr/local/include"
ENV CGO_CXXFLAGS="--std=c++1z"
ENV CGO_LDFLAGS="-L/usr/local/lib -lopencv_features2d -lopencv_core -lopencv_videoio -lopencv_imgproc -lopencv_highgui -lopencv_imgcodecs -lopencv_objdetect -lopencv_calib3d -lopencv_video"

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
