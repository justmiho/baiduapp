#FROM registry.cn-beijing.aliyuncs.com/dmka/jdk8:latest
FROM --platform=amd64 registry.baidubce.com/netdisk/openjdk:8-nginx
LABEL MAINTAINER nas-file

#RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
#    && apk update \
#    && apk add --no-cache tzdata \
#    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
#    && echo "Asia/Shanghai" > /etc/timezone \
#    && apk del tzdata

COPY target/*.jar app.jar
COPY application.yml /application.yml
COPY sh/* /sh/
COPY linux_amd64/* /sdk/

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY dist/ /usr/share/nginx/html/
COPY machine-id /etc/machine-id

COPY endpoint.sh /endpoint.sh
CMD ["/bin/sh"]
ENTRYPOINT ["/endpoint.sh"]
