FROM openjdk:8-alpine

LABEL maintainer="Arseniy Tashoyan <tashoyan@gmail.com>"

RUN apk --update add git curl tar bash && \
    rm -rf /var/lib/apt/lists/* && \
    rm /var/cache/apk/*

ARG SBT_VERSION=0.13.13
ARG SBT_HOME=/usr/local/sbt-launcher-packaging-$SBT_VERSION
RUN curl -sL "http://dl.bintray.com/sbt/native-packages/sbt/$SBT_VERSION/sbt-$SBT_VERSION.tgz" | tar -xz -C /usr/local

ARG SPARK_VERSION=2.2.0
ARG SPARK_HOME=/usr/local/spark-$SPARK_VERSION
RUN curl -sL "http://www-us.apache.org/dist/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop2.7.tgz" | tar -xz -C /usr/local

ENV PATH $PATH:$SBT_HOME/bin:$SPARK_HOME/bin

# Hardcoded URL and local path
# Assembly, fallback to package
ENV SPARK_MASTER local[*]
CMD echo "Cloning the repository" && \
  git clone https://github.com/tashoyan/sc.git && \
  echo "Building the jar" && \
  cd sc/05-functional-programming-in-scala-capstone/observatory/ && \
  sbt clean assembly && \
  echo "Running the application" && \
  spark-submit --master "$SPARK_MASTER" --class "$MAIN_CLASS" "$(find target/ -type f -name *-assembly*.jar)"
