import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';

/// Define a cursor to keep track of the print position
class _Cursor {
  // Current height and width of paper
  final double paperHeight;
  final double paperWidth;

  // current/last cursor position
  double x;
  double y;

  /// max values for cursor within margins
  double maxx;
  double maxy;

  /// The available printable width and height inside the margins
  double printWidth;
  double printHeight;

  /// The spacing between each printed line
  double lineSpacing;

  /// The margin set in the document being generated
  _DocumentMargin margin;

  _Cursor(this.paperHeight, this.paperWidth,
      {this.lineSpacing: PDFPageFormat.mm})
      : x = 0.0,
        y = paperHeight;

  /// debug print
  printBounds() {
    print("x: $x, y: $y, maxx: $maxx, maxy: $maxy");
  }

  /// Reset the cursor ready for a new page
  reset() {
    x = margin.left;
    y = paperHeight - margin.top;
    maxx = paperWidth - margin.right;
    maxy = margin.bottom;
    printWidth = paperWidth - (margin.right + margin.left);
    printHeight = paperHeight - (margin.top + margin.bottom);
  }

  // Add a new line space
  newLine() {
    y -= lineSpacing;
  }

  /// add a paragraph space
  newParagraph() {
    y -= (lineSpacing * 3);
  }

  // Move the cursor relative to the current position
  move(double mx, double my) {
    x += mx;
    y -= my;
    y -= lineSpacing;
  }
}

/// Define document margins in MM
/// The default is 25.4 mm (approx 1")
class _DocumentMargin {
  static double standard = 25.4 * PDFPageFormat.mm;
  double _top = standard;
  double _left = standard;
  double _bottom = standard;
  double _right = standard;

  get top {
    return _top;
  }

  get left {
    return _left;
  }

  get bottom {
    return _bottom;
  }

  get right {
    return _right;
  }
}

/// A wrapper around the [pdf] Flutter package that defines the spec of the document being generated
/// It requires the format of the paper to use for the report [paper]
///
/// Any printed text will use the specified [defaultColor]. This defaults to [Colors.black] if not defined
///
/// Reports that are generated with [saveAsFile] are stored in the [getApplicationDocumentsDirectory] and a subdirectory
/// defined by the optional [storageDirectory] which by default wll be set to 'reports'.
class ReportDocument {

  final PDFPageFormat paper;
  final String storageDirectory;
  final _Cursor _cursor;
  final PDFDocument _report;
  final Color defaultColor;
  _DocumentMargin _margin = _DocumentMargin();
  PDFPage _currentPage;
  PDFTTFFont _currentFont;
  double _lineSpacing = PDFPageFormat.mm;
  Map<String, PDFTTFFont> _fonts = Map();
  Color _currentColor;
  Map _header;


  ReportDocument(
      {@required this.paper,
      this.storageDirectory: 'reports',
      this.defaultColor: Colors.black})
      : _currentColor = defaultColor,
        _report = PDFDocument(deflate: zlib.encode),
        _cursor = _Cursor(paper.dimension.h, paper.dimension.w);


  /// Add a new blank page to the PDF and reset the cursor
  createNewPage() {
    _currentPage = PDFPage(_report, pageFormat: paper);
    _cursor.lineSpacing = _lineSpacing;
    _cursor.margin = _margin;
    _cursor.reset();
    _cursor.printBounds();
    if(_header != null){
      _printHeader();
    }
  }



  /// set the current color to use where it is not specifically defined
  /// where [color] is the required [Color]
  setColor(Color color) {
    _currentColor = color;
  }

  /// set the current color back to the specified [defaultColor]
  setDefaultColor() {
    _currentColor = defaultColor;
  }

  /// Sets the current True Type font used to output text to the page
  /// [font] - the name and location of a TTF as specified in custom fonts section of pubspec.yaml
  setTTFont(String font) async {
    _currentFont = await _loadTTFFont(font);
  }

  /// A simple header that will be automatically added as the first text everytime a new page is generated
  addHeader(text, {@required double size, String font}){
    _header = {
      "text": text,
      "size": size,
      "font": font
    };
  }

  /// Add the specified text to the current page using the currently set font [setTTFont] and the specified [size]
  /// optionally a different [font] from the current default may be specified
  /// if [paragraph] is set (it is set to true by defaul) then space is printed before  text.
  addText(String text, {bool paragraph: true, @required double size, String font}) {
    // Check we have a true type font installed and set  - if not this needs doing first
    if (_currentFont == null) {
      throw Exception(
          "Please use setTTFont() to load at least 1 TrueType font for use as the document default.");
    }

    // add a paragraph space
    if (paragraph) {
      _cursor.newParagraph();
    }

    // what font will be used
    PDFTTFFont textFont = (font==null)?_currentFont:_loadTTFFont(font);


    /// Now build up lines from the words in the passed [text]
    /// If adding a word exceeds the print margins print the line and start a new one
    List words = text.split(" ");
    String line = "";
    words.forEach((w) {
      if (line.length < 1) {
        line = w;
      } else {
        var lb = _currentFont.stringBounds(line + " $w");
        double lw = (lb.w * size) + lb.x;
        if (lw > _cursor.printWidth) {
          _printLine(line, textFont, size);
          line = w;
        } else {
          line += ' $w';
        }
      }
    });

    // print whats left of our text
    if (line.length > 0) {
      _printLine(line, textFont, size);
      _cursor.newLine();
    }
  }

  /// Get a Rawcopy of the actual PDF document
  get document {
    return _report;
  }

  /// Save the PDF as [name] file  to the specificed storage directory and return the name and location of the file
  saveAsFile(String filename) async {
    var reportDirectory = await _getStorageDirectory();
    String fileName = '$reportDirectory/$filename.pdf';
    var file = new File(fileName);
    file.writeAsBytesSync(_report.save());
    return fileName;
  }


  /// Create and/or access the directory to store any generated documents
  _getStorageDirectory() async {
    var directory = await getApplicationDocumentsDirectory();
    Directory("${directory.path}/$storageDirectory").createSync();
    return "${directory.path}/$storageDirectory";
  }

  /// Load the document with a TTF
  _loadTTFFont(String fontfile) async {
    if (!_fonts.containsKey(fontfile)) {
      ByteData fontBytes = await rootBundle.load(fontfile);
      _fonts[fontfile] = PDFTTFFont(_report, fontBytes);
    }
    return _fonts[fontfile];
  }  


  /// Add a header to the page
  _printHeader(){
    addText(_header['text'], 
      font: _header['font'], 
      size: _header['size']);
    _cursor.newParagraph();    
  }

  /// This will print out the string specified in [line] using the current cursor position
  /// If the line will not fit on the page it will first create a new page
  _printLine(line, font, size) {
    var lb = font.stringBounds(line);
    double yshim = (lb.h - lb.y) * size;

    // Make sure we used the correct color
    _currentPage.getGraphics().setColor(PDFColor.fromInt(_currentColor.value));

    // check if line will print on the page - if not create a new page
    if ((_cursor.y - yshim) < _cursor.maxy) {
      createNewPage();
    }
    
    // add line to page
    _cursor.move(0.0, yshim);
    _currentPage
        .getGraphics()
        .drawString(font, size, line, _cursor.x, _cursor.y);
  }  
}
