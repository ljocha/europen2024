image=cerit.io/ljocha/europen2024
tag=3

port=9000

push: build
	docker push ${image}:${tag}

build:
	docker build --platform linux/amd64 -t ${image}:${tag} .

force:
	docker build --platform linux/amd64 --no-cache -t ${image}:${tag} .

bash:
	docker run --rm -v ${PWD}:/work -w /work -u $(shell id -u) -ti ${image}:${tag} bash

root:
	docker run --rm -v ${PWD}:/work -w /work -u 0 -ti ${image}:${tag} bash

jovyan:
	docker run --rm -v ${PWD}:/work -ti -p ${port}:${port} ${image}:${tag} bash

lab:
	docker run --rm -v ${PWD}:/work -w /work -ti -p ${port}:${port} ${image}:${tag} jupyter lab --ip 0.0.0.0 --port ${port} --custom-css
