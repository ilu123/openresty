FROM bitnami/openresty:latest

USER root

RUN apt update && apt install -y unzip wget vim make gcc

WORKDIR /opt/bitnami/openresty/lualib/resty

RUN wget https://github.com/ilu123/lua-resty-s3-client/archive/refs/heads/master.zip && \
    unzip master.zip && \
    mv lua-resty-s3-client-master/lib/resty/aws_s3 aws_s3 && \
    rm -rf lua-resty-s3-client* master.zip
    
RUN wget https://github.com/ilu123/lua-resty-awsauth/archive/refs/heads/master.zip && \
    unzip master.zip && \
    mv lua-resty-awsauth-master/lib/resty/awsauth awsauth && \
    rm -rf lua-resty-awsauth-master master.zip


WORKDIR /opt/bitnami/openresty/lualib/

RUN wget https://github.com/bsc-s2/lua-acid/archive/refs/heads/master.zip && \
    unzip master.zip && \
    mv lua-acid-master/lib/acid acid && \
    rm -rf lua-acid-master master.zip

RUN wget https://luarocks.github.io/luarocks/releases/luarocks-3.9.2.tar.gz && \
    tar -xzvf luarocks-3.9.2.tar.gz && \
    cd luarocks-3.9.2 && \
    ./configure --prefix=/opt/bitnami/openresty/luajit \
    --with-lua=/opt/bitnami/openresty/luajit/ \
    --lua-suffix=jit \
    --with-lua-include=/opt/bitnami/openresty/luajit/include/luajit-2.1 && \
    make && make install && rm -rf  luarocks-3.9.2*

RUN luarocks install lua-yaml