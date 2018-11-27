# pdfdev

A Flutter app used to test a wrapper around the [pdf plugin](https://pub.dartlang.org/packages/pdf).

This app is a very simple WIP demo that will create an A4 landscape PDF and generate text in various sizes and colors that will line and page wrap as required.

The generated PDF can also be viewed and printed.

*I have only been testing this with iOS currently*


## ReportDocument
**ReportDocument** is a wrapper around the functionality of the pdf plugin to allow a PDF document to be generated using wrappable text(both line and page).
Currently you can specify:

* Paper size
* Font style
* Font size
* Font color
* An optional page header

To use **ReportDocument** just take a look at how it is used in this demo app. 

**Please Note: This will only work with True Type Fonts and at least 1 must be loaded to use as the document default**

The TTF font(s) should be added as an asset in the same way that any custom fint should be with Flutter (see the pubspec.yaml for details)

## Currently Planned Updates
* automatic Page  Footers
* page numbering


## Getting Started

For help getting started with Flutter, view the online
[documentation](https://flutter.io/).
