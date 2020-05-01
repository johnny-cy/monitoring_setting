FROM nginx:stable

#RUN apt-get -o Acquire::Check-Valid-Until=false update 
COPY ./misc/ /tmp
RUN dpkg -i /tmp/libcap2_1%3a2.25-1.2_arm64.deb \
    && dpkg -i /tmp/libidn11_1.33-2.1ubuntu1.2_arm64.deb \
    && dpkg -i /tmp/iputils-ping_3%3a20161105-1ubuntu3_arm64.deb
