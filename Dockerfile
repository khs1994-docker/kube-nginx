FROM alpine:3.11

ENV NGINX_VERSION=1.17.7

RUN sed -i "s/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g" /etc/apk/repositories \
    && apk add --no-cache --virtual .build_deps \
               gcc \
               make \
               libc-dev \
               curl \
    && curl -fsSL -O https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && tar -zxvf nginx-${NGINX_VERSION}.tar.gz \
    && cd nginx-${NGINX_VERSION} \
    && ./configure --prefix=/opt/k8s/kube-nginx \
        --with-stream --without-http \
        --without-http_uwsgi_module \
        --without-http_scgi_module --without-http_fastcgi_module \
    && make \
    && make install \
    && rm -rf nginx-${NGINX_VERSION}.tar.gz \
              nginx-${NGINX_VERSION} \
    && apk del .build_deps \
    && ln -sf /dev/stdout /opt/k8s/kube-nginx/logs/access.log \
    && ln -sf /dev/stderr /opt/k8s/kube-nginx/logs/error.log

EXPOSE 18443

STOPSIGNAL SIGTERM

ENTRYPOINT ["/opt/k8s/kube-nginx/sbin/nginx","-c","/opt/k8s/kube-nginx/conf/kube-nginx.conf","-p","/opt/k8s/kube-nginx"]

CMD ["-g", "daemon off;"]
