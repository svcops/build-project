ARG NGINX_VERSION=1.27.4

FROM registry.cn-shanghai.aliyuncs.com/iproute/ubuntu:22.04 AS builder
ARG NGINX_VERSION
# 安装构建依赖
RUN apt-get update && apt-get install -y \
    dirmngr \
    gpg \
    gpg-agent \
    curl \
    build-essential \
    libpcre3-dev \
    zlib1g-dev \
    libperl-dev \
    libssl-dev \
    libxslt1-dev \
    libgeoip-dev \
    libgd-dev \
    libmaxminddb-dev \
    git \
    wget \
    cmake

# 下载 Nginx 源码
RUN wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
    tar -xzf nginx-${NGINX_VERSION}.tar.gz

# 下载并安装 Nginx 模块
# 使用 git clone 获取所需模块
#RUN git clone https://github.com/vozlt/nginx-module-vts.git /nginx-module-vts && \
#    git clone https://github.com/leev/ngx_http_geoip2_module.git /ngx_http_geoip2_module && \
#    git clone https://github.com/yaoweibin/ngx_http_substitutions_filter_module.git /ngx_http_substitutions_filter_module && \
#    git clone https://github.com/google/ngx_brotli.git /ngx_brotli && \
#    cd /ngx_brotli && git submodule update --init

# 使用预下载的模块
COPY modules/nginx-module-vts /nginx-module-vts
COPY modules/ngx_http_geoip2_module /ngx_http_geoip2_module
COPY modules/ngx_http_substitutions_filter_module /ngx_http_substitutions_filter_module
COPY modules/ngx_brotli /ngx_brotli

# 编译 Nginx (使用标准路径)
RUN cd nginx-${NGINX_VERSION} && \
    ./configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-compat \
    --with-file-aio \
    --with-threads \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-http_v3_module \
    --with-http_geoip_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-stream \
    --with-stream_realip_module \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-cc-opt='-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIC -Wno-stringop-overread' \
    --with-ld-opt='-Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie' \
    --add-module=/nginx-module-vts \
    --add-dynamic-module=/ngx_http_geoip2_module \
    --add-module=/ngx_http_substitutions_filter_module \
    --add-dynamic-module=/ngx_brotli \
    && make && make install

# 最终镜像
FROM registry.cn-shanghai.aliyuncs.com/iproute/nginx:${NGINX_VERSION}
USER root

# 创建 nginx 用户和组
RUN addgroup --system nginx && \
    adduser --system --disabled-login --ingroup nginx --no-create-home --home /nonexistent --gecos "nginx user" --shell /bin/false nginx

# 备份原始配置
RUN mkdir -p /etc/nginx.bak && \
    if [ -d /etc/nginx ]; then cp -r /etc/nginx/* /etc/nginx.bak/; fi

## 确保所有相关的库都被复制
#COPY --from=builder /lib/x86_64-linux-gnu/ /lib/x86_64-linux-gnu/
#COPY --from=builder /usr/lib/x86_64-linux-gnu/ /usr/lib/x86_64-linux-gnu/

# 只复制 NGINX 运行所需的特定共享库
COPY --from=builder /lib/x86_64-linux-gnu/libpcre.so.3 /lib/x86_64-linux-gnu/
COPY --from=builder /lib/x86_64-linux-gnu/libz.so.1 /lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libssl.so.3* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libcrypto.so.3* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libGeoIP.so.1* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libmaxminddb.so.0* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libxslt.so.1* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libexslt.so.0* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libgd.so.3* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libjpeg.so.8* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libpng16.so.16* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libfreetype.so.6* /usr/lib/x86_64-linux-gnu/


# 复制编译好的 Nginx 文件
COPY --from=builder /etc/nginx /etc/nginx
COPY --from=builder /usr/sbin/nginx /usr/sbin/
COPY --from=builder /usr/lib/nginx /usr/lib/nginx

# 创建必要的目录
RUN mkdir -p /var/log/nginx \
             /var/cache/nginx/client_temp \
             /var/cache/nginx/proxy_temp \
             /var/cache/nginx/fastcgi_temp \
             /var/cache/nginx/uwsgi_temp \
             /var/cache/nginx/scgi_temp \
             /var/run

# 如果存在原始配置，可以选择性恢复
RUN if [ -d /etc/nginx.bak ]; then \
      cp -rn /etc/nginx.bak/conf.d /etc/nginx/ 2>/dev/null || true; \
      cp -rn /etc/nginx.bak/templates /etc/nginx/ 2>/dev/null || true; \
      if [ ! -f /etc/nginx/nginx.conf.default ]; then \
        mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.default 2>/dev/null || true; \
        cp /etc/nginx.bak/nginx.conf /etc/nginx/ 2>/dev/null || true; \
      fi; \
      rm -rf /etc/nginx.bak; \
    fi

# 确保目录权限正确
RUN chown -R nginx:nginx /var/log/nginx /var/cache/nginx /etc/nginx && \
    chmod -R 755 /var/cache/nginx

# 创建转发脚本 (可选：如果您想保持与原镜像的兼容性)
RUN mkdir -p /opt/bitnami/nginx/bin && \
    echo '#!/bin/sh' > /opt/bitnami/nginx/bin/nginx && \
    echo 'exec /usr/sbin/nginx "$@"' >> /opt/bitnami/nginx/bin/nginx && \
    chmod +x /opt/bitnami/nginx/bin/nginx

# 创建符号链接以保持兼容性 (可选)
RUN ln -sf /etc/nginx /opt/bitnami/nginx/conf && \
    ln -sf /var/log/nginx /opt/bitnami/nginx/logs && \
    ln -sf /var/run /opt/bitnami/nginx/tmp && \
    ln -sf /usr/lib/nginx/modules /opt/bitnami/nginx/modules

# 验证配置
RUN nginx -t

# 设置启动命令
CMD ["nginx", "-g", "daemon off;"]

# 如果您需要以非 root 用户运行
USER nginx