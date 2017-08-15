#!/bin/sh

set -o nounset
set -o errexit

ip_addr="$(ifconfig | grep -Eo 'inet (addr:)?([0-9]+\.){3}[0-9]+' | grep -Eo '([0-9]+\.){3}[0-9]+' | grep -v '127.0.0.1')"
if test -z "$ip_addr"
then
  echo "Cannot determine the machine IP address."
  exit 1
fi

docker run \
  -ti \
  --rm \
  -p 5000-5010:5000-5010 \
  --name spark-submit \
  -v /data:/data \
  -e SCM_URL="https://github.com/tashoyan/sc.git" \
  -e SCM_BRANCH="spark" \
  -e PROJECT_SUBDIR="04-big-data-analysis-with-scala-and-spark/04-timeusage/timeusage" \
  -e BUILD_COMMAND="sbt clean package" \
  -e SPARK_MASTER="spark://localhost:7077" \
  -e SPARK_CONF="--conf spark.executor.memory=2g --conf spark.driver.cores=2" \
  -e JAR_FILE="target/scala-2.11/bigdata-timeusage_2.11-0.1-SNAPSHOT.jar" \
  -e MAIN_CLASS="timeusage.TimeUsage" \
  -e APP_ARGS="aaa bbb" \
  -e SPARK_DRIVER_HOST="$ip_addr" \
  -e https_proxy="http://web-proxy.gre.hpecorp.net:8080" \
  tashoyan/docker-spark-submit:spark-2.2.0
