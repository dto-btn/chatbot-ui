FROM flutter:latest

WORKDIR /chatbot_ui

COPY pubspec.yaml /chatbot_ui/

RUN flutter pub get

RUN flutter run
