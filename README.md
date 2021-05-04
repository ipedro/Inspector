[![](https://img.shields.io/github/license/ipedro/inspector)](https://github.com/ipedro/Inspector/blob/develop/LICENSE) 
![](https://img.shields.io/github/v/tag/ipedro/inspector?label=spm)

# 🧬 Inspector
Inspector is a debugging library written in Swift.

* [Requirements](#requirements)
* [Installation](#installation)
* [Credits](#credits)
* [License](#license)

## Requirements

* iOS 11.0+
* Xcode 11+
* Swift 5.3+

## Installation

## Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swisft code and is integrated into the swift compiler. It is in early development, but Inspector does support its use on supported platforms.

Once you have your Swift package set up, adding `Inspector` as a dependency is as easy as adding it to the dependencies value of your `Package.swift`.

``` swift
dependencies: [
  .package(url: "https://github.com/ipedro/Inspector.git", .upToNextMajor(from: "1.0.0"))
]
```

## Credits

`Inspector` is owned and maintained by [Pedro Almeida](https://pedro.am). You can follow him on Twitter at [@ipedro](https://twitter.com/ipedro) for project updates and releases.

## License

`Inspector` is released under the MIT license. [See LICENSE](https://github.com/ipedro/Inspector/blob/master/LICENSE) for details.
