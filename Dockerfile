FROM debian:bookworm-slim
SHELL ["/bin/bash", "-c"]

ARG GMAIL_USER
ARG LOCAL_USER_NAME

ENV GMAIL_USER=${GMAIL_USER}
ENV LOCAL_USER_NAME=${LOCAL_USER_NAME}

RUN echo "Using gmail user: ${GMAIL_USER}"
RUN echo "Using container user: ${LOCAL_USER_NAME}"

RUN apt-get update -qy
RUN apt-get install -qy \ 
                sudo \
                vim \
                git \
                rsync \
                wget \
                curl \
                gnupg \
                python3 \
                build-essential \
                bc \
                kmod \
                cpio \
			    flex \
                libncurses5-dev \
                libelf-dev \
                libssl-dev \
                dwarves \
                devscripts \
                kernel-wedge \
                pristine-lfs \
                python3-debian \
                quilt \
                reportbug \
                exim4 \
                podman

COPY conf/update-exim4.conf.conf /etc/exim4/update-exim4.conf.conf

RUN sudo echo "*.gmail.com:$GMAIL_USER:NOTSET" > /etc/exim4/passwd.client
RUN chown root:Debian-exim /etc/exim4/passwd.client
RUN chmod 640 /etc/exim4/passwd.client

RUN echo "${LOCAL_USER_NAME}: ${GMAIL_USER}" >> /etc/email-addresses
RUN echo "${LOCAL_USER_NAME}@localhost: ${GMAIL_USER}" >> /etc/email-addresses
#RUN echo "${LOCAL_USER_NAME}@hostname1: ${GMAIL_USER}" >> /etc/email-addresses
#RUN echo "${LOCAL_USER_NAME}@hostname1.localdomain: ${GMAIL_USER}" >> /etc/email-addresses

RUN update-exim4.conf
RUN invoke-rc.d exim4 restart
RUN exim4 -qff

RUN addgroup --system wheel \
    && adduser ${LOCAL_USER_NAME} --disabled-password --gecos ${LOCAL_USER_NAME} \
    && adduser ${LOCAL_USER_NAME} wheel \
    && adduser ${LOCAL_USER_NAME} sudo

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER ${LOCAL_USER_NAME}
WORKDIR /home/${LOCAL_USER_NAME}


