#
# Dockerfile that builds rtl_433
#
# The container requires priviliged access to /dev/bus/usb on the host allowing communication with the tuner.
#
# docker run --name rtl_433 -d --privileged -v /dev/bus/usb:/dev/bus/usb <image> [rtl_433 args]

FROM ubuntu:20.04 AS builder

LABEL Description="This image is used to start rtl_433"

#
# First install software packages needed to compile rtl_433
#
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
	rtl-sdr \
	librtlsdr-dev \
	librtlsdr0 \
	git \
	automake \
	libtool \
	cmake

COPY . rtl_433
RUN cd rtl_433 && mkdir build \
	&& cd build \
	&& cmake ../ \
	&& make \
	&& make install

FROM ubuntu:20.04

RUN apt-get update && apt-get install -y librtlsdr0 && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bin/rtl_433 /usr/local/bin/
COPY --from=builder /usr/local/include/rtl_433.h /usr/local/include/rtl_433.h
COPY --from=builder /usr/local/include/rtl_433_devices.h /usr/local/include/rtl_433_devices.h
COPY --from=builder /usr/local/etc/rtl_433/ /usr/local/etc/rtl_433/
COPY --from=builder /usr/local/share/man/man1/rtl_433.1 /usr/local/share/man/man1/rtl_433.1

ENTRYPOINT ["/usr/local/bin/rtl_433"]
