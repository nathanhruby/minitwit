FROM python:3.8-alpine AS builder

WORKDIR /app
EXPOSE 5000
ENV FLASK_APP "minitwit"
ENV FLASK_RUN_HOST "0.0.0.0"
ENV FLASK_RUN_PORT "5000"
ENV MINITWIT_SETTINGS "/app/configs/minitwit.docker.conf"
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["flask", "run"]

RUN apk add --no-cache dumb-init
COPY . /app
RUN pip install --editable . && \
    mkdir db

