# docker-spark-submit

## Docker image to run Spark applications

Performs the following tasks:
1. Gets the source code from the SCM repository
1. Builds the application
1. Runs the application by submitting it to the Spark cluster

At present, only Git is supported for SCM and only Sbt is supported for build. Both `git` and `sbt` commands are expected in the PATH.

Run example:
```
docker run \
  -ti \
  --rm \
  -p 5000-5010:5000-5010 \
  -e SCM_URL="https://github.com/mylogin/project.git" \
  -e SPARK_MASTER="spark://my.master.com:7077" \
  -e SPARK_DRIVER_HOST="192.168.1.2" \
  -e MAIN_CLASS="Main" \
  tashoyan/docker-spark-submit:spark-2.2.0
```

## Important command line arguments

`-p 5000-5010:5000-5010`

You have to publish this range of network ports. Spark driver program and Spark executors use these ports for communication.

`-e SPARK_DRIVER_HOST="host.machine.address"`

You have to specify here the network address of the host machine where the container will be running. Spark cluster nodes
should be able to resolve this address. This is necessary for communication between executors and the driver program.

## Command line arguments

Command line arguments are passed via environment variables for `docker` command: `-e VAR="value"`. Here is the full list:

| Name | Mandatory? | Meaning | Default value |
| ---- |:----------:| ------- | ------------- |
| SCM_URL | Yes | URL to get source code from. | N/A |
| SCM_BRANCH | No | SCM branch to checkout. | master |
| PROJECT_SUBDIR | No | A relative directory to the root of the SCM working copy.<br>If specified, then the build will be executed in this directory, rather than in the root directory. | N/A |
| BUILD_COMMAND | No | Command to build the application. | `sbt 'set test in assembly := {}' clean assembly`<br>Means: build fat-jar using sbt-assembly plugin skipping the tests. |
| SPARK_MASTER | No | Spark master URL. | `local[*]` |
| SPARK_CONF | No | Arbitrary Spark configuration settings, like:<br>`--conf spark.executor.memory=2g --conf spark.driver.cores=2` | Empty |
| SPARK_DRIVER_HOST | Yes | Value of the `spark.driver.host` configuration parameter.<br>Must be set to the network address of the machine hosting the container. Must be accessible from Spark nodes. | N/A |
| JAR_FILE | No | Path to the application jar file. Relative to the build directory.<br> If not specified, the jar file will be automatically found under `target/` subdirectory of the build directory. | N/A |
| MAIN_CLASS | Yes | Main class of the application to run. | N/A |
| APP_ARGS | No | Application arguments. | Empty |
| http_proxy, https_proxy | No | Specify when running behind a proxy. | Empty, no proxy |

## Working with data

If your Spark program requires some data for processing, you can add the data to the container by specifying a volume:

```
docker run \
  -ti \
  --rm \
  -v /data:/data \
  -p 5000-5010:5000-5010 \
  -e SCM_URL="https://github.com/mylogin/project.git" \
  -e SPARK_MASTER="spark://my.master.com:7077" \
  -e SPARK_DRIVER_HOST="192.168.1.2" \
  -e MAIN_CLASS="Main" \
  tashoyan/docker-spark-submit:spark-2.2.0
```

## Available image tags

Image tags correspond to Spark versions. Choose the tag based on the version of your Spark cluster.
The following tags are available:
* spark-2.2.0
* spark-2.1.1

## Building the image

Build the image:
```
docker build \
  -t tashoyan/docker-spark-submit:spark-2.2.0 \
  -f Dockerfile.spark-2.2.0 \
  .
```
When building on a machine behind proxy, specify `http_proxy` environment variable:
```
docker build \
  --build-arg http_proxy=http://my.proxy.com:8080 \
  -t tashoyan/docker-spark-submit:spark-2.2.0 \
  -f Dockerfile.spark-2.2.0 \
  .
```

## License

Apache 2.0 license.
