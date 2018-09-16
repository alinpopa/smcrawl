## Design

The Smcrawl (SiteMap Crawl), was built around Erlang processes, as a dispatcher - workers architecture; and by that, I mean the following:
- at the core of the crawler, we have a dispatcher actor that coordinates a set of workers
- each worker, is an Erlang process (technically is an Elixir Task, which behind the scene is an actor) that uses a parser in order to go over an url
- when each worker finishes its own work, will send a message (with the payload) back to the dispatcher, and shuts itself down
- the dispatcher receives the work payload (which is a set of parsed URLs), and checks them against a Set implementation (for this implementation, I've used a MapSet, which is the default set implementation in Elixir); if the set doesn't contain the url, this will be added to a queue, and an internal state, which is the sitemap, will be updated accordingly.
- the dispatcher starts a worker for each URL that needs to be crawled, from the queue, unless the maximum number of workers was reached; at that time, the dispatcher waits for the other workers to finish their execution, and it'll start a new worker as soon as another finishes.
- when all the workers have finished their work, and there are no other urls within the queue to be crawled, it shuts itself down, and sends out the accumulated sitemap.
- then the sitemap is being rendered to the stdout.

### API

Smcrawl can be used programatically as well, having an Elixir API:

```
parser = %Parser{http: &Smcrawl.Lib.Http.get/1, exclude: exclude}
set = MapSet.new()

dispatcher = %Dispatcher{
  url: url,
  frequency: freq,
  parser: parser,
  set: set,
  depth: depth,
  workers: workers
}

result =
  Crawler.make()
  |> Crawler.with_dispatcher(dispatcher)
  |> Crawler.sync()

case result do
  {:ok, sitemap} ->
    SiteMap.render(sitemap)

  {:error, reason} ->
    IO.puts("Error while running crawler: #{inspect(reason)}")
    show_help()
end
```

The crawler module has two main functions that can be used internally:
- `async/1` - which returns an Elixir Task
- `sync/1` - which basically blocks the current Erlang process and waits (indefinitely) for the underlying Task to finish.

### Assumptions

- The links were considered only html `<a>` tags, using the `href` attribute from those.
- Displaying of the SiteMap, since I wasn't able to find a very nice way to display a cyclic graph like structure within stdout, the sitemap is partially flat, having the pages, and then for each page a set of urls that represents the links; in order to see what other links a link has, you'd need to lookup the page as one of the leftmost pages.
- This implementation uses a basic Set implementation (also a similar implementation for the SiteMap), in order to make sure an url is not crawled multiple times, entering an infinite loop that way (i.e. `https://monzo.com/about` is something we can find as a self reference). For huge (a very big number of unique links) websites, this would be an issue, and there are few other more involved alternatives like caches with some more complex eviction policies, proper databases, and I've considered that those would be beyond the scope of this exercise.

### Extensibility

As for the extensibility, smcrawl uses Elixir Protocols in order to support a plugin like design.
What can be customised, are mostly the dispatcher and the parser.
Smcrawl can be extended using the following extension points:

- `Smcrawl.Lib.Proto.Dispatch.Start` - a protocol to be used to start a custom dispatcher
- `Smcrawl.Lib.Proto.Dispatch.Validate` - a protocol to be used to validate a custom dispatcher before being started
- `Smcrawl.Lib.Proto.Dispatch.With` - a protocol to be used in order to be sure that the crawler accepts a custom dispatcher.

- `Smcrawl.Lib.Proto.Parse.Run` - a protocol to be used to run a custom parser
- `Smcrawl.Lib.Proto.Parse.Validate` - a protocol to be used in order to validate the custom parser

- examples for any of those can be seen within the `apps/smcrawl_lib/lib/proto/` folder, and `apps/smcrawl_lib/test/lib/`

## How to run this thing

Prerequisites:

- `erlang` >= 21.0
- `elixir` >= 1.7.3
- `make`
- `docker`

### Build

- `make` - this will build everything, also runing the tests
- `make cli` - this will build the crawler, and produces the cli.
- `make test` - will run the tests

### Run

After building it ...
- `./smcrawl_cli -u "http://monzo.com" -d 3 -e "cdn-cgi/l/email-protection"` - in order to crawl the Monzo website, with a depth of 3, ignoring the urls containing `cdn-cgi/l/email-protection` in their names.
- `./smcrawl_cli -h` - for more options.

### Docker

This can be run also in docker...

- `make -f Makefile.docker build` - builds the current state of the project as a docker image
- `make -f Makefile.docker run` - run the just built docker image, crawling the Monzo website, using 10 works, a depth of 3 levels, and excluding urls that have `cdn-cgi/l/email-protection` in their names.
