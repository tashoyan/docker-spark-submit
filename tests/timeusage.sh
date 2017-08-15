#!/bin/sh

set -o nounset
set -o errexit

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
  -e SPARK_MASTER="spark://16.17.90.70:7077" \
  -e MAIN_CLASS="timeusage.TimeUsage" \
  -e SPARK_DRIVER_HOST="16.17.90.70" \
  -e https_proxy="http://web-proxy.gre.hpecorp.net:8080" \
  tashoyan/docker-spark-submit:spark-2.2.0
