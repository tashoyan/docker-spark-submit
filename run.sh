#!/bin/sh

set -o errexit

test -z "$SCM_URL" && ( echo "SCM_URL is not set; exiting" ; exit 1 )
test -z "$SPARK_MASTER" && ( echo "SPARK_MASTER is not set; exiting" ; exit 1 )
test -z "$MAIN_CLASS" && ( echo "MAIN_CLASS is not set; exiting" ; exit 1 )
test -z "$SPARK_DRIVER_HOST" && ( echo "SPARK_DRIVER_HOST is not set; exiting" ; exit 1 )
test -z "$SPARK_DRIVER_PORT" && ( echo "SPARK_DRIVER_PORT is not set; exiting" ; exit 1 )
test -z "$SPARK_UI_PORT" && ( echo "SPARK_UI_PORT is not set; exiting" ; exit 1 )
test -z "$SPARK_BLOCKMGR_PORT" && ( echo "SPARK_BLOCKMGR_PORT is not set; exiting" ; exit 1 )

echo "Cloning the repository: $SCM_URL"
git clone "$SCM_URL"
project_git="${SCM_URL##*/}"
project_dir="${project_git%.git}"
if test -n "$SCM_BRANCH"
then
  cd "$project_dir"
  git checkout "$SCM_BRANCH"
  cd -
fi

echo "Building the jar"
if test -z "$PROJECT_SUBDIR"
then
  cd "$project_dir"
else
  cd "$project_dir/$PROJECT_SUBDIR"
fi
echo "Building at: $(pwd)"

if test -z "$BUILD_COMMAND"
then
  build_command="sbt 'set test in assembly := {}' clean assembly"
else
  build_command="$BUILD_COMMAND"
fi
echo "Building with command: $build_command"
eval $build_command

ip_addr="$(ifconfig | grep -Eo 'inet (addr:)?([0-9]+\.){3}[0-9]+' | grep -Eo '([0-9]+\.){3}[0-9]+' | grep -v '127.0.0.1')"
if test -z "$ip_addr"
then
  echo "Cannot determine the container IP address."
  exit 1
fi

if test -z "$JAR_FILE"
then
  jarfile="$(ls target/scala-*/*.jar)"
else
  jarfile="$JAR_FILE"
fi
if ! test -f "$jarfile"
then
  echo "Jar file not found or not a single file: $jarfile"
  echo "You can specify jar file explicitly: -e JAR_FILE=/path/to/file"
  exit 1
fi

echo "Submitting jar: $jarfile"
echo "Application main class: $MAIN_CLASS"
echo "Application arguments: $APP_ARGS"
echo "Spark master: $SPARK_MASTER"
echo "Spark driver host: $SPARK_DRIVER_HOST"
echo "Spark driver port: $SPARK_DRIVER_PORT"
echo "Spark UI port: $SPARK_UI_PORT"
echo "Spark block manager port: $SPARK_BLOCKMGR_PORT"
echo "Spark configuration settings: $SPARK_CONF"
spark-submit \
  --master "$SPARK_MASTER" \
  --conf spark.driver.bindAddress="$ip_addr" \
  --conf spark.driver.host="$SPARK_DRIVER_HOST" \
  --conf spark.driver.port=$SPARK_DRIVER_PORT \
  --conf spark.ui.port=$SPARK_UI_PORT \
  --conf spark.blockManager.port=$SPARK_BLOCKMGR_PORT \
  $SPARK_CONF \
  --class "$MAIN_CLASS" \
  "$jarfile" \
  $APP_ARGS
