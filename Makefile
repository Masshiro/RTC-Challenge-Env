# docker_image := challenge-env
# docker_file := dockers/Dockerfile

# all: challenge-env

# challenge-env:
# 	docker pull opennetlab.azurecr.io/alphartc
# 	docker image tag opennetlab.azurecr.io/alphartc alphartc
# 	docker build . --build-arg UID=$(shell id -u) --build-arg GUID=$(shell id -g) -f $(docker_file) -t ${docker_image}


docker_image := challenge-env
docker_file_azure := dockers/Dockerfile.azure
docker_file_source := dockers/Dockerfile.source
build_from ?= azure  # 默认值为 azure
build_from := $(strip $(build_from))

ifneq ($(build_from),azure)
ifneq ($(build_from),source)
$(error Unsupported build_from value: $(build_from))
endif
endif

all: $(build_from)

azure:
	docker pull opennetlab.azurecr.io/alphartc
	docker image tag opennetlab.azurecr.io/alphartc alphartc
	docker build . --build-arg UID=$(shell id -u) --build-arg GUID=$(shell id -g) -f $(docker_file_azure) -t ${docker_image}

source:
	docker build . --build-arg UID=$(shell id -u) --build-arg GUID=$(shell id -g) -f $(docker_file_source) -t ${docker_image}

clean:
	docker rmi -f ${docker_image}