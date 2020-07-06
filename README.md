# ImageBoard

[![CI Status](https://img.shields.io/travis/liuzhida33/ImageBoard.svg?style=flat)](https://travis-ci.org/liuzhida33/ImageBoard)
[![Version](https://img.shields.io/cocoapods/v/ImageBoard.svg?style=flat)](https://cocoapods.org/pods/ImageBoard)
[![License](https://img.shields.io/cocoapods/l/ImageBoard.svg?style=flat)](https://cocoapods.org/pods/ImageBoard)
[![Platform](https://img.shields.io/cocoapods/p/ImageBoard.svg?style=flat)](https://cocoapods.org/pods/ImageBoard)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

<p align="center">
  <img src="./Preview/ImageBoard.png" width="90%" />
</p>

## Preview

<p align="center">
  <img src="./Preview/ImageBoard.gif" />
</p>

## Requirements

iOS 10.0+

## Installation

ImageBoard is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ImageBoard'
```

## Usage

### Basics

``` swift
let editVC = ImageBoardViewController()
editVC.editImage = image
editVC.modalPresentationStyle = .custom
present(editVC, animated: true)
```


## Author

liuzhida33, liuzhida33@gmail.com

## License

ImageBoard is available under the MIT license. See the LICENSE file for more info.
