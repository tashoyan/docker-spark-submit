# docker-spark-submit
Docker image to submit Spark applications

Build the image:
```
docker build -t spark-submit .
```
Build the image on a machine behind proxy:
```
docker build --build-arg http_proxy=http://my.proxy.com:8080 -t spark-submit .
```
Run the container:
```
docker run -ti --rm --name spark-submit -e SCM_URL="https://github.com/mylogin/project.git" -e SPARK_MASTER="spark://my.master.com:7077" -e MAIN_CLASS="Main" spark-submit

```
TODO Table
PROJECT_SUBDIR=
TODO -v /home/cloud-user:/root

Run the container on a machine behind proxy:
```
docker run -ti --rm --name spark-submit -e SPARK_MASTER="spark://my.master.com:7077" -e MAIN_CLASS="Main" -e https_proxy=http://my.proxy.com:8080 spark-submit
```
Specify a branch to build from:
```
docker run -ti --rm --name spark-submit -e SPARK_MASTER="spark://my.master.com:7077" -e MAIN_CLASS="Main" -e SCM_BRANCH="hotfix" spark-submit
```
Skip tests during build:
```
docker run -ti --rm --name spark-submit -e SPARK_MASTER="spark://my.master.com:7077" -e MAIN_CLASS="Main" -e SKIP_TESTS="1" spark-submit
```
