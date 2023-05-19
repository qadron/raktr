# Raktr

Raktr is a simple, lightweight, pure-Ruby implementation of the
[Reactor](http://en.wikipedia.org/wiki/Reactor_pattern) pattern, mainly focused
on network connections -- and less so on generic tasks.

## Features

 - Extremely lightweight.
 - Very simple design.
 - Support for TCP/IP and UNIX-domain sockets.
 - TLS encryption.
 - Pure-Ruby.
 - Multi-platform.

## Supported platforms

 - Rubies:
    - MRI >= 1.9
    - Rubinius
    - JRuby
 - Operating Systems:
    - Linux
    - OSX
    - Windows

## Examples

For examples please see the `examples/` directory.

## Installation

    gem install raktr

## Running the Specs

    rake spec

## Bug reports/Feature requests

Please send your feedback using GitHub's issue system at
[http://github.com/qadron/raktr/issues](http://github.com/qadron/raktr/issues).


## License

Raktr is provided under the 3-clause BSD license.
See the [LICENSE](https://github.com/qadron/raktr/blob/master/LICENSE.md) file for more information.
