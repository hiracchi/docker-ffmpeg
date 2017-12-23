PACKAGE=ffmpeg

.PHONY: build

build:
	docker build -t "hiracchi/${PACKAGE}:latest" .

run:
	docker run -it --rm \
          "hiracchi/${PACKAGE}" /bin/bash

