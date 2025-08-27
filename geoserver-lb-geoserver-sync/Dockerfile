FROM python:3.13-alpine

# set fixed UID and GID - see github.com/hexops/dockerfile
ARG UID=10000
ARG GID=10001

RUN addgroup -g ${GID} gssync && \
    adduser -u ${UID} -D -h /app -s /bin/sh -G gssync gssync


# Work in dedicated folder
WORKDIR /app

RUN pip install requests
COPY sync.py sync.py

CMD ["python", "-u", "sync.py"]
