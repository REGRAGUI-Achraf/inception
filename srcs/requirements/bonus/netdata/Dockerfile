FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y netdata && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 19999

ENTRYPOINT ["/usr/sbin/netdata", "-D", "-i", "0.0.0.0", "-p", "19999"]
