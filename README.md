# Pact Mock Service

This codebase provides the mock service used by implementations of [Pact][pact]. It is packaged as a gem, and as a standalone executable for Mac OSX and Linux (Windows coming soon.)

The mock service provides the following endpoints:

* DELETE /interactions - clear previously mocked interactions
* POST /interactions - set up an expected interaction
* GET /interactions/verification - determine whether the expected interactions have taken place
* POST /pact - write the pact file

As the Pact mock service can be used as a standalone executable and administered via HTTP, it can be used for testing with any language. All that is required is a library in the native language to create the HTTP calls listed above. Currently there are binding for [Ruby][pact] and [Javascript][javascript]. If you are interested in creating bindings in a new langauge, and have a chat to one of us on the [pact-dev Google group][pact-dev].

## Usage

### With Ruby

    $ gem install pact-mock_service
    $ pact-mock-service --port 1234

Run `pact-mock-service help` for command line options.

### Mac OSX and Linux, without Ruby

See the [releases][releases] page for the latest standalone executable.

### Windows, without Ruby

I had a package somewhere lying around, but I lost it, and I don't have a Windows machine. If you are interested in using the mock server on Windows, please check out the instructions for building one [here][windows], and then let me know so I can upload it to the releases page. Thanks!

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

[pact]: https://github.com/realestate-com-au/pact
[releases]: https://github.com/bethesque/pact-mock_service/releases
[javascript]: https://github.com/DiUS/pact-consumer-js-dsl
[pact-dev]: https://groups.google.com/forum/#!forum/pact-dev
[windows]: https://github.com/bethesque/pact-mock_service/wiki/Building-a-Windows-standalone-executable
