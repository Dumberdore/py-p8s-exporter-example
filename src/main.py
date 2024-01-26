import logging
import os
import time

import prometheus_client as prom
import requests

#  Remove non-required metric-collectors
prom.REGISTRY.unregister(prom.PROCESS_COLLECTOR)
prom.REGISTRY.unregister(prom.PLATFORM_COLLECTOR)
prom.REGISTRY.unregister(prom.GC_COLLECTOR)


class DHMetrics:
    """
    Define metrics and implement logic to fetch the metrics
    Req:
        - The data return should not be older than 5 minutes:
    """

    def __init__(self, polling_interval_seconds=600):
        self.polling_interval_seconds = polling_interval_seconds
        self.stats = prom.Gauge(
            "docker_image_pulls", "The total number of Docker image pulls",
            ["image", "organization"])
        self.dh_org = (os.getenv("DOCKERHUB_ORGANIZATION", "camunda")).lower()

        self.reg = prom.CollectorRegistry()

    def loop(self):
        """Fetching loop"""

        while True:
            self.fetch()
            time.sleep(self.polling_interval_seconds)
            logging.info("Polling after %d!", self.polling_interval_seconds)

    def fetch(self):
        # self.docker_image_pulls.set(1000)
        self.stats.clear()
        image_pull_stats = self.get_image_pull_stats()

        for name, pull_count in image_pull_stats.items():
            self.stats.labels(name, self.dh_org).set(pull_count)

    def get_image_pull_stats(self):
        payload = {'page_size': '25', 'page': '1'}
        resp = requests.get(f'https://hub.docker.com/v2/repositories/{self.dh_org}', params=payload)
        result = dict()

        if resp.ok:
            for image in resp.json()['results']:
                result[image['name']] = image['pull_count']
        else:
            logging.error("Failed to make HTTP GET to %s", resp.url)

        return result


def main():
    logging.basicConfig(format='%(asctime)s - %(message)s', level=logging.INFO)

    polling_interval = int(os.getenv("POLLING_SECONDS", "600"))
    metrics_port = int(os.getenv("METRICS_PORT", "2113"))

    app_metrics = DHMetrics(polling_interval)

    logging.info("Starting webserver on http://localhost:%d/metrics", metrics_port)
    prom.start_http_server(metrics_port)
    app_metrics.loop()


if __name__ == "__main__":
    main()
