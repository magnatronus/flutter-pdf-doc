import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'reportdocument.dart';
import 'pdfviewer.dart';

/// Simple Test Widget to generate a PDF file using  the [ReportDocument] library and save it
/// once saved the document is displayed in a PDF viewer
class PDFDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PDF"),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () {
            generateTestPDF(context);
          },
          child: Text("GENERATE TEST PDF"),
        ),
      ),
    );
  }

  /// An example of generating a PDF document and they viewing it
  generateTestPDF(BuildContext context) async {
    // create a blank pdf doc
    ReportDocument pdf = ReportDocument(
      paper: PDFPageFormat.a4,
    );

    // set our default font (we MUST wait for the font to load!)
    await pdf.setTTFont("fonts/GeosansLight.ttf");

    // Add a header
    pdf.addHeader(
      "PDF Report",
      size: 28.0,
    );

    // create the first page
    pdf.createNewPage();

    // Now add some text which will print in the default color
    pdf.addText("ReportDocument Demo PDF", size: 20.0);

    // Change color and print
    pdf.setColor(Colors.red);
    pdf.addText(
      "1. This text should be in RED. Lorem ipsum was conceived as filler text, formatted in a certain way to enable the presentation of graphic elements in documents,"
          "without the need for formal copy. Using Lorem Ipsum allows designers to put together layouts and the form of the content before the"
          "content has been created, giving the design and production process more freedom.",
      size: 16.0,
    );

    pdf.setColor(Colors.blue);
    pdf.addText(
      "2. This text should be in BLUE. Lorem ipsum was conceived as filler text, formatted in a certain way to enable the presentation of graphic elements in documents,"
          "without the need for formal copy. Using Lorem Ipsum allows designers to put together layouts and the form of the content before the"
          "content has been created, giving the design and production process more freedom.",
      size: 16.0,
    );

    pdf.setColor(Colors.green);
    pdf.addText(
      "3. This text should be in GREEN. Lorem ipsum was conceived as filler text, formatted in a certain way to enable the presentation of graphic elements in documents,"
          "without the need for formal copy. Using Lorem Ipsum allows designers to put together layouts and the form of the content before the"
          "content has been created, giving the design and production process more freedom.",
      size: 16.0,
    );

    pdf.setDefaultColor();
    pdf.addText(
      "4. This text should be be in the default COLOR. Lorem ipsum was conceived as filler text, formatted in a certain way to enable the presentation of graphic elements in documents,"
          "without the need for formal copy. Using Lorem Ipsum allows designers to put together layouts and the form of the content before the"
          "content has been created, giving the design and production process more freedom.",
      size: 16.0,
    );

    pdf.addText(
      "5. Lorem ipsum was conceived as filler text, formatted in a certain way to enable the presentation of graphic elements in documents,"
          "without the need for formal copy. Using Lorem Ipsum allows designers to put together layouts and the form of the content before the"
          "content has been created, giving the design and production process more freedom."
          "The difference with this paragraph of text is that this line will wrap as it is too big to fit the page size defined so some of it will"
          "be put onto a newly generated page. This of course depends on the margins set and the paper size",
      size: 16.0,
    );

    pdf.addText(
      "6. Lorem ipsum was conceived as filler text, formatted in a certain way to enable the presentation of graphic elements in documents,"
          "without the need for formal copy. Using Lorem Ipsum allows designers to put together layouts and the form of the content before the"
          "content has been created, giving the design and production process more freedom.",
      size: 16.0,
    );

    ///
    /// Demo creating a new page
    ///

    // create page two
    pdf.createNewPage();

    // add some text
    pdf.addText("ReportDocument Demo New Page", size: 20.0);

    pdf.addText(
      " Lorem ipsum was conceived as filler text, formatted in a certain way to enable the presentation of graphic elements in documents,"
          "without the need for formal copy. Using Lorem Ipsum allows designers to put together layouts and the form of the content before the"
          "content has been created, giving the design and production process more freedom.",
      size: 16.0,
    );

    // Generate and save the PDF as a file
    PDFDocument doc = pdf.document;
    var path = await pdf.saveAsFile("helloworld");

    // Display the generated PDF in a viewer
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PDFViewer(
                  pdffile: path,
                  document: doc,
                )));
  }
}
