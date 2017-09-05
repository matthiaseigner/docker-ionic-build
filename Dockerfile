FROM node:8.3
# based on https://github.com/netizy/docker-ionic-2

# auto validate license
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections

# update repos
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list \
    && echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886 \
    && apt-get update

# install java
RUN apt-get install oracle-java8-installer -y \
    && apt-get clean

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

RUN apt-get update \
    && apt-get install -y git sudo unzip \
    && npm install -g cordova ionic meteor-client-bundler \
    && npm cache clear --force

# Install Deps
RUN dpkg --add-architecture i386 && apt-get update && apt-get install -y --force-yes expect git wget libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1 python curl libqt5widgets5 && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# To know all possibilities, just run: android list sdk --all
# Install Android SDK
RUN cd /opt && wget https://dl.google.com/android/repository/tools_r25.2.3-linux.zip \
    && unzip tools_r25.2.3-linux.zip -d android-sdk-linux \
    && rm tools_r25.2.3-linux.zip \
    && (echo y | android-sdk-linux/tools/android update sdk -u -a -t 1,2,3,6,10,14,16,23,32,33,34,35,36,38,124,160,166,167,168,169,170,171,172) \
    && cd /opt/android-sdk-linux/tools/bin \
    && echo "count=0" > ~/.android/repositories.cfg \
    && ./sdkmanager "platforms;android-25" \
    && yes|./sdkmanager --update

ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools


## install gradle
RUN cd /opt \
    && curl https://services.gradle.org/distributions/gradle-4.1-bin.zip -o gradle-bin.zip -L \
    && ls -al \
    && pwd \
    && unzip gradle-bin.zip -d gradle \
    && rm gradle-bin.zip

ENV PATH $PATH:/opt/gradle/gradle-4.1/bin

RUN adduser meteor

RUN echo "meteor ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN chown -R meteor:meteor /opt/android-sdk-linux

RUN mkdir /src/ \
    && cp -R ~/.android /home/meteor/.android \
    && chown meteor:meteor /home/meteor/.android -R

USER meteor

# install meteor
RUN curl https://install.meteor.com/ | sh
