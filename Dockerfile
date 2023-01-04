FROM tinygo/tinygo

ENV DEBIAN_FRONTEND noninteractive
ENV PATH="$PATH:/opt/gcc-arm-none-eabi/bin"

USER root

WORKDIR /tmp

RUN apt update \
    && apt install -y git curl make libtool pkgconf autoconf automake \
    texinfo libusb-1.0-0 libusb-1.0-0-dev libjaylink0 gdb-multiarch \
    libncursesw5 build-essential checkinstall libreadline-dev tk-dev \
    libncursesw5-dev libssl-dev libsqlite3-dev libgdbm-dev \
    libc6-dev libbz2-dev libffi-dev zlib1g-dev \
    && ln -s /lib/x86_64-linux-gnu/libncursesw.so.5.9 /usr/lib/libncursesw.so.5 \
    && apt -y clean \
    && apt -y autoremove \
    && rm -rf /var/lib/apt/lists/* \
    && curl -o Python-3.8.16.tgz https://www.python.org/ftp/python/3.8.16/Python-3.8.16.tgz \
    && tar xzf Python-3.8.16.tgz \
    && cd Python-3.8.16 \
    && ./configure --enable-optimizations \
    && make install \
    && cd .. \
    && rm -rf Python-3.8.16

RUN git clone --branch rp2040 --recursive --depth=1  https://github.com/raspberrypi/openocd.git  \
    && cd openocd \
    && ./bootstrap \
    && ./configure \
    && make \
    && make install \
    && cd .. \
    && rm -rf openocd


RUN ARM_TOOLCHAIN_VERSION=$(curl -s https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads | grep -Po '<h4>Version \K.+(?=</h4>)') \
    && curl -Lo gcc-arm-none-eabi.tar.xz "https://developer.arm.com/-/media/Files/downloads/gnu/${ARM_TOOLCHAIN_VERSION}/binrel/arm-gnu-toolchain-${ARM_TOOLCHAIN_VERSION}-x86_64-arm-none-eabi.tar.xz" \
    && mkdir /opt/gcc-arm-none-eabi \
    && tar xf gcc-arm-none-eabi.tar.xz --strip-components=1 -C /opt/gcc-arm-none-eabi \
    && rm -rf gcc-arm-none-eabi.tar.xz

RUN go install -v golang.org/x/tools/gopls@latest  \
    && go install -v github.com/go-delve/delve/cmd/dlv@latest \
    && bash -c "ln -s $(tinygo info | grep GOROOT | cut -d':' -f2 | xargs) /root/.cache/tinygo/goroot"

WORKDIR /
