#!/bin/sh

set -o nounset
set -o errexit

docker build --build-arg http_proxy=http://web-proxy.gre.hpecorp.net:8080 -t spark-submit .

docker run \
  -ti \
  --rm \
  -p 5001:5001 \
  -p 5002:5002 \
  -p 5003:5003 \
  --name spark-submit \
  -v /home/cloud-user/data:/home/cloud-user/data \
  -e SPARK_MASTER="spark://16.17.90.70:7077" \
  -e MAIN_CLASS="image.Generator0S" \
  -e SPARK_DRIVER_HOST="16.17.90.70" \
  -e SCM_URL="https://github.com/tashoyan/sc.git" \
  -e SCM_BRANCH="spark" \
  -e PROJECT_SUBDIR="05-functional-programming-in-scala-capstone/observatory" \
  -e SKIP_TESTS="1" \
  -e https_proxy="http://web-proxy.gre.hpecorp.net:8080" \
  spark-submit
