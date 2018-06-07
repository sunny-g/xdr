# XDR

XDR encoded data structures ([RFC 4506](https://tools.ietf.org/html/rfc4506)) in Elixir

[Source](https://github.com/sunny-g/xdr) | [Documentation](https://hexdocs.pm/xdr)

[![Build Status](https://semaphoreci.com/api/v1/sunny-g/xdr/branches/master/badge.svg)](https://semaphoreci.com/sunny-g/xdr)

XDR provides:

- base XDR type modules
- compound XDR type modules for defining your own custom types
- built-in validation, encoding and decoding functions for each base and compound/custom module

## Installation

Install from [Hex.pm](https://hex.pm/packages/xdr):

```elixir
def deps do
  [{:xdr, "~> 0.1.2"}]
end
```

## API Overview

```elixir
# base type modules
# can be used as is
XDR.Type.Int
XDR.Type.Uint
XDR.Type.Bool
XDR.Type.HyperInt
XDR.Type.HyperUint
XDR.Type.Float
XDR.Type.DoubleFloat
XDR.Type.QuadrupleFloat  # not implemented
XDR.Type.Void

# compound type modules
# create your own custom type modules with the `__using__` macro, the options for which are defined within each module
# examples can be found in each module's tests within the `test` directory
XDR.Type.Enum
XDR.Type.FixedOpaque
XDR.Type.VariableOpaque
XDR.Type.String
XDR.Type.FixedArray
XDR.Type.VariableArray
XDR.Type.Struct
XDR.Type.Union
XDR.Type.Const
XDR.Type.Optional
```

## Changelog

| Version | Change Summary |
| ------- | -------------- |
| [v0.1.2](https://hex.pm/packages/xdr/0.1.2) | [negative integers in Enums](https://github.com/sunny-g/xdr/pull/11)
| [v0.1.1](https://hex.pm/packages/xdr/0.1.1) | [minor bugfix](https://github.com/sunny-g/xdr/pull/6) |
| [v0.1.0](https://hex.pm/packages/xdr/0.1.0) | initial release |

## Contributing

1. Fork it [https://github.com/your_username/xdr/fork](https://github.com/sunny-g/xdr/fork)
2. Create your feature branch (`git checkout -b feature/fooBar`)
3. Commit your changes (`git commit -am 'Add some fooBar'`)
4. Push to the branch (`git push origin feature/fooBar`)
5. Create a new Pull Request

## Maintainers

- Sunny G - [@sunny-g](https://github.com/sunny-g)

## Contributors

- Bryan Joseph - [@bryanjos](https://github.com/bryanjos)

## License

MIT

