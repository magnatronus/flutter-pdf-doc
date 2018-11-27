import 'package:flutter/material.dart';
import 'pdfdemo.dart';

void main() => runApp(PdfDev());

/// A simpe MaterialApp to demo the use of
/// [ReportDocument]
/// This is a test class that uses the pdf package - https://pub.dartlang.org/packages/pdf
/// to generate  PDF files.
///
/// Please note that current this library is WIP
class PdfDev extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReportDocument Demo',
      home: PDFDemo(),
    );
  }
}
