Camunda Prometheus Exporter Coding Challenge
============================================
https://github.com/Dumberdore

What Is This?
-------------
This is a simple python app to a coding challenge. The aim of this coding challenge is to write a small Prometheus
Exporter app that returns
metric values for the count of Docker images pulls in a DockerHub organization and is
running in a Kubernetes cluster.

How TO Use This?
----------------

1. Make sure you have `Python 3.12.0` or later
2. Set following env variables-

   | Variable Name | Default Value |
   |:------------------------:|:-------------:|
   | `DOCKERHUB_ORGANIZATION` |   `camunda`   |
   |    `POLLING_SECONDS`     |     `600`     |
   |      `METRICS_PORT`      |    `2113`     |
3. Run `pip install -r requirements.txt` to setup dependencies
4. Run `python src/main.py `
5. Navigate to http://localhost:2113/metrics in your browser

Deploy As A Docker Container
----------------------------

1. Run `make build` to build docker image named `local.registry/camunda-app:1.0.0`
2. Run the image with `docker run -it -p 2113:2113 local.registry/camunda-app:1.0.0 `

Brief Note On Implementation
----------------------------
P8s-exporter is a minimal webserver which expose user-defined metrics to HTTP endpoint. This webserver running a forever
loop which makes GET requests to DockerHub url. Required fields (image_name, image_pull_count) are extracted from json
response and published as P8s Gauge.
