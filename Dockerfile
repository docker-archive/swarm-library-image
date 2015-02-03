FROM scratch

COPY ./swarm /swarm
COPY ./certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

EXPOSE 2375
VOLUME /.swarm

ENTRYPOINT ["/swarm"]
CMD ["--help"]
