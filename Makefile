PACKAGE=ffmpeg

.PHONY: build

build:
	docker build -t "hiracchi/${PACKAGE}:latest" .

run:
	docker run -it --rm \
		--device=/dev/dri:/dev/dri \
		"hiracchi/${PACKAGE}" /bin/bash
