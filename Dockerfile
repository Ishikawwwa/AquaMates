FROM ubuntu:latest

RUN apt-get update
RUN apt-get install -y curl git unzip zip nginx

RUN git clone --single-branch --branch stable https://github.com/Ishikawwwa/AquaMates.git
RUN cd /flutter
ENV PATH "$PATH:/flutter/bin:/flutter/bin/cache/dart-sdk/bin"

RUN flutter channel beta
RUN flutter upgrade
RUN flutter config --enable-web
COPY ./aqua_mates /app
WORKDIR /app

RUN flutter pub get
RUN flutter build web --target=lib/main.dart

RUN cp -r build/web/* /var/www/html
CMD ["nginx", "-g", "daemon off;"]