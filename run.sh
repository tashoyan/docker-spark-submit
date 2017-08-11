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

# TODO Assembly, fallback to package
echo "Building the jar"
if test -z "$PROJECT_SUBDIR"
then
  cd "$project_dir"
else
  cd "$project_dir/$PROJECT_SUBDIR"
fi
echo "Building at: $(pwd)"
if test -z "$SKIP_TESTS"
then
  sbt clean assembly
else
  sbt "set test in assembly := {}" clean assembly
fi

ip_addr="$(ifconfig | grep -Eo 'inet (addr:)?([0-9]+\.){3}[0-9]+' | grep -Eo '([0-9]+\.){3}[0-9]+' | grep -v '127.0.0.1')"

#TODO How to pass app args?
jarfile="$(find target/ -type f -name *-assembly*.jar)"
echo "Submitting jar: $jarfile"
echo "Main class: $MAIN_CLASS"
echo "Spark master: $SPARK_MASTER"
echo "Spark driver host: $SPARK_DRIVER_HOST"
echo "Spark driver port: $SPARK_DRIVER_PORT"
echo "Spark UI port: $SPARK_UI_PORT"
echo "Spark block manager port: $SPARK_BLOCKMGR_PORT"
spark-submit \
  --master "$SPARK_MASTER" \
  --conf spark.driver.bindAddress="$ip_addr" \
  --conf spark.driver.host="$SPARK_DRIVER_HOST" \
  --conf spark.driver.port=$SPARK_DRIVER_PORT \
  --conf spark.ui.port=$SPARK_UI_PORT \
  --conf spark.blockManager.port=$SPARK_BLOCKMGR_PORT \
  --class "$MAIN_CLASS" \
  $jarfile

