FROM gliderlabs/alpine:3.4
# Maintainer
# ----------
MAINTAINER Marcelo Ochoa <mochoa@scotas.com>

RUN apk --no-cache add nginx && mkdir /run/nginx
# Oracle Linux 64Bits 12.1.0.2
COPY linuxamd64_12102_database_1of2.zip /var/lib/nginx/html
COPY linuxamd64_12102_database_2of2.zip /var/lib/nginx/html
# Oracle Linux XE 11.2.0
COPY oracle-xe-11.2.0-1.0.x86_64.rpm.zip /var/lib/nginx/html
# Oracle JDK 8b101
COPY server-jre-8u101-linux-x64.tar.gz /var/lib/nginx/html
# Oracle WebLogic 12.2.1.1.0
COPY fmw_12.2.1.1.0_wls_Disk1_1of1.zip /var/lib/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
