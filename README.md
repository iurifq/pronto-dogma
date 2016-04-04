# Pronto runner for Dogma

This allows you to take the output of Dogma and submit its errors with
[Pronto].

## Installation

As an Elixir application will probably not have a `Gemfile`, install it with:

    $ gem install pronto-dogma

After the gem is installed, [Pronto] will already detect the Dogma
runner.

## Usage

It's important to run Dogma with `--format=flycheck` and send the output to a
file.

The path for Dogma's output file should then be passed to the runner. It uses
the environment variable `PRONTO_DOGMA_OUTPUT` to define the location of
Dogma's output file. If this variable is not defined, it will look for the
file `dogma.out`.

### Running on Travis CI

Pronto works perfectly to create comment on PRs and commits. For that, use
`pronto run` as described in the readme for [Pronto].

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/iurifq/pronto-dogma.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


[Pronto]: https://github.com/mmozuras/pronto
