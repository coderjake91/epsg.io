FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt update \
&& apt -y --no-install-recommends install \
software-properties-common \
gpg-agent \ 
curl \
python2.7 \
python2.7-dev \
gcc-aarch64-linux-gnu \ 
g++-aarch64-linux-gnu \
wget \
ca-certificates && update-ca-certificates && \
curl https://bootstrap.pypa.io/pip/2.7/get-pip.py | python2.7 && \
mkdir -p /var/www

# Set up necessary flags for ARM compatibility
ENV APPLY_LP2002043_UBUNTU_CFLAGS_WORKAROUND=1
ENV CPLUS_INCLUDE_PATH=/usr/include/gdal
ENV C_INCLUDE_PATH=/usr/include/gdal

RUN add-apt-repository ppa:ubuntugis/ppa && apt-get update && \
apt-get -y --no-install-recommends install gdal-bin libgdal-dev && \
pip install setuptools && \
pip install --global-option=build_ext --global-option="-I${C_INCLUDE_PATH}" GDAL && \
apt-cache policy gdal-bin && \
gdalinfo --version

COPY requirements.txt /tmp/requirements.txt
RUN pip install -q -r /tmp/requirements.txt

COPY . /var/www/epsg.io
VOLUME /var/www/epsg.io
WORKDIR /var/www/epsg.io

EXPOSE 8000
ENV FLASK_APP=/var/www/epsg.io/app.py
