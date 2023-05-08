import 'dart:developer';
import 'dart:io';

import 'package:open_filex/open_filex.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

import 'report_pdf_view.dart';

class ShareView extends StatefulWidget {
  final Map<String, dynamic> data;

  const ShareView({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ViewState(data);
}

enum Action { Print, Download }

const directoryName = 'SDK-Neodocs';

class ViewState extends State<ShareView> {
  bool isDownloading = false;

  bool isPrinting = false;

  bool isSharing = false;

  Map<String, dynamic> result;

  ViewState(this.result);

  late pdf.Document pdfDoc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [_downloadButton(), const Spacer(), _printButton()],
      ),
    );
  }

  _printButton() {
    return Expanded(
      flex: 6,
      child: Container(
        padding: const EdgeInsets.all(0),
        margin: const EdgeInsets.all(0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [
                const Color(0XFF6B60F1),
                const Color(0XFF6B60F1).withOpacity(0.52),
              ],
            )),
        child: ElevatedButton.icon(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.transparent),
              shadowColor: MaterialStateProperty.all(Colors.transparent),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: MaterialStateProperty.all(EdgeInsets.all(8.sp)),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)))),
          icon: SizedBox(
            width: 24.w,
            height: 24.w,
            child: isPrinting
                ? const Padding(
                    padding: EdgeInsets.all(1.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 3.0,
                      color: Colors.white, // line width
                    ))
                : const Icon(
                    Icons.print_outlined,
                    size: 18,
                    color: Colors.white,
                  ),
          ),
          label: AutoSizeText(
            "Print  ",
            style: TextStyle(
                fontSize: 13.sp,
                letterSpacing: 0,
                fontWeight: FontWeight.w500,
                color: Colors.white),
          ),
          onPressed: isPrinting
              ? null
              : () {
                  setState(() {
                    isPrinting = true;
                  });
                  _print(Action.Print);
                },
        ),
      ),
    );
  }

  _downloadButton() {
    return Expanded(
      flex: 7,
      child: Container(
        padding: const EdgeInsets.only(right: 4),
        margin: const EdgeInsets.all(0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [
                const Color(0XFF6B60F1),
                const Color(0XFF6B60F1).withOpacity(0.52),
              ],
            )),
        child: ElevatedButton.icon(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.transparent),
              shadowColor: MaterialStateProperty.all(Colors.transparent),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: MaterialStateProperty.all(EdgeInsets.all(8.sp)),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)))),
          icon: SizedBox(
            width: 20.w,
            height: 24.w,
            child: isDownloading
                ? const Padding(
                    padding: EdgeInsets.all(1.0),
                    child: CircularProgressIndicator(
                      strokeWidth: 3.0,
                      color: Colors.white, // line width
                    ))
                : const Icon(
                    Icons.file_download,
                    size: 18,
                    color: Colors.white,
                  ),
          ),
          label: AutoSizeText(
            "Download  ",
            style: TextStyle(
                fontSize: 13.sp,
                letterSpacing: 0,
                fontWeight: FontWeight.w500,
                color: Colors.white),
            maxLines: 1,
          ),
          onPressed: isDownloading
              ? null
              : () {
                  setState(() {
                    isDownloading = true;
                  });
                  _print(Action.Download);
                },
        ),
      ),
    );
  }

  Future<void> _print(Action action) async {
    pdfDoc = pdf.Document();

    if (widget.data["sampleDetails"] == null) {
      Map<String, dynamic> sampleDetails = {};
      sampleDetails["name"] = "${widget.data["firstName"]} ${widget.data["lastName"]}";
      sampleDetails["dateOfBirth"] = DateTime.parse(widget.data["dateOfBirth"]);
      sampleDetails["gender"] = widget.data["gender"];
      sampleDetails["gender"] = widget.data["gender"];
      widget.data["sampleDetails"] = sampleDetails;
    }
    ReportPdf pdfView = ReportPdf(test: widget.data);
    String path = await pdfView.getReport();

    final pdfImage = pdf.MemoryImage(
      File(path).readAsBytesSync(),
    );

    pdfDoc.addPage(pdf.Page(
        orientation: pdf.PageOrientation.portrait,
        pageFormat: PdfPageFormat.a4,
        margin: pdf.EdgeInsets.zero,
        build: (pdf.Context context) {
          return pdf.Center(
            child: pdf.Image(pdfImage),
          );
        }));

    if (action == Action.Print) {
      await Printing.layoutPdf(
          format: PdfPageFormat.a4,
          onLayout: (PdfPageFormat format) async => pdfDoc.save());
      setState(() {
        isPrinting = false;
      });
    } else if (action == Action.Download) {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      File downloadToFile = File(
          '${appDocDir.path}/report_${result["sampleDetails"]["name"].toString().replaceAll(" ", "_")}.pdf');
      log(appDocDir.path.toString());
      await downloadToFile.writeAsBytes(await pdfDoc.save());
      await OpenFilex.open(downloadToFile.path);
      setState(() {
        isDownloading = false;
      });
    } else {
      await Printing.sharePdf(
          bytes: await pdfDoc.save(),
          filename:
              'report_${result["sampleDetails"]["name"].toString().replaceAll(" ", "_")}.pdf');
      setState(() {
        isSharing = false;
      });
    }
  }
}
