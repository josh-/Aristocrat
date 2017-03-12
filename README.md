# Aristocrat

Aristocrat is simple utility that allows you to decode barcodes on your screen and read the text in images and scanned PDFs.

After choosing "Capture Screen..." in the Aristocrat menu bar, select an area of your screen (which can be done through a system-wide hotkey) and Aristocrat works its magic.

## Installation

<a href="https://geo.itunes.apple.com/us/app/aristocrat/id886910172?mt=12" style="display:inline-block;overflow:hidden;background:url(//linkmaker.itunes.apple.com/assets/shared/badges/en-us/macappstore-lrg.svg) no-repeat;width:165px;height:40px;background-size:contain;"></a>

## Requirements

* OS X 10.10 or later

## Development
1. Fetch submodules (if the repo hasn't been cloned with `--recursive`)
    - `git submodule update --init --recursive`
2. Install dependencies
    - With [carthage](https://github.com/Carthage/Carthage) installed, run the following in the repository's directory:

```sh
carthage bootstrap --platform mac
```

# TODO

- Allow users to tailor the recognition (ie. changing [tesseract control parameters](https://github.com/tesseract-ocr/tesseract/wiki/ControlParams)) to favour words/numbers/etc
- Support languages other than English
- Asynchronous barcode detection and OCR
- Ability to edit the resulting text

## License

The MIT License (MIT)

Copyright (c) 2017 Josh Parnham

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
