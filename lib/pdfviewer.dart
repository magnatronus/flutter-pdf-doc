import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

/// Simple PDF View and Print Widget
class PDFViewer extends StatelessWidget {
  final String pdffile;
  final PDFDocument document;

  PDFViewer({@required this.pdffile, @required this.document});

  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold(
      appBar: AppBar(
        title: Text("PDF Viewer"),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Printing.printPdf(document: document);
            },
            icon: Icon(Icons.print),
          ),
        ],
      ),
      path: pdffile,
    );
  }
}
