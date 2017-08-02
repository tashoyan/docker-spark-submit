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
docker run -ti --rm --name spark-submit -e SPARK_MASTER="spark://my.master.com:7077" -e MAIN_CLASS="image.Generator0S" spark-submit
```
Run the container on a machine behind proxy:
```
docker run -ti --rm --name spark-submit -e SPARK_MASTER="spark://my.master.com:7077" -e MAIN_CLASS="image.Generator0S" -e https_proxy=http://my.proxy.com:8080 spark-submit
```
