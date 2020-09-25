FROM hashicorp/terraform:0.13.3

RUN  echo http://dl-cdn.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories && \
  apk update && \
  apk upgrade 

ENTRYPOINT /bin/sh
