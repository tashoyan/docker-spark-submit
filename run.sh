#!/bin/sh

set -o errexit

test -z "$SCM_URL" && ( echo "SCM_URL is not set; exiting" ; exit 1 )
test -z "$SPARK_MASTER" && ( echo "SPARK_MASTER is not set; exiting" ; exit 1 )
test -z "$MAIN_CLASS" && ( echo "MAIN_CLASS is not set; exiting" ; exit 1 )

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
if test -z "SKIP_TESTS"
then
  sbt clean assembly
else
  sbt "set test in assembly := {}" clean assembly
fi

echo "Running the application: $MAIN_CLASS at Spark master: $SPARK_MASTER"
jarfile="$(find target/ -type f -name *-assembly*.jar)"
spark-submit --master "$SPARK_MASTER" --class "$MAIN_CLASS" $jarfile

