.PHONY: build test cli clean clean-deps docker-build docker-run

#VSN := $(shell git describe --always --dirty)
VSN := latest

all: test cli

build:
	mix deps.get && mix compile

test: build
	mix test

cli:
	cd apps/smcrawl_cli; mix escript.build
	mv apps/smcrawl_cli/smcrawl_cli .

clean:
	-rm -rf _build

clean-deps:
	-rm -rf deps

docker-build:
	docker build -f docker/Dockerfile -t smcrawl:$(VSN) .

docker-run:
	docker run -it --rm smcrawl:$(VSN)
