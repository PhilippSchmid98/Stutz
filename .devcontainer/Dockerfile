# Offizielles Ubuntu-Image nutzen
FROM ubuntu:22.04

# Grundlegende Systemwerkzeuge aus den offiziellen Ubuntu-Repositories installieren
RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa openjdk-17-jdk wget \
    && rm -rf /var/lib/apt/lists/*

# Umgebungsvariablen für Android und Flutter definieren
ENV ANDROID_HOME=/opt/android-sdk
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$FLUTTER_HOME/bin"

# 1. Android SDK von den offiziellen Google-Servern herunterladen
RUN mkdir -p $ANDROID_HOME/cmdline-tools \
    && wget -q https://dl.google.com/android/repository/commandlinetools-linux-15859902_latest.zip -O android-tools.zip \
    && unzip -q android-tools.zip -d $ANDROID_HOME/cmdline-tools \
    && mv $ANDROID_HOME/cmdline-tools/cmdline-tools $ANDROID_HOME/cmdline-tools/latest \
    && rm android-tools.zip

# Lizenzen akzeptieren und Plattform-Tools installieren
RUN yes | sdkmanager --licenses \
    && sdkmanager "platform-tools" "platforms;android-36" "build-tools;36.0.0"

# 2. Flutter direkt aus dem offiziellen GitHub-Repository klonen
RUN git clone --depth 1 -b stable https://github.com/flutter/flutter.git $FLUTTER_HOME \
    && flutter precache

# Container am Leben halten
CMD ["sleep", "infinity"]