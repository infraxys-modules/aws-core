FROM alpine:latest

COPY entrypoint.sh /entrypoint.sh

RUN chmod a+x /entrypoint.sh

USER 2000:2000


ENTRYPOINT ["/entrypoint.sh"]
