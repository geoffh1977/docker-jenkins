# Project Makefile
include container.conf
export $(shell sed 's/=.*//' container.conf)

.PHONY: build update run all clean

all: build

build:
	docker build -t ${dockerUser}/${finalImageName}:${finalImageVersion} --build-arg IMAGE_USER=${dockerUser} --build-arg IMAGE_NAME=${buildImageName} --build-arg IMAGE_VERSION=${buildImageVersion} --build-arg JENKINS_VERSION=${finalImageVersion} --build-arg JENKINS_SHA=${jenkinsSha256} .
	docker tag ${dockerUser}/${finalImageName}:${finalImageVersion} ${dockerUser}/${finalImageName}:latest

update:
	@tools/update_version.sh

run:
	$(call colors)
	@echo -e Starting Container...
	@docker run -it --rm --name consul -p 8400:8400 -p 8500:8500 -p 8600:8600/udp ${dockerUser}/${finalImageName}:${finalImageVersion}
	@echo -e Container Stopped

clean:
	docker rmi -f ${dockerUser}/${finalImageName}:latest
	docker rmi -f ${dockerUser}/${finalImageName}:${finalImageVersion}
