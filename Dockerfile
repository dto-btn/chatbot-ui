FROM ubuntu:22.04

RUN apt-get update && apt-get install -y git libglu1-mesa wget xz-utils 

RUN apt-get install clang cmake ninja-build pkg-config libgtk-3-dev

RUN wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.10.6-stable.tar.xz

RUN tar -xf /flutter_linux_3.10.6-stable.tar.xz 

ENV PATH="$PATH:/flutter/bin"

RUN mkdir /chatbot_ui

COPY ./chatbot_ui/ /chatbot_ui/

RUN git config --global --add safe.directory /flutter

WORKDIR /chatbot_ui

RUN flutter pub get

CMD flutter run