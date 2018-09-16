.PHONY: build test cli clean clean-deps

all: test cli

build:
	mix local.hex --force
	mix local.rebar --force
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
