FROM alpine

ENV JDEMAIL shakugan@disbox.net
ENV JDPASSWORD AliAly032230
ENV JDDEVICENAME JDownloader

RUN apk update &&  apk upgrade && apk upgrade &&  apk add openjdk21 tini su-exec shadow ffmpeg jq

RUN addgroup alpine
RUN adduser -D alpine -G alpine -u 1000 alpine
RUN echo "root:AliAly032230" | /usr/sbin/chpasswd \
    && 	echo "alpine:AliAly032230" | /usr/sbin/chpasswd \
    && 	echo "alpine ALL=(ALL) ALL" >> /etc/sudoers 
RUN chown -R alpine:alpine /home/alpine/

WORKDIR /home/alpine/

RUN mkdir Downloads
RUN wget http://installer.jdownloader.org/JDownloader.jar && chmod +x JDownloader.jar
RUN wget https://github.com/sorenisanerd/gotty/releases/download/v1.5.0/gotty_v1.5.0_linux_amd64.tar.gz && tar -xf gotty_v1.5.0_linux_amd64.tar.gz && rm -rf gotty_v1.5.0_linux_amd64.tar.gz && chmod +x gotty && mv gotty /usr/local/bin/gotty
RUN wget https://github.com/cloudflare/cloudflared/releases/download/2024.2.0/cloudflared-linux-amd64 && chmod +x cloudflared-linux-amd64 && mv cloudflared-linux-amd64 cloudflared && mv cloudflared /usr/local/bin/cloudflared
RUN tar -xvzf https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz -C /usr/local/bin && ngrok config add-authtoken 2cdcqEH4bvsYaxCd3gJ5CQTm6KA_244R59c8eGZaj8RdkXFti
RUN java -jar JDownloader.jar -norestart 
RUN echo "{\"devicename\" : \"$JDDEVICENAME\", \"autoconnectenabledv2\" : true, \"password\" : \"$JDPASSWORD\", \"email\" : \"$JDEMAIL\"}" > ./cfg/org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json

USER alpine
EXPOSE 3129 12345

ENTRYPOINT /usr/local/bin/gotty -p 12345 -w bash --reconnect && /usr/local/bin/ngrok http 12345 && java -jar JDownloader.jar -norestart 
