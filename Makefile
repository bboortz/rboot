timestamp = $(shell date +'%Y-%m-%d-%H-%M-%S')
branch = $(shell git rev-parse --abbrev-ref HEAD)
commitid = $(shell git rev-parse HEAD)
tag = $(branch)-$(commitid)
image = registry.gitlab.com/devara.world/health-app:$(tag)
image_latest = registry.gitlab.com/devara.world/health-app:latest
curdir = $(shell pwd)
export PROFILE ?= dev

help:               ## printing out the help
	@echo
	@echo *surfer*
	@echo
	@echo "--- TARGETS ---"
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'
	@echo "------"
	@echo

clean:              ## clean up this project
	./scripts/clean.sh
c: clean

fmt:                ## format the sources
	./scripts/fmt.sh
f: fmt

test: fmt           ## test the software
	./scripts/test.sh
t: test

build:              ## build the software
	./scripts/build.sh
b: build

release: private PROFILE = release
release: build
r: release

run: fmt
	cargo run

doc: release        ## create the documentation
	cargo doc

deploy:             ## deploy the application
	docker-compose up -d

docker_clean:              ## clean up this project
	docker system prune --all --force

docker_build:       ## build in docker
	docker build -t $(image) .
	docker build -t $(image_latest) .

docker_push: docker_build
	docker push $(image)
	docker push $(image_latest)

init:               ## initialize
	rustup target add x86_64-unknown-linux-musl
	cargo install cargo-chef
	rustup update
	rustup component add clippy
	rustup component add rustfmt
	rustup component add rust-analysis rust-src

debug:
	echo "image: $(image)"

