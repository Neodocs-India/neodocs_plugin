import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:ui';

import 'package:flutter/material.dart' hide TextStyle, Image;
import 'package:intl/date_symbol_data_file.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../constants/app_font_family.dart';
import '../constants/app_colors.dart';

class ReportPdf {
  final Map<String, dynamic> test;

  ReportPdf({required this.test}) {
    init();
  }

  late double screenHeight = 3508;
  late double screenWidth = 2480;

  late double pixelsPerOneMM = 10;
  late double pixelsPerOneCM = 65;

  late PictureRecorder recorder;
  late Canvas canvas;
  late Image image;
  late String path;

  late double paddingLeft;
  late double paddingTop;
  late double paddingBottom;
  late double paddingRight;

  Paint bodyTextNormal = Paint()
    ..color = Colors.black
    ..strokeWidth = 1;

  Paint bodyTextBold = Paint()
    ..color = Colors.black
    ..strokeWidth = 2;

  late Paint headerPaint = Paint()
    ..color = AppColors.primaryColor
    ..strokeWidth = 1.0;

  final Paint tablePaint = Paint()
    ..color = Colors.grey
    ..strokeWidth = 0.4;

  TextStyle titleStyle =
      TextStyle(color: Colors.black, fontWeight: FontWeight.bold);
  TextStyle normalStyle =
      TextStyle(color: Colors.black, fontWeight: FontWeight.w500);

  late Image footer;
  late Image logo;

  late double headerHeight;

  late double footerHeight;

  init() {
    paddingLeft = pixelsPerOneCM;
    paddingTop = pixelsPerOneCM;
    paddingBottom = pixelsPerOneCM;
    paddingRight = pixelsPerOneCM;

    headerHeight = pixelsPerOneCM * 4;
    footerHeight = pixelsPerOneCM * 3;

    recorder = PictureRecorder();
    canvas = Canvas(
        recorder,
        Rect.fromPoints(
            const Offset(0.0, 0.0), Offset(screenWidth, screenHeight)));
  }

  Future<String> getReport() async {
    logo = await loadUiImage(base64Logo);
    footer = await loadUiImage(base64Footer);

    drawReport();

    final picture = recorder.endRecording();
    final Image report =
        await picture.toImage(screenWidth.toInt(), screenHeight.toInt());
    return await saveImage(report);
  }

  void drawReport() async {
    Rect header = Rect.fromLTRB(0, 0, screenWidth, headerHeight); //50
    canvas.drawRect(header, headerPaint);

    paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(paddingLeft, paddingTop / 2, headerHeight * 2,
            headerHeight - paddingTop),
        image: logo,
        fit: BoxFit.contain, // <- the loaded image
        filterQuality: FilterQuality.high);

    canvas.drawParagraph(
        getParagraphText("Test\nReport",
            style: TextStyle(
              fontSize: pixelsPerOneCM * 0.8,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            width: screenWidth - paddingRight - paddingLeft,
            textAlign: TextAlign.right),
        Offset(paddingLeft, paddingTop));

    displayInformation();
    canvas.drawLine(Offset(0, headerHeight), Offset(screenWidth, headerHeight),
        bodyTextBold);

    canvas.drawParagraph(
        getParagraphText(_disclaimer,
            width: screenWidth, style: TextStyle(color: Colors.black)),
        Offset(paddingLeft,
            screenHeight - footerHeight - paddingBottom - pixelsPerOneCM));

    canvas.drawLine(
        Offset(paddingLeft, screenHeight - footerHeight - paddingBottom),
        Offset(screenWidth - paddingRight,
            screenHeight - footerHeight - paddingBottom),
        bodyTextBold);
    paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(
            paddingLeft,
            screenHeight - footerHeight - paddingBottom,
            screenWidth - paddingLeft - paddingRight,
            footerHeight),
        image: footer, // <- the loaded image
        fit: BoxFit.fitWidth,
        filterQuality: FilterQuality.high);
    canvas.drawParagraph(
        getParagraphText("1 of 1",
            width: screenWidth - paddingRight - paddingLeft,
            textAlign: TextAlign.center),
        Offset(paddingLeft, screenHeight - paddingBottom * 2));

    Rect foot = Rect.fromLTRB(
        0, screenHeight - pixelsPerOneCM / 2, screenWidth, screenHeight); //50
    canvas.drawRect(foot, headerPaint);
  }

  void displayInformation() {
    int rows = 4;

    //String date = DateFormat('dd MMM yyyy').format(mData.getCreatedOn());
    //String time = DateFormat('hh:mm a').format(mData.getCreatedOn());

    //String.format("%s  %s %s", now.substring(11, 16), now.substring(8, 10),now.substring(4, 10), now.substring(now.lastIndexOf(" ")+3));

    double rowLength = (screenWidth) / rows;
    double rowHeight = pixelsPerOneCM * 1.2;
    double rowPos = headerHeight + pixelsPerOneCM;
    double colPos = paddingLeft;

    canvas.drawParagraph(
        getParagraphText("Name:", style: titleStyle), Offset(colPos, rowPos));
    rowPos += rowHeight;
    canvas.drawParagraph(
        getParagraphText("Age:", style: titleStyle), Offset(colPos, rowPos));
    rowPos += rowHeight;
    canvas.drawParagraph(
        getParagraphText("Gender:", style: titleStyle), Offset(colPos, rowPos));
    rowPos += rowHeight;
    canvas.drawParagraph(getParagraphText("Reference:", style: titleStyle),
        Offset(colPos, rowPos));

    colPos += rowLength - pixelsPerOneCM * 4;
    rowPos = headerHeight + pixelsPerOneCM;
    canvas.drawParagraph(getParagraphText(test["sampleDetails"]?["name"]),
        Offset(colPos, rowPos));
    rowPos += rowHeight;
    canvas.drawParagraph(
        getParagraphText(
            (test["sampleDetails"]["dateOfBirth"] as DateTime)
                .getAgeYears()),
        Offset(colPos, rowPos));
    rowPos += rowHeight;
    canvas.drawParagraph(
        getParagraphText(
            test["sampleDetails"]["gender"].toString().toUpperCase()),
        Offset(colPos, rowPos));
    rowPos += rowHeight;
    //canvas.drawParagraph(
        //getParagraphText("Dr. ${test["doctor"]["name"].toString().replaceAll("Dr.", "").replaceAll("Dr", "").trim()}"),
        //Offset(colPos, rowPos));

    colPos += (rowLength + pixelsPerOneCM);
    rowPos += pixelsPerOneCM * 3;
    rowPos = headerHeight + pixelsPerOneCM;
    canvas.drawParagraph(getParagraphText("Report ID:", style: titleStyle),
        Offset(colPos, rowPos));
    rowPos += rowHeight;
    canvas.drawParagraph(getParagraphText("Sample type:", style: titleStyle),
        Offset(colPos, rowPos));
    rowPos += rowHeight;
    canvas.drawParagraph(
        getParagraphText("Sample collected on:", style: titleStyle),
        Offset(colPos, rowPos));
    rowPos += rowHeight;
    canvas.drawParagraph(
        getParagraphText("Reported generated on:", style: titleStyle),
        Offset(colPos, rowPos));

    colPos += (rowLength + pixelsPerOneCM);
    rowPos = headerHeight + pixelsPerOneCM;
    canvas.drawParagraph(
        getParagraphText((DateTime.fromMillisecondsSinceEpoch(test["captureTime"]))
            .millisecondsSinceEpoch
            .toString()),
        Offset(colPos, rowPos));
    rowPos += rowHeight;
    canvas.drawParagraph(getParagraphText("Urine"), Offset(colPos, rowPos));
    rowPos += rowHeight;
    canvas.drawParagraph(
        getParagraphText(DateTime.fromMillisecondsSinceEpoch(test["captureTime"])
            .format("dd/MM/yyyy, hh:mm:ss a")),
        Offset(colPos, rowPos));
    rowPos += rowHeight;
    canvas.drawParagraph(
        getParagraphText(DateTime.fromMillisecondsSinceEpoch(test["captureTime"])
            .format("dd/MM/yyyy, hh:mm:ss a")),
        Offset(colPos, rowPos));
    rowPos += rowHeight + pixelsPerOneCM / 2;

    canvas.drawLine(
        Offset(0, rowPos), Offset(screenWidth, rowPos), bodyTextBold);

    rowPos += rowHeight + pixelsPerOneCM / 2;

    canvas.drawParagraph(
        getParagraphText("Test Report",
            style: titleStyle,
            fontSize: pixelsPerOneCM * 1.2,
            width: screenWidth,
            textAlign: TextAlign.center),
        Offset(0, rowPos));
    rowPos += rowHeight * 2;
    canvas.drawParagraph(
        getParagraphText("Urine Examination",
            style: titleStyle, width: screenWidth),
        Offset(paddingLeft, rowPos));
    rowPos += rowHeight - pixelsPerOneMM;
    canvas.drawParagraph(
        getParagraphText("CHEMICAL EXAMINATION",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
            fontSize: pixelsPerOneCM * 0.8,
            width: screenWidth),
        Offset(paddingLeft, rowPos));
    rowPos += rowHeight * 2;

    /*if (test["kit_type"] == "CKD") {
      test["panels"].remove("urine_ds_uricacid");
      test["results"]["urine_ds_acr"]["display_name"] = "ACR";
      test["results"]["urine_ds_acr"]["reference_range"] = test["results"]
              ["urine_ds_acr"]["reference_range"]
          .toString()
          .replaceAll("<br>", "\n");
    }*/

    List panelList = ((test["panels"] as Map<String, dynamic>).values.first as Map<String, dynamic>)["details"]["biomarker_details"].toList();
    panelList.sort(
        (a, b) => (a['index'] ?? 0).compareTo((b['index'] ?? 0)));
    debugPrint("-----------------------------------------------------\n");
    //debugPrint((test["panels"] as Map<String, dynamic>).values.first["biomarker_details"]);

    /*if (test["kit_type"] != "CKD") {
      panelList = panelList
          .where((element) =>
              (test["panels"]["wellness"]["biomarker_name"] as List)
                  .contains(element.key))
          .map((panel) {
        return panel;
      }).toList();
    }*/

    double colWidth = screenWidth / 3.5;
    double padding = pixelsPerOneMM * 3;
    double tableStart = rowPos - pixelsPerOneCM / 2;
    for (int i = 0; i < panelList.length; i++) {
      if (i == 0) {
        canvas.drawLine(
            Offset(paddingLeft, rowPos - pixelsPerOneCM / 2),
            Offset(screenWidth - paddingLeft, rowPos - pixelsPerOneCM / 2),
            tablePaint);
        canvas.drawParagraph(
            getParagraphText("Investigation",
                style: titleStyle, width: colWidth),
            Offset(paddingLeft + padding, rowPos));
        canvas.drawParagraph(
            getParagraphText("Observed Value",
                style: titleStyle, width: colWidth),
            Offset(paddingLeft + padding + colWidth, rowPos));
        canvas.drawParagraph(
            getParagraphText("Unit", style: titleStyle, width: colWidth),
            Offset(paddingLeft + padding + colWidth + colWidth * 0.7, rowPos));
        canvas.drawParagraph(
            getParagraphText("Reference range",
                style: titleStyle, width: colWidth + colWidth),
            Offset(
                paddingLeft +
                    padding +
                    colWidth +
                    colWidth * 0.6 +
                    colWidth / 2,
                rowPos));
      }
      rowPos += rowHeight * 1.5;
      canvas.drawLine(
          Offset(paddingLeft, rowPos - pixelsPerOneCM / 2),
          Offset(screenWidth - paddingLeft, rowPos - pixelsPerOneCM / 2),
          tablePaint);

      canvas.drawParagraph(getParagraphText(panelList[i]["display_name"].toString().contains("Ratio")?"ACR":panelList[i]["display_name"]),
          Offset(paddingLeft + padding, rowPos));
      canvas.drawParagraph(
          getParagraphText(
              panelList[i]["display_value"]?.toString() ??
                  panelList[i]["estimated_value"].toString(),
              style: panelList[i]["user_value_flag"] == 0
                  ? normalStyle
                  : titleStyle),
          Offset(paddingLeft + padding + colWidth, rowPos));
      canvas.drawParagraph(
          getParagraphText(panelList[i]["unit"].toString().isEmpty
              ? "-"
              : panelList[i]["unit"]),
          Offset(paddingLeft + padding + colWidth + colWidth * 0.7, rowPos));
      canvas.drawParagraph(
          getParagraphText(panelList[i]["reference_range"].toString().replaceAll("<br>", "\n"),
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              )),
          Offset(
              paddingLeft + padding + colWidth + colWidth * 0.6 + colWidth / 2,
              rowPos));
    }
    rowPos += test["kit_type"] != "CKD" ? rowHeight * 1.5 : rowHeight * 2.8;
    canvas.drawLine(
        Offset(paddingLeft, rowPos - pixelsPerOneCM / 2),
        Offset(screenWidth - paddingLeft, rowPos - pixelsPerOneCM / 2),
        tablePaint);

    canvas.drawLine(Offset(paddingLeft, tableStart),
        Offset(paddingLeft, rowPos - pixelsPerOneCM / 2), tablePaint);
    canvas.drawLine(
        Offset(paddingLeft + colWidth, tableStart),
        Offset(paddingLeft + colWidth, rowPos - pixelsPerOneCM / 2),
        tablePaint);
    canvas.drawLine(
        Offset(paddingLeft + colWidth + colWidth * 0.7, tableStart),
        Offset(paddingLeft + colWidth + colWidth * 0.7,
            rowPos - pixelsPerOneCM / 2),
        tablePaint);
    canvas.drawLine(
        Offset(
            paddingLeft + colWidth + colWidth * 0.6 + colWidth / 2, tableStart),
        Offset(paddingLeft + colWidth + colWidth * 0.6 + colWidth / 2,
            rowPos - pixelsPerOneCM / 2),
        tablePaint);
    canvas.drawLine(
        Offset(screenWidth - paddingLeft, tableStart),
        Offset(screenWidth - paddingLeft, rowPos - pixelsPerOneCM / 2),
        tablePaint);

    //canvas.drawLine( Offset(paddingLeft, rowPos+pixelsPerOneMM), Offset(screenWidth -paddingLeft, rowPos+pixelsPerOneMM), bodyTextNormal);
  }

  Paragraph getParagraphText(String text,
      {double? fontSize,
      double width = 1000,
      TextStyle? style,
      TextAlign textAlign = TextAlign.left}) {
    fontSize = fontSize ?? pixelsPerOneCM * 0.8;
    style = style ?? normalStyle;
    ParagraphBuilder builder = ParagraphBuilder(ParagraphStyle(
        fontSize: fontSize,
        textAlign: textAlign,
        fontFamily: AppFontFamily.metropolis))
      ..pushStyle(style)
      ..addText(text);
    /*..pushStyle(TextStyle(color: Colors.red))
    ..addText(text);*/
    final Paragraph paragraph = builder.build()
      ..layout(ParagraphConstraints(width: width));
    return paragraph;
  }

  Future<Image> loadUiImage(String base64Image) async {
    return decodeImageFromList(base64.decode(base64Image));
  }

  Future<String> saveImage(Image image) async {
    var pngBytes = await image.toByteData(format: ImageByteFormat.png);
    // Use plugin [path_provider] to export image to storage
    io.Directory directory = await getTemporaryDirectory();
    String path = directory.path;
    print(path);
    await io.Directory('$path/$directoryName').create(recursive: true);
    var file = io.File('$path/$directoryName/tempReport_${DateTime.now().microsecondsSinceEpoch}.png');
    file.writeAsBytesSync(pngBytes!.buffer.asInt8List());
    print(file.path);
    return file.path;
  }

  final directoryName = 'NeoDocs';

  String base64Footer =
      "iVBORw0KGgoAAAANSUhEUgAABqIAAAB0CAYAAADuICNqAAAACXBIWXMAABYlAAAWJQFJUiTwAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAALwmSURBVHgB7Z0FYBTX1oDvzKzFnUCw4BSnaJGS4A7tX+irEqhQBSq0rxpSb4ECpUaNUC8UCO5NKE5x9ySQEJd1nZn/nM0ubJaNoe3r+d6bzs5cnbubBe6Xcy/HCIK4ZmSAEf8zcAAjCIIgCIIgCIIgCIIgCIIgrhmeEQRBEARBEARBEARBEARBEARBEMQNgEQUQRAEQRAEQRAEQRAEQRAEQRAEcUMgEUUQBEEQBEEQBEEQBEEQBEEQBEHcEBSMIIjrzpQpU9iBAwfYzQbbHT169KXrtLQ0Nm3aNHYthIaGspSUlErzJCcnOw83HTt2ZLNmzSqXJy4ujt3ovl4NvvpKEARBEARBEARBEARBEARBXB9IRBHEDQAl1ObNm9nNJiEhodx1RkbGNfcjNja2yjze7XAcd0Ue737ciL5eDb76ShAEQRAEQRAEQRAEQRAEQVwfaGk+giAIgiAIgiAIgiAIgiAIgiAI4oZAEVEEQRAEQRAEQRAEQRAEQRAEQRA3mBfm7YlcuSerBxOEljqzvRnjWD2VwDW2iXIEx1i4xSFxkiwzFc8zlZIXZUnOd8hSNhQtVgmK7CCN4qjN7jjSMSbg+KKkAefZPwQSUQRxE8Dl7bz3SLoe4N5NpaWlrLJ2vZfAqwpcVtBzfyus33P/JwT3dsK9o9x06NChXDsNGzZk1wrW77mH1PUC96LCZQAJgiAIgiAIgiAIgiAIgiBuJB8v3O43b1P+ML1N6i3wXJ/5WzLagGgSOM7BApS8lnHcUbNDPCzDNGyEn8rhMNnzLXbJoVJzfgEKIUxvcwQyxuFEbIQoSV1ydObx4KnYpnOlUu2EJQeUPLdfrVQs69Gw1vbvX+1WxP6mkIgiiJsASqj58+ez601qamqlIgrbrakAmzZt2hUiavz48VfU6ymiUBhdb2mE9d+IMUNhRiKKIAiCIAiCIAiCIAiCIIgbQWJiIv9bYaehBrM05oNVF0fbHHKwO81fxe8JVqg+6NQ0aNePL8Vlcxwnu9MKPOrQ+ao3NVWxdaXYPMtgbAaC6jOTTbzdwtjteqvjkbUnsvQx45dsrBWkXtCshf+mRU/HG9jfCNojiiAIgiAIgiAIgiAIgiAIgiAI4hp4Yvq2Wo0fS3nz6/MdTuaWWlfYHOJ/NAK/olaQ3331Q/2fEXjOClKqtZ2T79A7RLunhKoOSfHxjqBAtUOU5DEmm1RXJXAljcL97g/XKB9Q8twGmyjdmVFkStn2V8mxFk+s+LDH06uufdmq6wSJKIIgCIIgCIIgCIIgCIIgCIIgiKvgyZm769d/ZMmXS47kpReb7Ekck4rqh/uPH9DIL+r8d3c/eOrL4b/6KSS9UuBtDkn2KzLaXthxsjSj8WPLv2nyeEo8Lt9XWf33/3dLWKunlifEPpKycfPZvBNFZscDeN8hsVCeY3Ufqtd+SXby3f/37qTYOtFB6nt5Ts4rMFinntabzzV6dOknLZ9YGstuMbQ0H0HcImq6PBwuVee5HN71ahf3kaoK7zxV9d1XX73ruJpnuZol9arzfARBEARBEARBEARBEARBEDXh2U9Wq/846UhadPD8RFFiIaF+ig2NQ9Vv7pwzbHc2Y/JhyPPQ25sbbTtf/NmpQssQfyWf3jg84EmFQnEyV29O1Fns4xyS9Mj7K3Ic9cYvOSfw3BGVwBWoFApRb7ErFTzX2GgTm6/Nyq8jyZJCwTNjoEoxq32j8C+Li8zNz5YY3j9bZJ7+nWH/uJZPr/q/iZ07n4ImF+Ix4NX1Hc4VmqaXmh1P8Tb2RINHlrzfITr48+Xv9c9jtwASUQRxC0Ch0qhRoxqVwX2ZcE+oa8W7Xayzsn2kUOSkp6dfcS8zM7Pctack8tVX7zquBtzfafPmzTUqg+2SjCIIgiAIgiAIgiAIgiAI4nrR6qlVgxfuNX9qdUhNAlRCauNw/xe3zB68z3MGtOsLa+5bfTL/M5nxoZEBqml3NNPM+GHqICOmJSbKo+aeWbyfY6wdz8nrbaIcrmR8H53FESEzu7O8RsFb/VTCcaUknzNapT4BSsWurnr7S4ve6CNC8mk4Vt325IqphUbbfw1a84mWTyx/9d57g2bgEn4b3ht4ANIH9HphXafzpabPod43d2brHo17aePTaR/1T2E3GVqajyAIgiAIgiAIgiAIgiAIgiAIogr++/mhsEaPLfsxR2taw3Oco0GY36js+Xf3RQnlzpOamqpoOCHl09O5hp+VAp97e73gTme+GpXkllDIz7krvpCY3K5OkOrFvO/vGZb//T13ZM+/K8pfqXgY0+sEqx+bGHvIP+Ob0R2zvrsrLsRP8YXW6uj7V7Bikmd/jn8xYnpc/dB2IWrhUK7e+v4Pv+qX9H51bR13+taZg/ae//aubs1rBSSIkigeyC5Z2nTisgVtn1wZxm4iJKIIgiAIgiAIgiAIgiAIgiAIgiAqodEjS7t+t+vUnlKT7YHawZrP7u3TqPuhT4cv98zzn3fW1U/4SbtTa7U/HRGg/qFjrF/3jR8M2O+Z587n14wsMtoeA9m0ZMwXI2ddTuHkID8Bo52YgzFTUlKS5E4Z2CV/sr9KcUZvlWb2fGlNC8/6Fr3bLzvj27s6BGuUb+lM9iFnc8zba3vtC7V71tAFD93etF1kgPqbEqP9oVyj5VDci6lt2E2CRBRBEARBEARBEARBEARBEARBEEQFdJ28+mGjQ061OeTGGpWQWUfD3p89vmOpZ542k9e023BSv1lncdweHax56cxXIx9ekzRU55nnpW9PBJ0oNH2iELh8f7XqmSSOkzzTc0ssBjwXaE1Gz/tfTZxorxvqNxpclSkj3/zrs5+cVnv38fy3oxMbR/nf7xClINkkHek8aWU50TT7uY6l0Ob3vMB0dlGudzinaH/7Z1Y8wW4CtEcUQfzL8N6rCfdd8tzfSavVspoyefJkNnr06EvXaWlpVe7LNHv27HJlCIIgCIIgCIIgCOLfwEJZFjrCnJxouhChN5mCHBzPi3Y7HyBwttAov4JYFouTjw6O42RGEARB3HKaPLZk+qlC44tqBb8/WKM4pLdKDxwusmY2eixlVsMA+d202XeVtn9m5aALxcZvlTyLaFk3tN/m9/qn+qpr2V+nPraJUsPbwoO67Zg9OIfVgL9mDT7acdLqD9OLjG8tO3hkMtz6yDvP7o+HLIp/ee2pQxcNyzNLrbvufGXNfX++P2R5txdWt8ousc44X6wfAs9hrx2oftVgF+/LLLF8EftoSosudW0vL0oaa2M3CBJRBPEvw5cgyszMZNdCaGhouXrxdVV1lpaWMoIgCIIgCIIgCIL4tyDLMqdl2tDjF4/2PlxS2Edk4h2cQmggcVIQ42ReKcl6ZRE7etxxZleDyPqbCowFJzP9Iws6c5ydEQRBEDcd/N6OfWzZV0Um+6OR/qqVd8RoHvkhaVB+v1c2fnsyVze3xGR/0WjjH27xxIqluXrrPSB45AB/qTNIqKO+6uv733V9D2TrJmiU3Hc75g7eza6C/Z8Mfbv+I0uHGW2O9/v9d8Pvmz4YcM47T+qHgw8mvJ/aZ/Xxoj+OZRl/q/9IStrZAlM/UZSVtYNUK4MFxQu7Pxt2aszHC2fvPab+tthsm7LnojJi+OPLn1j51UgTuwGQiCIIgiAIgiAIgiAIgiCIGwROZJ4yZ8Wsztg9vFhXOt7qsDcVZclPqeBKBFEo5kTxosxJvIPj/e0KoQ3juW6H8tOfCtTl5YVrQlL2Zh3fVrtu3Z0xLKiU4zgHIwiCIG44+N1df8LSbww2cUKoRjnvgftHPpMUX/YdvOn9/lvg1LH9MysSLupsH+TpLRPxfri/ck20EKQ/U0GdJ3INnyh5Tt8qRPlqLrt66gYFP3WqqHjn2XzD19DP/r4iaE/n2yMVAldkskmN9Bb7YAXHZdULVj94+IuRm915Fj0/1gzlH2g2cUUmZHx5ryDzIKMevxEyikQUQRAEQRAEQRAEQRAEQdwAcCLzIiuut/f8ma/0JlMPDc9bw9T+q0Qmp8bUqXMiNDyyMITxZgsDw2Q1+2v1pXVLzdpYyS7fZzSbumXZCl4KUKoK9Rm6bZbw6G8K5IItUVyUnhEEQRA3lOZPrvjCKaH8lJ9kfDN6ctK3V2SRZaZKEyWrRSVwViUv5Beb7EO0Fu25uuMX/+mvFH7o3yEi5Yunepdg5oaPLZmgNYmt64donv1jzoi8qtpXKZR8RWk7Z/fbV3/Ckm9LrY4nOk9Zew/cWoT373pxXa2DWvMTFrt099F8bXsO7oX4KfeabY4YhyQHOzSqQu+6XBLrlTbPrLBml1rfPMZk6yer5acmDeWs7DpCIoogiErBJfSmTZtW7h7uK1VVnsTExHLXSUlJjCAIgiAIgiAIgiD+LYCE4tdk/dU7R1vyocMqdlAwfmnTmCZf9IhqtpXz2pzeg1Ousj9mWQtiT1xMf8xhswzW6YuGnbYWD/Er9tt9sODIjHqRdTaHs3BDJfUQ1xEUijhZ6z6zGnK15a4WbC8rK0uj1Wr94NLWunVr0/X8rFT2PNfrWbEe92vaL4242TR6bNnrBXrrxAAV/wVKKF95Ej87EvjNXyfXcRyr1zo6+M4nu5TunLk1+M4svSnBJkp3G232+IU7875o8EjKFl5mm4w2cVKwRpF+95jhXx7+vOK2o4I1gQVGKwv2UwTkV9LH0R0i3/xlT8EDF3Xmj2ISlvaWZbHXn7n6DiL87PiphMJQjTKxTrBy6Y5Zww7Hv7K+55GL+uWlJaZVg17984517915xd5URz4dMa31M8v5i6XWNz5JWQZNy6/CT991+9kjEUUQRKWgZPKWSOnp6eX2hEIJ5ZknLi6OpaaW34+PRBRBEARBEARBEATxbwEm0RX78k+2yisueqNYst3exL9WcuPA8KT2Uc1yqiMEII8d6jhTr1HU60eyjvxoDfQbVmQuvL/UXNLZIkpfF+l1e2LCayfnyvo/o1lgIQmpa+PDDz+st2LFiqdNJlNEaGiorlu3bt+9//77xzBt48aN0XD9XOfOnUN79uwpjRo16peUlJStU6dOHb5p06bRripwslZ2yyqv6rlOnTpxXbt2NcyaNetdqMPn3PKMGTNa/v7774/abLYgz/uSJPHR0dH5kZGRGZC2rXfv3mefffZZmy85k5iYGHjy5MmOd955513nzp1r6XA4wu12u7V+/fqnJ06cuHrw4MF/3HXXXZc27Xb3dcCAAR8WFxeH4q0ePXosmTt37npf9WN+GKtWHTt2nHz77bfLPM/LY8aMmfPyyy8fx/SxY8cOhbEa0a5dOwUgQrrz+f39/U3BwcGlderU2V+rVq29/fv3z4uPj69wmcnhw4e3bN++/fNGozEIB7RPnz6/bN68eYU7Hca+9/r168dh+xqNxgJj8uFHH32U5V3Pjz/+GAzP8iKMQwwcrFevXhs/++yzXxlBVELjx5ZNKDHZ3vZX8j//+PDdk+Ln+87346GzHxvtUrOGYX7Pp04fuM01E4qn1JEvbX3mrK50mNZqG2uyOUY6JLk/JsJPhHX+D8uX1puw5EiUv+qMmnEnBrWNPpk0sfOlSCVBKDubLeKliKjExFRFdpgYcSxDbJ1nMHfS2x2Nlx8sukOU5ECHKOF3xrMaBVcSFqCcpRaElVFRAVvSkuIdGa7yqe8P3NbsseWPl1htvxzLLfo2MVUe6V5m0JOjn458s9GjS+oUGe3/bTVxZeaxeexLdp0gEUUQBEEQBEEQBEEQBEEQ1wmMhNqcf6LL6exzc0WONW8cVGtetybdX46BecWaRHa48trgOAR1HilhF386nXlmgEF2vKq3lg45m2PqH6krXW/QBH8B6Rto/6ir5+LFi3WPHj36UElJSd2QkJCC8PDwlXDbKaJKS0vDDh8+PN5isdRSqVSW5s2bb8X7Bw4c6A3HhOq2oVar80B0zYGXPkVUenp64/379z9utVqDKqoDJFnxhQsX5h88eHAuXGZ6pu3cuTP48ccfn3H69On/QF9R4DCQQSiyGDzXnSdOnHgwNTV1w6RJk57/5JNPTnuWPXTo0IP5+fl18HVOTk7zvn377oHyxd6f10WLFgUkJydPBdk1Dq8FQZC7dOnyC7x0iqgjR470hLSJKKywXSjvLId9cecHGXV8796906Evv4KMsvh6TrPZ3A/ej0ehDqxAhrFTgUBKffrppw2YDhIs45tvvrlLp9OFY91+fn643c67nnVgH4YOHToaxvQFURT9IU8JCLmFjCAqIf7lte2P5hpnB6kVW/vWD306Pt7392qjR1c8XWywPOanVMw++OnwWd7pyz/qhUuoovT89cH3U5uuOlp42k8pZIqSdNIqOm4TZXlQRolZiT8Zp7ZksMiHF5sEDv+M4K1FRkcg1gF/fsyNHrf4A5BNfp+dKwqAMkr8UcKfK56TjSa7VBDhr1hZYnbcDj8otZ67s3bDlx/pVeHSrae/Hrm45ZMrEnN1lvd++W3la3DLZ9TAwz3Dnv1xu65+kcU2s/OUNSf2zB6Sxq4DPCMIgiAIgiAIgiAIgiAI4rpwqPhMTHrhxXdMkr1dgFK9pI66XmJdjjNdy/JiGPEUztU937Xhnd9FBUUNqxtc+yOlQigoNRcNy9ae/+lg1q7vMgpP9JXlC36MqDEgbCR3VBm+T0ql8tJ7BQJDcosUV5qIZyhTjHIJDxBUuXAugntWnCTG/JBPp9Fo8vCAtFyQSFkgWCr8DAQFBdncfQBh4/D39y/Bclge+lCK9aJ42bNnzyQQRzNReLrLJiYmhj/66KMfggh6BCUUlLdBmazatWv/BfWehf7p7Xa7+tSpU8PXrVs376OPPqrtjobCZ8HIInddWq2268yZM3v6+rzOmTOnI4iqQRjphP1B2eQG68OxQXmEzw9tmqHvOTg+gYGB+XDWY1p2dnarP/74Y+4XX3zRx9c4wLPwubm5A9z9wzNIst4//fRThPvefffdd6Fly5bfuduH5x77wQcfNPCsZ/bs2SEg9x6y2Wz+IKIYysV+/frtZgRRAUMSVwcfyzUtho9vkcBJDyYnxZf6ytfimeWNdDbrKyEaxb4BzYPeqarebed0I/ErpGGY39S8BfcMeiI2vGWL2orYRhH+Q0L9lU8EKLk3NAr+W38Fn6bk2TGBSc5l82SJGVUCd85PwW8OUAnfBGsUbwYqhcebRgUOub1OSPP8BXc3PvPV6JG1A1VzHZKsnL+7aEBVfbk3vtFM6PemIoNl6p0vbb7NV56k8fGWyDDlo4xjuedLTN/0fnxxHXYdoIgogrhF4PJ1NaF9+/bsepCWllbuGpfYc/+GCpKRkeE8PPHuK/zlid0KOnToUK6v1eFW9ZUgCIIgCIIgCIL493HEkF77QEbme3qT8Y5QdcCSxlEN3+4RXb+YXSdccuAETMgnZpoyFxXq8h8xGPV36xzFDxp1pcN1ttDP8o0ZS6L8Gx6CvCIjrhkQOOUmIkDyOOdT33///S8LCwudETYgXeSjR482eO+99z66ePFiVxAyth49enz02muvYbQQA3EjGo1GHiTR+eq0GRAQoH3wwQcnP/DAA1uhnGrt2rX1lixZ8mJmZuYQh8Oh3Lt3793ff/99G/gcHIbs3IgRI+4E6fIALuMHfTF16dLlkzFjxiRPnjw5HcRT4Oeffz7kzz///AQkUzjIqPilS5c+OXXq1LegrNPkuEUbAn300+v1T8LL5d79AqFzD/QnGsWOe37GU2LBa/dYybfddtumV4CIiAgTyCv/1atXN0tNTZ1TUFBQH+RQ4Pbt258AqfZH586d7Z5tNALgOTuh7HK3U1xcHNWiRYse8PpSFFjbtm2/P3HixKiSkpJm8FzNVq5cORhuf+VOB1nXHupBoYbRaOaJEyfOfu6550oZQVTAiYu2dxyS2KBVnZAhWz4amFlRPskufwSf9MDgQE2/71/tX1RZnfCZV4yZXzTZTykcq9ddvwTvJSU5l6W86DquoO74xfcwUV4EkmrqyS9H/OSd7l6Dkvuo7Jz4UMdPnpm3e4reJr0Al0sq6Q5LGtvG1v/l5RP2XxS3nC4o/CwhMXUoCLcrIhN3fTQ0q8eL6x47matbcc6umDNm4cL7Fo0de01/ppCIIohbAMof7z2Ubhbx8fHlrrEfnqLJe7+nW9lXb2bPns0IgiAIgiAIgiAI4u9IiVwSuiH9xDPZppKxwUy5tE5Y/Rd6Rje7yG4AMLmOS/btK5ALTuv0ul9KzNkvOuz2tnqz4XmbPfueXHXx78eLjy9sGdbyFOS1MqJScMm4qvK4ZQ3IHueLjh07otS4JDYWL16MUseEUTpQH0YWFQ8YMOAcqyZeQkc0mUzZPXv2zHS1fSYvL88MgqhjUVFRHYws2r17d/tx48bhso3CuXPnEsxmcxBKFxA2S++9995pkyZNsk6ZMgWLF0Oenzt06BB97Nix90BkqSH/f1599dXfQJwddz2/JLg2psGoI5RVzz77bJ+5c+dudvcJ8rb86KOP7gE55I5UwhMn4OCVRSrxkMbjfVdUmDEsLCwdxsDoquJI06ZNG4G8+wjLgNCKLS0tDYf7eZ7j8O233/a1Wq3ROI4g1awo3lCwbd26dQTUuRSyOD/PMH91HJ5p/ubNm9+B/H4XLlyYlJ2d/WNMTIw5OTlZDelTQHj54bNBvl/heQ+CGGQE4YuFC2XVqxuWZ0T4Kx8CCbWponwPTd9Wa/eZwhOhKtWvh+YMOVlVvS+u1IcGqlXfBjG2edHYu6slcqJC/PfwOvMLJVbdjurkH9ujvrntU6ue0FmsTcY8t91v0awe5sryb/xw5Pk2z6wYV2Kw3749R4/LAPpcInP7jEF/dH125VidTWpcsD0Ulwy9JpFLIoogCIIgCIIgCIIgCIIgrpG9udn9s3UlD/urNQVNwurNHNig5Q2RUJ5EcVG4H8hWEFIHjXpjW62+8PFSu26k0WZ5JdhuuvukZf8SmLyfAXl017I0IHEZkB4+94yxWCwCjLHnNigSuwZAwHhOWgshISFajUZjcN8ASeNM37ZtW6309PTbUQCp1WpLRETE7yihPOvC9/7tt99eM3PmzGdAkDUCCVTnr7/+aslcezthFvcyd1gPCBz1hg0bxqempu6Ki4uzLlq0iH///ffvMRgMUZ7RUwjklbF+uSxBdtWBN3iQZ+XygmArADEkwrMJIK1QfpWLNps3b57/nDlz+kNfcM5aGjRo0G/Qh8Eg5WoVFxd3+eCDD1q/8sore91DNGbMmF+jo6MfzcnJaXz+/PnW06dP7zNr1qy1v/766x24xCAKsaCgoKzGjRt/SRGCRGWMHeuU+x9Xle+HqT1xj7c3WDXZO3NkIZzeYjXgwOwhGdXpiyeHPx+2DM+Z1cx/5NMRaXBKqyrf7rnDV+H5BLt2PL8cO8ARV8kRywgkDo75cExm/0zwfcb+z2I3hvmug9ZDIwiCIAiCIAiCIAjifx6cdM+T86IvFOe9YrVZAmtrwqYOqN9mL7uJoJCKDY7d3i6m06NNGjbvHhEQ+bHMi2FmVvLa/swNxzMK9n+Tp8vocYH2kLomXMvR1WzPgKvAJXJUe/bsUZ4+fVoNYqXWjh077gOx0xj7ALIpt3///n9g3q1bt8bCKRA9UHBwcDGkp/uqc/jw4TmQJx/zmc1mv6Kionpw2xkGhVFOeN8VzSSjlMrNzR02f/78OzA9JSWlcVZW1kTIp/SutzLBWb9+fSXUqYG6AkCE3QbS6mmQUCp8xCZNmqSC5Mr3fOY1a9bUg7zx2B+FQmF7/fXXk0C4HcV+6XS6Bt9///1QjABzlwERdb5p06ZzlUqlBfMsXLhwyty5c+vCOE0CERWDz9GoUaMlP/300z5GEMQtxTMiCsVEXBX5MfwqBY4FrBrG7H+UWDgSWNnzz2H/PFAQJcCRAcdzrGaMhgM3KkLDeqCCPAmu8zR2jeF6BEEQBEEQBEEQBEEQf3cOsTz/C2fPP2i0GNvWDYtYWL9ps9W3KvoI2nXgMm5+4X7vGPWKbXa76UGDWNpfay26T2/V3RloC16bZ0hfWSsgEibmA0swPyOYe7m5vwsmkylk/fr1iZs2bTJgdBD0L8JgMLSFs1CrVq0zffr0eX/YsGG5mBfScaU7DgUVCBmHv7+/z8gfTIN8NrdM8/Pzw72mnBc8z1+K3gKxcyAjI6MViJyIgwcPPnf06NFtFy5cGAPiqi6UlRo0aHAchRjuJYX5QSy5i5b7zEOZHvfdd9/P0D+l3W5XQNv1SkpKmuLPBrSx7oknnvgE63Pnx/ujR4/uh+3iaxBVR7t06ZJ+++23b9ywYUM81KOyWq39n3nmmc8hu3NfnrFjx4offvjhQujj+OLi4nYwRp1+//33KWfOnOmH6aGhoTlt27b9hj7nxK0GRWuzSXNVE1oMwKXw2HcnNxgeCC+yJyUlXVPk5PUmceERlS5LF5hxUa8IDfeTOYG31DfZza59ra4JX0vzZbgObzCSxi0x8EARcVcFeYn/TUaxyxLrACOqTUpKyg3ZZykzM7PKdl3rAV8iPb38L8YkJCQw+AtGuWvPPJiG+0R5kpaWdsW9642vdq8H8BcaRhAEQRAEQRAEQRDXi4L07NuzinMmyZJ4rK4qbFY3Fm5gtxDX5L4OJj5XwGlLYUDhHSXG4v+zWa19TeaSJyWb4UGLvnBTUFBEiixrVzMWXOopBIhbD0YNFRYW9nZf4/5NGN2DEikwMDBDpVJpcWLbFb10aVk91x5NPqVaZGQkiqJLaRXl69ev33dLly6dALKp46FDh0asWrVq6JEjR+7GstB2ae/evT9atGjRPJfQkqEvbgGF+0XJrvsYwRSDUUmufl56DjhMISEhx0C2ea7UhXNRGqh7KO4HhXtkRUREpODz/ec//1mvVqvfBAmlzsnJ6Qwyqz5ziSjk5ZdfvhgXF/f5tm3bPjGbzRFbtmx5HvuiUCgcjRo1Sn722WdPLViwgBH/Hjo+u3KxRbwxX2kqXtAe/HTYhKryjfxwa1BGemkHgygOsYvinbUTlkQ7xJiAT/YcC8QfQ4dYx/Cltq4+etzvBYFK5Vme59aFBQinPhw59EB8/GVxmpgqK6zHtwZV1E6YnnO8/HIvPbsKHkjcGXy8pLCZWZT7miyOHmaH2OSLlSfCRcZpBMb8WL4B1xc180zW10lYUqxW8pkBCmGT3SHvfuauEYcmDa3Z/oO+RNQ0Vhbx5AuUUbgk3WjX6/1wxDOSEgRRKaWlpc7jVrTrLat8yZ2q8lQlvG4Ut6pdgiAIgiAIgiAIgqgOJ+QTQTsOZTxtlxx1WtRr9HqjukFHmVdkyK3CJZeKQQSs4dWhW+zG0i5mU8EIm8Xc0y4a+trs9n4Ws/5+0Bgri3SH9muE4Ax//2ATTG0aaD+dmw8KJfdr3AuqW7duvwcHB2eClJEtFotmz549XUC0dD537ly/rKysHvn5+SELFy5ccObMGfe+TM6oooqi8UBscR6RT0551alTp0sSySNrTrNmzX6D+jvixVtvvTXfbrer8TWIqK1jxoxZByKK86jH/dqzHywmJuZYly5dUkCO2UEiKWGOKgT62lOv17c9ePDgJHiGDuPGjXs8OTn5HJabOnVqc4PBcBu+DgoKygeJtGXr1q243GBG/fr194Ko6gH1+EO/BkMbBz2f84EHHkg5ceLEWJBnfd3iC8qdveeee77q3LmznRH/KnK0lrst4o35GtYo+HOVpQ98fV2ji0XWqTuP5o21iVKEd7pov9SvIAeT6sC5udVh6wnnhwtNnHxf8pKzLZ5Y+n1seMQ36967M2f76g2NDhbo/6qoPRXH4R5UTVk1SUxMVawuMXYtMtmf2XAuu69NkqKvzCUzjz8A/OGIAMsda7aLt5cy+134A//Or0syWzyxYpOC2b47+uX/batG0z5FVGWgcBoPRxIcS1mZjMIwD5JRBEEQBEEQBEEQBEEQxL8GnPBOO7ezm8FUGhfiF7qpS93btoYyjSqP5QmQhhvfO27VEn2euCOk4NgE/UorLc2tb5ZK77aatQ9YrcXxErP3t1pYrlIwHLQ6LOeDgh2/yXLeScZq4dJ9NkbUhOuyxJ9arTbVrl17wa+//prmvpeYmOi/ZMmSj48cOTLRZrP5w/nJo0ePrvbz83NGIeGB0UQVRTohrogpn/s6uaOWAA1IoWSof6pOp4swmUyhrj7Z7rzzznkdOnRwLu+H9SAe7fFYv+seyqQj48ePf2/kyJEmd8UgtVrPmTNnUUlJyW0FBQV9QB5hsMPHcChSU1N7gmir54r+4uB17xEjRnQsKipSOBwODup21rFv377haWlpXzKPLUEee+yxvPvvv/+7n3/+uS9eQx1iq1atvn3llVcyGPGvw3YL4jsfT1zuv6uIe2FPhn6qJMtBV1MH/ixZHHJTi156q9iY93SrJ5Z/EqQU1trsUkhFZfz9lf7u6MjK6n72k9Pq1NMnh32dWfya2SF3rOx7osp+wgGSrWGe3jKB57jx9Scs+Ss8QPPGwblD11dWrqYiyk0GK5NPKKFQRs1yXVcGfrHg0m6xrmvP/aa8iYOjjytPZfswJcDR0JWnonCTOFddGR5tucu59zqKc/WtQzX6Vh3wC3qcq95Q170MV3sp1Sjbwas/zNXPOazqpRCxPK7F1p5dbjvF1XZVZStiske/EHwvYz3SkyopG8fKxsKdP4OVPUdV4tLXGF7r+0IQBEEQBEEQBEEQBHFdyMO9oYpyHlEzhTrCP2jblqO7H+EVihYMg07kM0ZRlo4tPrD+dGhAUGZkUFRWcLSgi2WxuOSSeAv3kMLZ/AyYhJwN53lG4/keFwvO3c8pbP0ZZxxQatCptPqch/0Dgs8KfOHm4tKTO5gkH1OpVHnmgCBTJIvEpZhkVnHUF+d1rgQMHmuNU8aSZ31/B3lXCRhVdDP2k3K24znBnJSUZFoAjBs3biJeW63WJqtXr64P0qgARI1ziSyQN8F2ux2jLA57V3j48OFIOIWjRIL30wqyBveY8hX5Jo4aNSqve/fuX+zevfsV3IAKo6eaNGmyrkWLFqlarRajo2QPceVJpe/dm2++ebRXr14btm/fjpFPWPWdUM9MkGwB8AxjcPk9eG6m1+tr//777285H95LnIGQajpr1iyM1iq3B0ZCQsLuX375xSnB/P39jaWlpVsZ8a9Ekm/uV0hcYmrt1RdKlhmsYld2nbBLLPqi3vpuodH+HLtGBr66rs3iA4c/M1nFO9l1Bsaa08NzG22mtU0fW76oXljQC2kfxWf5ynu1IgpBKYB7ROFmMnGuI81HPrw/n5UXF25QaExjvpcDnOZqYwHzLZliXfW6+1KRsHIvJZjs0YZbcGS40hKZ774lsLJnrMmaalNc9YX6SEtglyVeRgXpsyooG+eqG6XPNFaztuNcZTD9atY6w3KxHtejXYcbXyIqjJWNeZyPtARW+XNgmao+MxWN4d+CadOmldt36WYRFxdXZR7cA8r72vNehw4dqqwD950KDb38MbseS+hh3+fPn89uNp7PQRAEQRAEQRAEQRDVASa7+fUZe9sU2c2DrQ4xyFyaM8lqsobxAqcom4vnmCzJEigLa5DDlHemKPdMWEHwaX1DYV2joLDtUL74Vi5/54qSMkI/NjULCNtXosvoZjAbO6hVXA+HaLvdaCxtJgh8S8j3EHQzX2+1ZfE6OS+bCXpBBpHGOIeCE2AUysQDz0AUSJIA+dHSwH1JQB8HVzKMiTMPlJFhTCAzJ0NGGBulneP+sqgEpY4xVTETAg8y/6Az0Cfd31xG3Qw4EEouDyPz7j28QNagvJFBxmACbqYktWrVKjskJCQ3Pz8/GgROEMicgZB1vXeUxOeff97ZZrPVxogjPz+/4pYtW571THdHOLnvde3aNeXYsWMTLBZLDNwzgYT6FW5bgoKCVK58zEsSSZ57ROFnwfuh8FlAcAmu1zJKJyQvL6/RuXPnbndHdrn64qzIncfdR4PBEHXx4sUuzEtEmUwmzaXBA6AvV7RPENebMR/sCdl1+sIqkFC3sxuATZIi2TVw5wtr7t6bZUgWRemqorSqCwqpQpN1bInFfkf7Z5c/enDuyCuio65FRCEZrCxCBeUACp80r/QEdlkWYRr+toU7EibWlY5HMisTF7M98qL8cUfhpPloO87jNbZfkYhy5/OVnuBKT3YdGa5+4L1EdlmI3MWqxzR2WWrhuMz2qLODKy2WVby3FuYN9Sh7kJWNA5YZ51F/Kbs8Vr7aTnNdZ7iu411pyazy6KWKmOLqVwK7PF5pVZRBodbB1Q+MxiphZeMw2VVPRc+BaZ6fGSyf4bqOdeV3LwnZkdVMEt40qiOEbhXeGzSihKppf5ctW1bu2te+UzUF6/CWZARBEARBEARBEATxdySDlQZfKM57pshhCxVgvlyy2EJC/AJ2ijbHKbVGpQNLEMAkVkvi5HpWu62JzWyJt9lt/Yu0JY8dVvudCfMLXLY9ffeaKEfYzmbNmtVow/friUtwFMGxGib518L0TZCNGRs6rLYGelNRT6NZF6vipToBKmUMeKSWoAnUnMQJnCgq4KmdzqFsXyIQUiieyv6DyglMAC79JGOq7NRQcBMlVJlngJuiVWCgUqyyQymgs5BUpTad5jf/2g0+gPTsmyWjsC8vvvgi+5shg/BRQN9Q+nDZ2dnC9OnTG7777ruTsL8umZTfrl07fevWrU3dunVLXrdu3UcgmpQ7duyY+NBDD+1bsWIFzi+a9uzZo/zpp59aLlq06D2z2RyOMic0NHTrG2+8sf+7775zNua5P5WbOXPmHEhPT38KBNftGo2maPHixb/j/fPnz3OuJQCd+ZRKpXs5QDw7JRO+dyqVCqOXVHAP92iSsrKyVM8880yvU6dOxaFcwg8P9NcZuXXy5Ml7QKI5lx+rU6fOCcj3YlRUlBavoR4JpBybPXv2a4cPHx6K/kqn090P54+hDoe7v9CPSzIN+ldZ1B5BXDe2n8icZrRLN0RCXSudJ68ZeTTf+KsoyUp2kxAlqX6u3r689ZPLJh79YlS5SehrFVEIzkijCIrzuh/LymQEMo1dKUAwhGIzK5MM01x5UcykudKTWZkAGcV8S49xrrN7aT0UJd5Swn0/g/leCi7O1cYcr34dcB0oO9zPlsYqJ4FdFkH4eoGPOpNdB/Yd99jyFilprEzWeD9HBisbP/wCnuVqx1PgxHq0PY1dOdbJrgOfZzKrOW7rEMcu97Oq5fFiWdnzZXjcw3EYz8qezx295f0cVX1msM5kVjaGWP6awxMJgiAIgiAIgiAIgiCqC066rzy1p4dRtPfE+e4wlX92LU3o17c1aPGVJrJhUWvGcHJckVGa4Z9rsYQWFeQ2lUJYG4PJ3EdvMHTWScYmOqvp+dxS/p6LysLN28/sXqRn6n0Dm7QruJWRQC4phXNPh+AZj/irVZu0YdGaEKYMttksIUajLhiePkSp4P0kgflLkqjEUgqnf+BEPOEqe5DGBElWyIyDE4M8ooAxU6xs3xZZyXOiBPck2aEBWeUv8FI4k22t7aLpNrvDPEZfyBmDIoM+hLzF7CaBkTyuMSjrpMf+KS6p4UZWKBQ+3yMQIU754bFkXY2W8AM5c6leo9EYsn79+tcaNWr0DMgaXAqPx/2TQMA0xWXyMC8ImzX333//eXzfHn300V9iYmJ6gyS6C+RPAEij2ampqQ/069fv8FNPPRV67ty5/kVFRU1QANWqVevk0KFDZ0Hdlksd9Vxm7/L+OhLIrGUwFsvLZGNZnpKSEtnjcyqDJJJckVuX5A++zMzM7PnCCy98B+2rYcysJpMpDJ6lFTxHFD5DcHDwWZBoKx5++OGI119//U7I495baisIto3Qx3KCdvDgwQtPnDjRH+UW1N3yl19+acHK1ndkns/hitLiUEwRxI3ktkkr2xSUmCexvyEdpqzqkFls/uVmSig3VrukLpAdX7V9dmX24bnDN7rvXw8RleY6h7LyMsi9RBymVxaFk8Qu72uU6FHfMte9BHalbIhlZVIE5Q7afYyQQTHhHfXkllUpzDfJrOJIqjTXEcfK9ltKY5XjKYIqkzQJrvqwzyiFvMemsgif2ezyuMZ59MnddgarfKzdSyneDKaxipfOwz4msMsRb25J6H62ZFb5c7gFZYIr398yKoogCIIgCIIgCIIgiP89srKyNAWFOcONFn29MJWfpX5Q+Adj2vb/Gua+PSfOba4D5yxwT6ZNcJ57JPNI86zSgsF5onGs0WjoZBelCboC+9gQdeC+zUe2zi6QCzZGcVF6dotxSSmz6yipKB9Gp1SQ5Os+mgzZ43DbDxVj+gCHJa+1WHzubaW1YJK1JBd/eX01uwmgRHnppZeYx5JyPgWSe4k4CS2KFyiuFi1adMVtVgMwKgkjnfCA16qLFy/e6brv7pfzHBAQoGvQoMGqr7/++u0OHTo4P3PffPNN3sKFCyeB+PHLy8vrZ7FYorKzs4fCMcS1RJ+zLMiqfd27d5/8ySef7Jk7d+4l4QZS63KnObnc83vLUYPBwIMMUnqku99rDtp1L9vHgbCK0Wq1d3mMkXMM8RweHp7ZtWvXF7/77rvdcXFx/R0ORyuok2k0GkOLFi3+GDJkiM17fCIiIv6qW7fuCZBQ7VBGzZs3byTUddxj2UKF+znhNQ/jpmYEcQOxmO2THBL72y0BOeaDDSHbTuoX2kXRn90ibA5JlV1inv/4vD1dv5rYOQfvXQ8R5QmGULqX1Etw3ZtWjXIoE1AuxLHLYiLNo644Vl4ExbnOyaxMWE1jvpfnc+erSAwdYJVzwKNPlYF5Ylnle1V5gmINo5Pcez5VRKyrzlIffWro1T4yjVUO1pPsavdGc5BV3o8MVjau+Bzu92G061zVGHo+BwqpqqKzbjopKSmstLRiP4b7Eo0ePbpGZXDpOu8l9LzLYLrnMnm+lrtLTk5m1wr23XNvJdwPy3NPLHzt3Y53P7yX88MyaWlpl659jdH1ANvw7KuvcSUIgiAIgiAIgiCIijhSmBVtc4iDeYkJUcqAn9rVqb/AS0JdgWsyH/eEOg6T5yd3pR/52RCq71Kk091ttNn7FphKepgUyg6FB/bt3XBm2y8B6pDUO+q1PueeZP+7Ukn/atJvp/CCcdklqQr/YNaizlZDYQ/5woVUrn59M7vBoIx5//33TbVq1doKIqR2YGBgUXBwcK57jyXAFBkZuQ1eB4BIEUFwnPeuA/OBCLKFhYUdsNlsdpBFVpjXuMBqQEhISBGU3wr1a8q6JUuuSCQR2uXUarWxadOmR+vXr59iMpnOdezYUecZuTV27Njs++6772GQQXft2bNnuF6vrw9SKwDyOKBs/u23375MqVSugH6e85ZLUVFRf0C+WvgaZNUF9zP56ifUYYWxWu/euwrEUZYrSYL7p6H9NSCrVCidoH3JZcGcEVMwjhdbtmy5tXbt2mkgwnCPKox0CgTBtBZFEvZz1KhRqb7afvrpp9Pz8/O/gnrvxKUBoR+GM2fOoBBz/uzB+6aD9jfhvll+fn5mII8RxHVGcvllECzKlG2ZfapbTiFwDo0gLIQfhZN6q2gKUwuRVllWg5dtIslyd5soR7HrxF9njP812cRm7BYjyazepj0X0H08jteehhvFSBy7clm5qkCZsN/12l1fnKs+nCEPq2Y9+111eS6VN8t1PZuVj4py97URKxMa7mvPZe3cfchw5WM+yiewyp8VI3SmsTLpMd51D8vMZ2ViLN4rXwqr3n5SOIPv/m0SXGrOU4glsLJIrjiPe6Xs8nKBeL+DR98rq8sXCa7+Z7Arx6Uq5rPL+3pVNG7uPyhiWdlSehXh/R54fo7Gs6rp4yrr/dm4JcjuRWhdoNjYvHlzhflRfqSnp19xLzOz4iHDOlNTUystM3/+/Cr3WfL+xR6sszIRg9KmUaPyHxXsu6dImjZtGktKqsypXt70siJQXI0ff/mt9zVG1wMcH899snyNa0W//UQQBEEQBEEQBEH8u8GJ/+VHtz18NjdrHq9QFHRtdtvIdTELDyZxSVcljHAPoG2Ze3sWabVjtAbtGLssRvCcYAvxC9wTHRrxZY9Gty+Ef6La2L8AHFuH4XRvc0nWTEHmbUJYgwma4MYn2U0A28ZIN61WK4iiKLdr187sKdkgXXPx4kW+sLCQgzSTL1GCYgbmUFQKhYLLy8vjOnXqZK7JUovYB2jDD9sAYSN7LglYr149PNk990SqjNOnT6uPHj0aAfUF+fv7O0Bg5ffq1UtfWX6QcLyrLUtV/Ya++rlfwmF154f7Snh2VXR0tARt415SMsgioXnz5hhIJtf3IRZx3NLS0njX3JRTvFXUbmJiIg9zUO45G9nrPeK3bdsWYLfbZWwPhFqNxp/43yFm3JKv3a95gck8A6HLszu1ZkfLGlTD/BX8NpglPO55T6lgpZnf3j11wOvrm+3J0J7AQL/q1NUgzO/RQ58O/9ZX2oQPtwZtTy/pZHY4hlvs0sNWh1RtKRXqr7SnfzVK7f6sD3p1bZ19WYZTdlEOZDUEzDJu/redF/idGgWXruGYGb506kJ/OoAoG2Fz1DzKUClwtrgGUS0XvdMn/XpERLmjhTI87sW6zlVJEU8OuOoK9bjnXp4PwyKe86g7zpU/w3UvzXXPc3m+Ua5zRcvyXU9iXeeMauZ3RwTFsrIoMjfJ7PJygpiexi4veehevtAbz/HKYFVTnTy3As/nmM+qTygjCIIgCIIgCIIgCIK4OaiyiwtG2DlZVTc4aNsdMa2O9LhKCYW4JFMqTKJvzijN+OhMzsUnSrQld+v0pm4mk7V7YXHJpNQjuz+PqhW1tnVUbN7/8sR6WfTRhb/EItVyjcL4vN1S1BNu3xQR5RpXcyXplmrUgZ+DKvNV0QcTuw40a9YMo4Qu1jB/tYG+miu4b4eTndUA17hV62coKSlJqugXoV313PJlLYlbz8UFdz/mfa/NMys/q6mI8lMpfj379ahPfaWlFxgiqyuhnHVxsraitO9edkriNDz6Tl42PcvKjdeZ7YkWhzM6skacyTc/ejUSyl8pHI/yZ483L3DsWLTonitkcJOnljV1WKXpWoujRstXQV9U+wtKEuBl4vUQUW5xkuYjLZZVH19501iZtME0XMINQz/iXGnJHvkwvGEaK788X5xH2s2iJlLEO+80VjaWGaws0mdzBWUwdKMD8417acR/Mtj/2TXIn8EIgiAIgiAIgiAIgiBuAgcKzjWQmNRSJXN6tSikuCberxnXJHpGtpz91vF9ws9BGvvdBqv5Aa3ZcrvBZPnYYDSM0ZWW/Ljr+PH1XVu2LP67CKmypeHy/JlB728xlgRxok1ps8iySqWU1WqljL9jz5iaWWWTpA6IMLKAWJyMLSdrXMvfwYRuGm++qI0KCPAzyLrcIAfn1xfu//hviQgjCOKfQ1SgX3ChwVDt/GdLrbMbTFja+rbawSvWvtt3f0Xf4X/MGYVLSn7Q/tnV6/L0ll8sdrEFqzYyZxKX/ofVEIHnsmNCVcP3zB5+rqK9ds5+PurM0KmpTx4qLL3NYHPUoE+MGS3SYHYdRBSKnzjXa08d7Y6EimVl8qQ6ciTWq6ybZFYWCZTgasMtvpZ55Mlgl6Oi3NFDHVz3axKVdbW42+hQzfyx7LKIcr+/7udKYL4lFOK9XxSSwS7vpYXrp1W2HB7Snv09cY8hPgfKxH+6UCMIgiAIgiAIgiAI4n+M9NPnWokWsXaoJvBktCr0FLvO1OXqYkTMIRAwx49mpa8+V5j9psVo6G4wGQaDjOoTGhr4+9EMcfbp06eP1zSK5XqCS7DB1E1AUdahFjxn6qji5N683dJatpsjmd2msNs5STTzEicIjON51FXFZrv+kGwu+tM/OHonUwVeYMwKEi/agXsYMaYNdpTUaaWQi56QSwqG2ixawWhTdFaGXawty4lZ3DVEnREEQVxvTHZrjQS5Q5Lr6qyOaXsuFL9ZO2HJ8caPLdsSoFSsvbt1w01JT7e5wmgdnDt0f9xzqcOPFxcvtTqkNtVpY1jixkbbzoitWA0J81MtRAlVVb7V0+Nzb3tq+Scgoj5jNcAqSl0G/Te1abXDx3wQy8r2cEKSWfnIFJQKbpEwmVVNgqs+LOMtYdzCKY75XpbPTZrrjELnZi7Lh7ijrlBExVUjf6LrnMYuS6RY173NrOa4Jc6oauStUfjcTQTHIc31ehz7HwP3JcI9ktwH7kmE2xB5HmlpaeXyJCYmVlkv7t/kWaaq/aEQz/x44P5Onv3Aa09wrybvMrhur2cZ7zzeey5drzG6Hgf2/Vr7ShAEQRAEQRAEQfz7wOgfs8N2p9ViDZZFcXvdwLCz7AaBkVat6zXa07Re/ccaRNZ+JDQgeJVKECSDznB/Zm7OLxdtRZ8cyTnXFfoksJsAPrsspypMhSfrlpQc7ahL/+vNgqN7f+T0F3+VS/Omm/LP32vV5bd1WPTRst0SIdnMUaLFHC2ZTLXtRkOMXV/S1qHN+Y9cmj7DmLX3R2vWnl+kogsfMl1mX2bJbCAWZvWWSs/PtmgvjhEZ0zigOSUnBQnW0o6MTbuW+UuCIIjrDi8JxVezwbwoMR7EUutik+2JC1pTyue7ThbVS1iysd74pc8MmLq+WVmUaRlps+LP1I8KvC9YJRzzF/hTvg4Fky8tX5pZbIljV4HMpBXVzdsgQlVjdyHBM53M0/a+2oioOFa2j08sKxNCvhbnxHsoqjCaaQGreAm1WHZZzOCSbN6RMGmusnHssmhJ9lGP5/J8nvduBtjnZFYm1HBcOrKKI3o6uPIx5vs5Kosgi2W+RdcC1333WFcUBZbAqifKbhX4mYljZe8jCsiMSvJWN9KOIAiCIAiCIAiCIAjiesBxSkV3jVotaZTKs40bN67+ukxX1Zhzub4cOJbB5OTarUf33K036B/UmfUDDBZjc7PF1F1flLfgbPHZ3xuHNb5wI5brK1syj6mYNateTramP7Pl/J/dYW4jOGxRSuYQZJ4TeZ4vVqqD8gR1wEm7zXzCbneYlAIvyhKn9PMPbK5kfIDosNaW7Pq6ktUUKsqGdlZ9aTt/P4NN4LS9ZM5y2uGw3W632xqqAoMOicqgFKUovaCQWaSlNL+jKtR/HfTBwQiCIP4mhKjlbIFnOofEgtk1YBcllV1k/eBlv78uahkIqbONH01ZEeHvv/Khpo6tkyYNOgJprSurg/u67Kw1O2ocDcXDnxsBgrra+8l1b6w+uzfDKDskqWYejue61ERExbIyEeS5HF8GHPHMtzCY7cqPeTHkACXJMq88mOYptOYw3ySzMjnh3jtomY88Gezy8nzu65uxLJ+b59jlqK39zPe44NjNd73GZ3GLMnc0EJZfCsdd7ErJEudR1ptkVhZF5C5fUduzXPdj2dVR6tGXGyH50lz14rPgZ8bXc6CAws/SZHZZvBEEQRAEQRAEQRAEQdxQillxYFZR/m084411m9XDrRZu2nJxIJmsIIV+zSjNWJOdW3ivtrj4XqtO161Uof/AqC1+XB9eOmvvke2bbm99x9nrJaSgPX9mv9hCV5AzwqItGWIz6luLohioUCgkZUBgKWQ4yqk1e1X+oRuUSi7DalUVhKuKjCxP5WCdOkEf9nKsuJEfEwxCSVFBkF9A7WYKyXiHUZ/fShIt9RxmqTmz57cVmKkd1MvUweEmITA62S+q7nJLhr2PpCuIF0VDS1YiqZnXvlIEQRC3krSZIwsbPJKyW2ex92fXEaNdbALHlGKzdsq7Wt7UYMKSjX4KZUqfTnV++2piZ1NlZe0OVo/VEI5jthA1p6tu/qTx8RaQZRcMNqkBqwEWu6OhLxGVzHxH6niCQgJFSlV7+aBQQTESx8qWyUMxlOZK81zG7gDzLV/ceIZ8pbGKI2XSPOq8WcvyucG+ozhBgRILR7qrP24ZFscu7yGVzMrElSfPucpivv2ucnigeBntqjOZVRwVNb6Stt1jjdcYdbSUXR0oAN37dSGlrnrj2fWLTsL6Q1jZM/t6Djzc+2uFMoIgCIIgCIIgCIIgiJtAUVFRXYtoD1HLfHqr6CZnbkQEUmW42isFQfT1qaxTK7WlBQ/rdKXPWsym5rm5uXM0Cr/9h47unwmv19SuXdvIrhJcGkqvzw4vzD74sL4ob4zgMHWSrUaVQlAypSYw288/5KCsVs/3V0Xu0dSOzYYijkrGwu46l0C9F+D8Z0hhocbOlbRyFGRMdhgt9zBJUKoEBZONNo1DpW2mDKrL7BK3i5fkXnA3hIVplIwgCOJvRqCSf19vZf3lG/QngdUh+VsdbKTOKo5cseP89BZPLPvo+Y51Z02c2NnuK7+Sl1vW1NgLPG++rXakaUsNyvC887u8RiKKF7gmNYmIymCXRRJGoVRHPLjlTAIrW37PLRI801FoJVVRTxq7HMmTXEk+9/J87tc3mwxWtiwfRusksDJJE+eRnsbK+u+rbwdcZeezy5FV7mUGcZxQ0KD4S62kbRzrRB9tY/lprvId2NWT5qpnGisvozqwy4LxWsH67mKXPzNxrPwYuj8zlS1BeMuZPXs2Ky29/COCeyhVhff+TpmZmdUqg/tEXQtYh+e+UN59xecYPXp0uXuY3zPfgQMHnHsvudFqtaym4B5Z3vtTVbV/U3JyMluw4PKPU2hoKFu6dGmV7Xj2tWPHjmzWrFmMIAiCIAiCIAiCICoC5czq3dt6MkHJBwcEZln8/UvYLcK1ZF829OmDnJycnwu1F/+vsKDwcYvJcHuOSf9LUUF+xv79O2dFRoYtq1eveS7kF6uqE5/vzJkzqqZNQ5Tnjuzuw4mmZxxW7QDRYRNUSt6u8As6ydRhP4XFtvrOzy8iD+qs8VJ5Llllt+Sdb8DrLz4gGgsHK9Qyk7mww5LI/AWHOYYrzH3cbLZHyYHBOyWmMPG80FB3PD8MyhUygiCIvxHT+o7YPHn10mVmuziK3WCgjQg4Ppy24/zYNs+uvvfI3KFX7FHoEOVarIZwsmxj5ov2mpRRKQQrY1X+sVK+HcbV8xRR8ezGkew6UFg0ZGWRLBjCXBOR0KgaeTIYPlfVVPdZk9iVkiyZVS7DSj3K9WGXo3bwWasyCxmuvsWysnHCs/c4xVdRHiOjMLqqPbu85OFBdlkcprHqjVFF4HMtcNWPbGblpWR1667qPUhm1/6ZuWV06FBz37d58+aaFnFKleoIq8pA+eMpZrxBEeXdNxRAniIK+3E1/fcEhZpnHVh/Zf1yt+sJiqiqymDfPduBvwgzgiAIgiAIgiAIgqgKnUFbG3eaD/ALSK/n3H+9bFP5mx0Z5cbVbib049NDtj3rHQHW/sVa7USbw9awoCh3ut5cOKZEX7jmbNbxlMZ1W2ZBXrOvvuJzFJ85ExQkmPqcO5gz1G40jJIdhmiOlyWlJui4JiBkeWBQyJLgeq0P4hKB7CqBdgRrwbnGvO7C07bi3HFMtCtZSMRfflGNX7XA3INsNLwm6/P7yNq8uxQOaywvirIoO/wU/ooQ7OOtGmeCIAhfjB3Lia0eWThB4BX7DFaxIbsJgIzqVKAzHbzjudXDdswaWm4yVuKYP6shHM9JLVtH1ui7tchgL2A1xOYQA2oSEXU9cC8392/hamfmM1zH1ZYvdZW9NjNQMRms4uURrzf/ts8MQRAEQRAEQRAEQRB/MzBaqNRgjOEkJisF5dGLTB9Ukl1Yt6gwP/rgmWMX2zW57RyrQPTcaKBNG5xwQ/sjR47sWWKxOcbYrMaHTZaiXjm5+j4BpUWPlxbkrwsJq/VTfn7+oaioKJMrqsopoQw5p1sWai8+Yzfp7xUd1ggl3PbT+JX4BYWsDg6Pnudft8VWdo1AO2pbxp7BlpLCSZLd1F1ivE4ZEPG7pl6Tn1lQy72aSMax3JOvORj3lqkocwDnKO0G86OMU6msCibiElC4jUXNfgWfIHwAn0UeTyQ2ievBsW/HFvd4cV3Xs/mGnVZRqk4gzTVjdcgBpwqMawe/+cfwtW/13XQpQeZqvIwpB6U6RtWp0c9CZKAqssBQs99JsEsyu9kiiiAIgiAIgiAIgiAIgiD+UYhNm6ocR/aESjaRFReUDPx9ycp7rKK1Nkxl+6sEQffXmePnIgLDvklNT18eFxtrvVWT3G3adD4PE+2zTp48uURt5cfptdp4m13sZLMXP2HQF99VqgnamZen+fHcub+O+gvB9swTf91lLi65z2Y1tbfbrbJSpSn2Cw7ZHBYV9mVIaOO9LCjIxK4SZ8SYXh/BrHkNDIdTJ/Am7d2S3RrFBQQeUodEvhfYuPlGxsL0mNVZoHaLvcxkmqmwWYNlg66rw2pUOOymYIVkawOpK9m/RES5Iu04tywkrjvOzxtG6PlIk2rys+uO1LsZEXso0Ogz8fdk+4xB+W2eX9fHbrJ9nae3DGI3AVFmmr3pxYu6Pbu63a65QzHiFaSSfHP+3JElNashfgpBJhFFEDcB3EMpJSXl0rXn/lFuJk+e7Fxazg0uH+e99Jw3U6ZM8VmXm4MHD5ZrF0lMTCx3XdX+Vdgn7zKe/bxR4HN57xnljfdygNUpg2NCEARBEARBEARBEDXBXJohwMSfWrLbuYLC/L4yJwt2XnJO+wk8H1Uq2ZoY9KZYZnKo4R/aS2DS2HQLl+zDyep0WV74dl5e1wXnz6dPtNtNI0DqNDFoC0dbDaq+sjnkkEEslmSrubNoswRIDocUGB65S+EX8mt0ZK0Uv5jGeVCH7WqfwSVTNNaC0w/Z9IV3iUZtN16EmXSN3wFVcMQMv8bd1rArI8hwQv9PvdH6uWC0NWOyLUqQmJqTxGBI49kNZPXq1cE7duzoaDKZNJ73eZ6XlUql2KBBg8K4uLhzLVu21Psoqy4qKoqFsgFVtRMZGVkkimLW2LFjL0k1HKv169dH/fnnn60OHz5cb+TIkVxMTEzpDz/8cOrBBx885f0eYF+Li4sbWiyWKud1BUHIGT9+fK6vtD179oT8/vvvnaxWq0qhUEjNmzc/+Nhjj+X5ygvzQjgu3aHvvMPhKPde4Bg1bNiwBMqfgzHSVvaZSU1N1YAkbQHn5mazWR0UFGQcMGDAqT59+pxt1KiRxTv/jz/+2Nb9nDB2Z0aPHn3F+Kenp2vgvWtit9udYsloNF546qmnKtzDLSsrS7Nt27ZYbB+e54r9GtasWVMyePDgHFbJ5x/fM+hbk+Tk5MD58+ezFStWaOFeRkX5Z8+e3S4/Pz/K854kSZxKpRJhDCzNmjXLgme74KvsTz/91BjGrOFbb70lzZkzx9CuXbuD8fHx5fZog/enO7wPTjmA7xE8/+7atWsbGXHTOPLxoAuJianDV6qUCVmlxnetolTj/Zpqil2SwwrMts/h5Ui8dkiyDk5Vfg95Ah9Ybn9BTo32LbGJNd/2R2ZyAYkogrgJoIhKSkqqNA9KJU8phEKlOiKqMnA/JG8RVZWo8QalU03LXA9QKlU1ZtejDEEQBEEQBEEQBEFUhb3UqOE5OVgCGyVw8H+ZcwSo/LNlSSwQBGVtk8EYU8o5mpgs5z8tXL20f1RQ8IcwMX3iVkYwcJxTdoCQyn4rM7Nwnija7yjKKXjVpNe1LrEV9OYkWRYkO8eDTQsJDsoPCgr+xj8iLNXPrsL9P8pNwrv3w2Jle4PLPtJQTsA8Y6mf/tT5ttZjhzo6SgqH86LtDuaAsQsJ3sMFhM/ThAXuUUXfdgLyir4m7XGZQfnChSVFpUXjBaaIE2C4JZM5lrmjpm4Qu3btajxv3rwvdTpdjEdf3M8nwyS/IzAw8MKgQYM+adq06fLPPvusyJ1v3759tb/77rvPL1682N6jrAwSyCkbPNsBoTUfBAb+tq8z0uzbb78N6tev38t79+69x2azRcMtDZTB8ZUWLFhgAoGxfNy4cV/A673uOr788ssO0ObnIL9qQ9dQBJV7FryHBwg0B8iIaVjE+3nxPQPh9TDIrzdARDkFBvRjNpwSfY3Phg0bos+ePbsAxifY/VnwbBf67IiIiMgAoQJeZv5PCQkJ5YQUiCfFb7/91vbRRx/9ODs7+zaoIwjSeRgj+9KlS01169Y9OHz48AUg+pZNnz7dKXEhn3/r1q1XgYjCfW/ke++99//g/Kd3344ePRrz9NNP/wZiKdrf398Ec2s4WbaUVQCIphZvvPHG13q9HpdRk1z9513PhH2216pVKxPe5yV333334iVLlpzzruOLL75oBHX8AtKrEZSRQKIdhfflPkjyKf2+//77V48dOzbY+z4+Jx5Qh6l79+6LO3To8DXUc8QzzzfffDNx586dj+PrFi1a7AJJhu1cEm0wbvfPAkDEqWA8Rej3bpgbG8WIm05SklMQfnP/+1sW/5VeNNpkkyeZHGIH+QYGKhWb7SPueG5t1x2zBu9WKYQSh81RpyblHZKkSkuXauSIRFkOZjVGziIRRRAEQRAEQRAEQRAEQRCVYYRJageYibL5RCnAz39pk3qxn7Vt0fjsqYs5t50/nf5ckb50gMFhDTZdzH7QHmZrvnLbttnbL1xY3qN+fTO7pcQ4QkJ4+ezJU3Ucdiba7DLYJAkmvzmrUtBYBSb7GfTWaJ5pk4wlxnsLOcVhde7FM7as9AMOv+Asv3A7TnrjBCvnOhyuiVXeeRRlxtoM5o663LwOks3U2J9xXe0We6jACUGSIGSpw2v/yYcFf6ow8Hu52q1sVXa3Xj2LMuf0EtGg68Fkya/Gv3p/FRgMBqXD4QgE6eGcYHVLKDyDpHC+NplMEX/88cfncG4Gz/+6WzIqFAoZygZD2Qi8RkGDZbCsux4XMpS9tKQVCIZwEBpvgVR60rVvUVkmGFsQCjLUEQBpj2RkZHR5/fXX//POO+8cx3RoRw3SKhTbc7eBZdxnBNsXRdEB7fn5el4QYGFHjhzpBzImEsUSltu9e/eI3NzcjyqKpIH2gkD2hGI7bgnlbhfbA3EUkZ+f3w7ajIqOjn4fki9tIgOeZNDmzZvngshCcXNJlsGBkVZBZ86cGZiTk3MH1NMA6vvA9QzoAIOg3VDXOPvc/wbq46BfkZAvEvIYQKxpWCXAeyXA2ARDvgh3O5zXG3X+/Pk6Fy5c6AKCbMi2bdv+07Nnz3zP9B9++KEb1NMcPy8oHE+fPt2tV69eKLZ8iihoLwDyhrivPT9frnEM27NnzyQYhztAOt4D8vG8R1kVjju+hve9XLTLSy+9FAN9eQWEWC3Ix4KDg0/16NEjEeq1M+KW8fMrvfE7cz4ePaaublJqkPoZrLb/GO1yb1GSrruPuaA1PQqn3QJjZ+HcqiZl4bMSlJeVh59NfXXL2BxSGKsxfB6JKIIgCIIgCIIgCIIgCIKoBAtMdoMZ4BwWG1MGBuR269b5g94NbzsASXKziHpZMJG8OXnt8lfySoufNlvMUTna4u7Feu0PtXUFG9bv2/3RgI5dtrEKooBuFNAnZcnFi3X27Ng6AuTARINB3wabB0GkDQmNWBkZGfZLcGBYXl52dm+HxdDbIbH2dpP2DoHn+siCgaUXFhhhcltSa9RapVppUSsVxZzAWyRZVIKGUEmSqGZ2e7Bst4dBtUFgMxQgjgy8SqNT+PkdtQmKA4GxTb5lxbpDrGFre3Wf3bnnTvqJbGOprkS2WzSSxN+sqDJn//z8/PRhYWGpIBpKQDLgvjxqu93eubCwsBHcw2XdXnnhhRc2wfimooxSKpWyq9/OSrp167awbdu2q/E1lCsXrhQeHn5ao9E4l1X75Zdf7jpw4MATGBkE90q6dOny6eTJkxdC+/aFCxf2WLFixVQQN7cVFRW1++2339794IMPxv/3v//VOjvqEjkqlco4bNiwTwMCAs5iNIwrzdkRXPYtJiZmp6+VY37++eemIKG6ekS64ZJ2jd97773u8HKTd36QNuWesUGDBstBjjijckAEKeBz0q6kpOQ2OCuPHz/+PEg23BfBGZUE/W794YcfLtBqtREYPQSiK/W+++6bGxcXd3bv3r0N582bNxnGti98RoNA9L3yyCOP/AWibFO9evU4d6QSApKJ+QLG+NIzuKRatdwljp9arTbBuH/duHHjQ3gP3l/F/v37e549e3YUiiMQUvEghabD+/HE2LFjLwlleM67MDoMxwMFEPTT79ChQ/dCnTsr+py7RSFIur8g/xHXPQHep2YFBQUd4Dn8YAw7wVi9mpiY+Dy8b86oOfh5ld1yE4E+O+tfvny5P4io90Hg4R5q+Lk1jBo16vXPP//8L0bccOISUzVZufrdoEt9LsGnEvgD944NHJ4UH49yCI+vxny8PfzkueJeWrN9jNUujbaIUiC7PozA/8BHL53VEIdDUpolNT5DVnXyL5Rl4dlxS+qyGhKk5o6QiCKImwAub1fVXkwZGRlX3PMs42tfJu8ymMczn692fbVTWR1Xg686quprdahqDKsDLt9X2b5aBEEQBEEQBEEQBOGNc20wB5NxSxmHxW5pENUwx3PZPVxSLjc3d0ba8YN78woLXy3W6bsY7Dbl+by8wcU6bcuCksIv2jRs/j1MRBfcSBnlmoTnju7YEXp4795+xcXFT5lNpi4O0aHxDwwsBVF0IiIkbE5UgwabQFI4l5eLrN/4QO6ZMz+WGgqaqcTAWD8l19GhNbUTHda6CkERKkhypGQyK03M0QRXEisLg4JGeFyiT4AR4QotonxBFeB3Th0QvE0ICD7K/DXnA2Nicc8bExdzFc8rcjZOFkQJxpyJCoysuWlLHMKEvu6hhx76EI49eA1SSgHiqdPOnTunZ2ZmOuUNSIC7unfvnobpniIEASm056uvvlpQUf0zZ850nkHkxIHEwH2N5DZt2myENj4YOXKkUz5AG6cfffRRQ3Jy8m8Y8QPzGN2gTZxE0aL4cn+GIM3evn37NSAuNrMaAFKnOy7t54q8wrp4eA7/devWxUHbaVC/WFl5eL7X+/fvj0sssh07digWLFhQD8TZfPgZ6AlCKwjOuGfNUtw/69VXXx0HggUlFI7lySFDhrw8Y8aMvXBg8SOTJk3K/OGHH36DPK1gPPz//PPPASh28/LyqiWV3CLwaoBxcMCzboJxXuG+99lnn/0Mz5N+8ODBl0DA+cHPUPx3332HUXCHMR2Ek3+fPn364mtcyg/3mULBdPr06V4g4HCCvsIJfZRRIL7WwVi9BRKOderUiU2fPj1iyZIlE3ft2jUNI+NAEPYFGYbvtclHFZeeFYTTqPT0dOfeQCCzdCDTvpswYcJSGEtG3HhO5uh5s8kaDe+ITxEFH9xBP/3GXoOXl0zwoud7FMNpOR579sjKR75b0U1vl4eabY4BVlHuLF3lEn4mm1R75Idbgwry9Tt1uYZJNSmLLRptDD/P+6qT/8OJK+paRanGgaog29NIRBHETWD06NHOozJQssBfaC5dw18icMPFSsvExcWVK4MbJCYkJFTarle08RVgu9e6J1SHDh1w/d9K2/Xua3XAMvjM1wK2CX+hYARBEARBEARBEARRXVzLhDln32TJ92QhLmkGeVYdzcjYs/3w/hdyiwsnmO22ML3R3Pic6cK7phJDf/g3/EeQ50/4N7KD3QDOnTsXXJyX93+lpcXjjQZTF+ivGtqyBvj77/X3U8+vG9tkef369XO99q7CvhRAvwrhvJuxQpiUjwRTUhxqztPVNRm0dSw2m9Jk1AdIzKFRcEzksTxMwis0fsaQsND02pHh57igOgXsOuHgGIooiZMUKKNwOb+bEUnmnrjApfbsrVu3dr9H9okTJ+4AUbACxENnGCfBYDA0BqmC0QxabxHi2meoSkBEBbmXtlOr1Vq3hHJ2BMYX5oQ2gOSZh1FGIMcszZs3t27bto0bPnx4uXq896Gqij179ijvueeeu1Hy4BJuIMG2Hz58uA9GA0FdfUGAzYJsxT6KXnouEDh2j+Xf8Hx62LBhS1etWtUTI5eys7NR3PCzZs2KLCwsvNO9lF+DBg0Wf/311/tB2FyqdM6cOUfXrl271yWieJAqTUCmqAcOHOgcCnaD8ZZdTz/9tAHGeT7IJtyXyU+n09UxmUxN4XmdUVNPPfXUEBCDTrEWHBycAzJPgmesZ7FYGv/++++4T9gVIsr9mXDtByV6Lp0H7efBXNd33bp1m4bXUFddeB9wiciL7v557zG0ePHiOk888cSHIMqcv+ENEmrF+++//258fPwN+V4hag6+Y1qj9b9tnlpReuTzEXO80zt3dn4GtuIB7+9rXSaval1odPS0OsR7QUrdiVv4VbMphgLrrwPF6v90iUw5XWAyOUTJn9UAaPPB1FR5dnx81X8u6Rl7kNUQtcAZ+zYO20siiiAIgiAIgiAIgiAIgiAqIUSpdPCMs6KEwvl7s06n9pXPFamSCxOLr67atW316dPpU4wO250WkyH0gjlvYH5JcccCnXbB0pXrfhs9bOC+a42Ock2iC7t3724ME+F3HD1ydKokinXtVmsITHhbNSrVMbVG/YmS45Z37x2XW1l7rjSciNQ76/ULN/jFhmf5XU5jviJUbkSEl8NoBBfFC5KdkzmJwz2LbtqShgBvs9kET1k3b968ABBO0awsGAwxgYgqtw+PWxbY7Xala5wwr2e/Zc+xqlWr1iGQNiNw+blDhw6NGjRo0G6QTWs++eQTjLYTY2NjtTNmzJjizj9kyBAUcldECWHElGuPKfd9PEve7bnZsGFDm/z8/LYowIKCggp79er1HoijlkVFRdHnz5/vDJKlJWTbzioB+i25RJb7cyGATKnlvg4MDNRhP9avXx8B4xHjHpu77757l5cEdX5+fvnllzc3bdr0NS5TGBkZWfDQQw+Z8vLy/D3zgnTxub+YK0Ks2hFz7ggm9+ELEE9Yp/O9xuUEATs+7969e/0efPDBYe59sVCsRUdHyxs3bpwEcjIMjiFQZJV3fSgLcS8p195hV+zftHnz5hjMhm2ClDSD4Lr0rBK7QjSGv/jii+8VFBTUxzpjYmL+Amn3KojMQkb8rbBLsiZXZ51Rf8LSiHvaRL8/6/kePvcLdP3cHHEd89o/t7Z1kdb0q8EqtqlmU/A5YAzrr/9Iyp96URrMaoDZLrae8vuK++BlpeF0HSauaJZjtj7Pagh8TrfOmdKd9ogiCIIgCIIgCIIgCIIgiMqwajSi6BCtDCeuZVldrNdXuta8a7I5dcuhzAPnLxx5KDsv72WDxVTHZLPXysrNecEYEDzy1+UrZ4IA+Klu3bomdhXg5P+FCxduO3ny5L1Go/EuvV7fjOc4Fc/xEoiArEC/gM/qRNdNadm+5UlWQyrZ5+amCCGryaZWikxpszkcak6BESY3bWk+FEMwfuFnzpyphZIHhIjf1KlTH8zJyfkPSgzMA8Lor06dOjknlb2X5oNyoxs3blwb9//xFCSjRo3CPZMuLR/Tpk2bn0Fs/J9Wq20F713U1q1bPzl16tRfAC4V9ztkOTF06FCrV/fkYcOGOfcMcu1PpP7tt9+e+OGHH0Y6HI5L+ymBzBD79ev3Nbw8Xq4wCKuuXbv2hT4HuiTM+cGDB++DfmwrKSm5G2SPCj5LAyFth/d77V7pBstBf8NhXKLgWZlOp1PAsw07cODA/ZgNZQt8prcwl4TD8XQLH+iXz4iL++67LwPyZLrbfP/997EdmXmIPHhPmi9btsyA9gtEIe/qk3TkyJEG8FLpupZr+hn1zo9jNGDAgFHwMgCvAwICSuEZnBJ3woQJ9UHUdcexwAPk22aQVlZ4P57Gn0cQeUNOnz6tbtasmff75t7jCR8r5Ny5c9EYZYmfr5dffrnd4sWLX+ExVEoUGYi4ky6R5wQjrvCM7zkIxMbw2fgAzii8cLmz0p49eybNmTPnAghMRpTRa+rawVZH+dUlS0yOJqyGqJV8iy7PrSondZSywrZ99qA/qluHQ5YVeqvjjR/35zzQ9IkV7w5s22jh50+3MVRW5uCswUebPp6yvLoiSsnz8vA+Maa9MxmrHayZb7DYB9fkh0CEPl7Q2j5r9OiSFk3qBn21MWnAec/0l77dGrRid/FDFy22KTZRjmA1JCpQ8xWG95GIIgiCIAiCIAiCIAiCIIhKsCkUVrvVapBFicEUtKYgOy+yOuV6t2tYAqdPth0+vOrg0aPPFut195ktlqgCbUkLnU7/eVFJ6cu/r1g/q07dyJU9b789s6r6cJI8IyOj1vHjJwcuW77y/yxmY1+LxYJLxMkKhcIWGBS0P9gv4KcOXTp9GxYW9o/dINlhsQco7KLSJkt23mHPuFkCDAExVHvGjBkr4HALFIz+4VE84BJrderUOfDVV1997s7vWprvUv9ADnaFvHiUi7g5e/YszsVeElEzZ848AQJp1EsvvTSnqKioHwgNDZTtDe9v7z179rzx9ttvH+3fv//Mxx9/fMmYMWMwKqycNMH6QT75nThxYqx7iT93e9jPqKioHcxLRD3//POhIJGGQT4V5m/duvWfGEkDUiwFhMdwkCOqgwcPDoV+4fPlVzRGI0aM2AGfN9kdVeQWdFhnbGzsNn9//4U4Jq5lA6tcXs8V0SV7Rll58+mnn37z2WefOYUMChv383qPc3XBMiDkVCCD+3Ts2BHFHAd1q2+//fZuIATvh7HFnytWv379NSAiT48ePZoDudcF3qsmKJXgc5CdmJi4ceLEiaqYmJjT8N61hLoaL1iwoB8UW+2rPYBftWrVi+vWrXve1XcZ5N+l+XmQXnlNmjT5aN68eUXwGXPegz5eEnm4bB+0PwbHAN/jWrVqHX/mmWf+vJk/H/8EzuQZ1ljEax+Si1rLM3B6xvOeRsGfg1ONpZZdkhoX6i3fLtp58r0GE5ZsCdAo1sqydPzOJrWK/zyUW1C7tsbPZuPqX9TbmttFsXup2ZFQ3brh43AsaWRn5y807P540O/1J6QcM9gcrVgNgC+5oBKz+Nr+c9qX6yQsPsxkHuSrZJc5Vid5c97tNlGq9lKBnqgV/Ok7mzVddZCRiCKIGwLuy3TgwIEK03E/qLS0tHL3vK+Tk5Od+dzEx8c790iqrAzu7eS5vxP2Y/bs2exagL8AXbEvE7br2bcpU6aU2+/JOx3x3u8qNLT8L49hX6va/wnbwP54totHZWCdnmW8x4ggCIIgCIIgCIIgqqJTTIwFDEI+J8Gku0NSlei0YTUp37Nt27Op+/dPy7p48WBefn6i2Wypb7FYFUXFJU2sJts7pdrSIetSU7+MiItb19nH0l0ITEAH799/uOfps2cmWq2WbiajIVqtUnICL4hqjToD/p29CCayF/fs2fMoTEyb2T8Yu80RwlstKp5XWEUHbktyk9uHyX8PwcHjEmgoPxo2bLh7wIABr7do0cLgNfl/SbbgUm6QX3btC3QpKoiVLXtYjoceeugMyIzH/vjjj7EgMp7IyspqhlEyIEEEEFftCgoKZpWWlnZp167dq9imsyEvGQVtiXIZvDvNtYfTFUvZ6XS68Nzc3HYukSM1bdr0zy1btrBBgwYdg7YLIL2u0WhstGjRottYJSIKRQxGgrmispz3QMhJIGROtWzZ8tX777/fKQ9xnyeXwHOPTUWRdtWKeHNJr0uv3Wes3xVxVG2wX/AMapBHT8N4Od8bHHcQu5qyZA7nrvLvvPPOT++66y6n1O3evXt/yKPE9xckXhrIXhNIOcfhw4dxErAl9mXlypU94bzG+/PhjihzSTsB++sp0MLDwwtg7KZ/+eWX6zzLuqPfPPO6BCB38eLF21599dUR8PoXVyMkpP7mgJCKtlvZPTqreA9eL9yf7fzyyM02sqslyE+5I8/1Gn+Wer247r/HcvVLa7LPlBtRkhVmSe54vYJQ64T6TZ87qSxCkEQUQdwA4C8JLDOz4l9kcv/h44m3uEE86/CUKdUto9Vq2fWgsmdBUCp5iiXsl3cZX32trI7q9AXHuSpw3GraF4IgCIIgCIIgCILwQg4MCCjO1+mZ1WJR5eTnVCsiypP4jh3xH7Hzj+TnLzq8c+eEgsLiZwwmS0O9zRKqKzQPyy3OHxh5Pmvvb8uWfRfbosXGAIcj2+gQYs+eOdFByQtDU1as7m+1mHGfIoUkOexBgYEX/TSaP2vXrr2+d+/ei+G+4X9lItphsUaLWoNSGRyks6vkmyqiVCoV7v+0F8RKCUiJViCDmqI0iI6OzmrTps3Yr7/++jwcFZbv37//e3Pnzp2DS6+575nNZjXUWZySknJFxE9SUtJFEAlz4OUX06dP7w554s6cOTMKpFBbFEf79u17asyYMdwdd9zxEuQxoYDA/uDh5+dX+sYbbzwE6buwrqCgIM5kMjkPtVpd0qxZs0vtYDkQKsNhrgiX1pKbNG5yKioqKv+HH35oCs9q+uWXX05AGoqoiLy8vIGQZ3NFz1i/fv0/QchooZ1Ger0eIy9wOcMLjzzyyH+gP4fc+UDY8O7+Irj3FqsmMO68535Y8Bn/FGTNaVx20L0MIYgkgWd85Jp1a56BukNYDXGJNMFVH+7jJIeEhOj8/f1zQOrufOqppz567rnnjqPkW7ZsWd2HH364L5aDz4glMjJy9bp16yJBHskg9LaeO3duNPRHA8J4wLvvvosRZdmebblFUt26dQ+CXDprtVqjS0pKOqMMw/tDhw599ccff/wG5qy8Jw1l9zxigwYNjo4cOfLj33///YmcnJwuUEfoyZMnP0hISDiYnJx8jBH/SK7lS5vjeLlWkOKDMx73ts4YtKLu+CXfGG3iRHYLCVAKJ0b1NCw4MKfsmkQUQRAEQRAEQRAEQRAEQVQCyoMl6zedPZud7bCJEu8Q5RjX8ma2mtbVOirK1HrEiC9T1qduM1hNgy7m5CVY7LZGZptVebGwqFuRTtcmv6j0qFqpuijaHc3MJmNTJskqAeaiNWqVGeYdT9eKivnD38//F5iYPgQT4Tc9YuhGgpP++pWpLawiTLEyzgCG4KZGd4GA0IJwSIIJ/90zZszounr16hW4BB6IkTogDUZC/z73FcHj8UvHuhYtWhRW1sbChQuFzZs3O38bF+QR1oWS0vbSSy9thvq3TJo06UdIf+bYsWOTUJJcuHDh3jp16nwKeU54VYVz2FoQIYVVSUgQKYG7du0a6O5uTm5ObRBqC7AcShKQGjGuyBsOBNig1NTUxPj4eAded+7c2XnfLVO++OKLFyIiIk6B/Ljjp59++t5gMNSCI2bJkiXDPUUUiCOrQqEwu8cGxEuAr+X3pk6d2gyEVl2M5ILxKHrvvfdOwniX63+rVq1S5s2bt8n7udavX99s3YZ1j7Eags8CUsvUunXrL6DN7XgPhKEdJFEpCMe8cePGZYH8s4CIckaZDB48uCeMkVNAw+dAsWrVqjfXrFmDchCXbgwGEabB6KXi4uIW8N61ZuVFlPt5ZRjLVSCq3l+xYkUkCMuvQCgNwAQY77EwrsuhLe9ItEsiD2RffkxMzFKQnbm//vrrYvhsaPLz8+vv3r379S+//HIyqySKjfjfJETNL9s+fehZ7/vZ8+96stGjy+4oMdvbsVuAShBKooKVI5PG3n3pz0gSUQRBEARBEARBEARBEARRBQ0aNj68Ze9eu0MWNRoF327Dtm04KX2R1RCc1IaJa/vogfH74fLorpNnd+zbu29G9sXc2yWZcRaTI9Bh1nVTKRVlURSixASY4A4KC95eOyo6uUOHrovr1QtGcSH/jy7FpZa15ttVdk4pilx6ZEBUDru5SCAcDL169dJ/+OGHu0+cOLHm5MmTd8F7Iezdu/fJd955B2XIpb2XcIk6PLslTXWWiAsLC6v7559/fgtlw0CGmLdv3/4UXB/GNJfkOgv33h40aNCjIGgCQQxFNGvWrD5IlxOeUUKY3bWMYJWfg8WLF7eyWCxt3UvlgThCEXZpaRq3LAIZxOB5bz916hROYO/zVZefn5++W7duBjg2HThwYMOePXvuh34oMzMzJ6elpc0DgVWI/ZwzZ45hy5YtRVB3YywH/b/9o48+WuzeH8k1bhxIptfPnDnzMPTL0bx584UggB5r3Lixd7O8r764x7+m4PMqlUp7aGhoKvRrjeues0/btm1jIL0u5Z0/f74G5NhAlE14De+xAt6XFu563OB7bzQag0EQDcbHvdTxy0sSolSygvwy4gGfrW++//57p4gqLCzsDXJqKLxM9uyn+/PkkoQ8vIfyDz/8sLp9+/Zfg6h8CpcTTE9PHwlC8Pwnn3zyJkhMKyP+FagUfF6L6IinMnymcvLDdVO7fXuhZL/BKrZkNxE/BW+oH+Efv/vjwac975OIIogbgK+l6TzBJei89ynCvY48l6bD155LyPlatg73f/Jcng7b9CwTEnJlVLL3PlMLFiwot+yfdzt47V0G96/yBPd36tChQ4V990VKSkq5fbSwPNZTGd7jevDgwSr3e4K/3JX7S8HmzZvLPS/W6bm/FUEQBEEQBEEQBEH4IjA8MFulUBRbrfa6RoPxtpzz53GZvEpFFE6yH2VMGVBa6n86Pd3/7Ilz0ZLdGvrdb0vaOBz2LqUlpc2MZnN9QaEMQf0gCApZyQmSwDFRFiUFTjwzXOEN/llrMdtbFJeUjN23bxu3exu3v3nrFuchvQiaEf+nhFShKdReYqinBs1mtDtOso4titgt4qWXXjIdP378ywsXLvQCOVWrpKTkNpAWEyBpakVlcK+kitLcEgmEluns2bONzGZzE7zdpUuXESBzTnTq1Mnhfi9BBgWDdHAu24b3cO8oLD9s2LBydeJychW15fm5ANETD+1F435XgYGBGW3btk1BIQX5JMjH47J5kGdAQUEB7nXEffbZZ/8H5wMoxqBfzrkVz72KXEJVrl+//mcwRoNAlkXC+EQ999xzU+BZkiCLY/LkyTnTp0/fD9m6YBmoe8gzzzyT8umnn/7FXFFCn3/+eT0Y3/YgVFCC4TOmjxgxwgp5/bwkj1zBeMuez4zjxCoB8ru6z2GdHIgjrqqfH3i/6sDz4bJ8uHyf1KRJk7VQpsD58wmeCSuA96pOVlZWb1EUFTBf1R8EXFjv3r1LfNXnbg8E0nIQkLthnqorSq6//vrraZinWzFu3LhLn3mUWL62+BgyZMhsGKNOubm5PaBt/927dz8FgnAT9GkD7RX1v49K4E0tagUMXffenRWK+qSkeEti4pH2ydlnZhis9qdFybfMvb794k7WCVcMBwl1xjuNRBRB3ABQdPja08kTTwmDoAzxlEAomLyFiTcooioTXr72iPKWLiiVPNvx3ncJ++RdxlsI4bWniPLuuy9QRKEE8+xXVSLKe1zxNdZTE7wlWlxcHIkogiAIgiAIgiAIokpaRkXpP/zy62NaozGmsEgbXTciqjFM+h7ENPjnqYoP0/pZ9Hp/k9YcVVyqrVNcUlT7iwW/1jWa9XWsDls9jhMiHQ4J5IM1yGKx+QlKQVByziWMmOyw2ZQcXxoVFnpSo/bbLFrtpxRqRe+S4oKhVos1wmG38nq7NcJqMfcvKdHG+anVRYa9+iMH9+49Wis68tTpoxnbA1XqrDrN6hSwfziWsxdacnbJX1QK1oCICPyNeju7dUiJiYlbtm3bdvj06dP94Jo7cuRIAoiWDzt37uy5/N4lU2AwGLqAbHkYhYVbPKHwwNdvv/32maFDh+4GsVPcrl27P0AeNME0EDlPQzvWSZMmrdqxY4dl1apVLUHgPIVRRiiLoqKiLoJ0OOXZjqteBQirftBerGekFIoIqIuHOncnJSU59w4CCTUIZJrTwtx2221LNm/e/KKnsEhNTVU8+uijidDOq3DJY4TOL7/8Eg6vC2F+SYJ+SCixMEIHn83dDrRx8OjRo0tA1DyGQubixYv3fvXVV/PhwOXC7PDMH8+YMWOsXq8PzcnJab948eLPQJi8De2dhHK1Zs6cOQkkTEuULVCvceDAgZvKHs0pni71zyOqqBw+IqJqEiFVZV4c10ceeaQbjEt9lHD+/v7677///uFu3boVeeThx48f33XlypVLioqK6oDcqv/77793haR1rnFi7kg0zzFv1KiRZfjw4R+ATPoe3p9AGOdWUPc9UB9uQiZ7RI25i1wSCR988MG5sWPHvrVixYol8L76g8gLhM/Cu2+88QaO+1lG3HLC/ZW/6q1iL7so1WPXEZBQRbc3DBmy9u3++6rKm5TUBpfGmxQ3deP6Y7naOTZJasxuAPj5DtMoPmgcEfDBxg8HaH3l8RRROIuMs+AZrqO6XG25vxsJcPSBYxkcNZvZ/t8h1nUgaYwgCIIgCIIgCIIgCIK4BMcp0niRj7fYHMEnzxd89vrMrz+AmWHJbrf5w2RwsCg6VJIoKpxhGc5wEwdDj8ILvHMSGqbWRcYpHQEhISUqleq8zWA4W7du7aNNGzXY3bh5k/2xUVF5HpPP83NzDRF7D+zun5OVHWez2/uAxIqVREmt1xmiTQZTtMAL/YwGAzt38pzdX6M2LE5eXOjvr8lUKRWnYQr/HC/LDuwFrgcmKASHJEsc9ISBFeEVHMeLMqTJYEKYIMI0vzO8A6bLHQpIx4gX3jkDLjCBgyzQdUiUJZnD2xKIMyzLwV2GrxmqCcgHioITZAzf4comzUFc8AoF1O5wXkN5TsAXvLNG5wvJbtZwvFLnHxyWrbuQG6+QZI1WtBc3aFxvm6/9mG4mKAsSEhJmFBcXt4WjVmlpaeTEiRNfhjF4BfrmcGWT3dFCW7duvXfLli33uqWNJ40bN/6qb9++hyCv/q677nodhFCdY8eODQdJE7N27doZ69atmyGK4qX8WCdIm6LmzZu/dvfdd19gl8WMU6DAZy7wxx9/fIMr2+jJM1oJpY6jQYMGL8G947gs37333nsnpimVShtIsFXeUTNxcXHyPffcs2H27NlPQb3h0Kd2KSkpHaD8pttvv10AEcNj1BKCHyd3ORBdprfeeutTECPDTSZTTElJSdODBw9OgaRnMR3EyMlnn332XujnFzB2jUG6dII2lnz88cf4DJf2nVKr1cYOHTp8BPdTQU5x0dHRDoVC4fAVDVQJVWaG8a1RhYsWLVJu3LjxHnhm+Bgr5FatWm30lFAuZBCMp9LS0g6jiAKxFrJhw4Zhq1evToP7VmjT+aOE44f1XCoEkmvZsmUbT5w4sers2bP3Qrr/qVOnnn3wwQdXwXhhtCUODucRiVYu+mvNmjVpmZmZn+zbt+953LPuwoULnRYuXDgDROlYEKW3UuASQLHB8fOjQ4IeXbXd+nKp2T7e7Lg2IQVfyo5QP+U3PZtHJv4wtWeN9gNLm95/JXxGVrV+duXEIoP9OatdbM6uAwr4+g7SKH+pG6B4c+vs4efOVZbX4/UsOOJYmUzqyMo2yasO7nLT4Ehi/1xQQiWwsuf/t4qopaxMLCLxjGQUQRAEQRAEQRAEQRDEZWR2gJcFo8MhhpTobdFMZ6mFOgVkD1OpFCKHy2jxgihKzAyz3Q6B40xKTjAHhwTlhoYEnw8I8D9itXPnOE55plmLZgV1GtQqPpYWZe7XixO9m3IJGFz+69esrKyUvXtPNrLbLe2sVtswbWlpK9Eh1QWlFGY2WRQKUD0mhxRmM9nC9KW6puAY+gqMF5UgwNTYOdBH0BfZPafPc6iUZFRMMDnIwSHIggwKCg0Vk52CCHKzMlNQFobBO6WV0xw4VRYYNSgNdZStAefMB5ecM24FbROWBlHFnMJDZq6NlDiBXZIlsgLrgvKiBOJL4B3ixRKdws6p1VDaERKYyUL9T7Kbg+Tv728AkaID2WABCcO7+4jnhg0b7oyIiEiB9PtwOTqQKQNGjx79PSQdBqEogkQxQfkiTxHkEcXihtNoNKbIyEjnxdKlS/MnTZr0NFzvO3ny5P9ptdq6ICk0KLCgvAji0larVq1jrVu3/nTlypU4Z+e0WpAugkwyYHvuPrqjodzSBq8xagn65bz922+/dYd+4meJ1a1b9yzcP3pF56BNkCcHk5OTD2Jkjt1uZ/C8uBwdRiihwDJD/wVsA0SLwnPpv5YtW2I/Vx0+fPhevJmenh43ffr0NlOnTj2C6SDR/sA0EHlvgnDpBmImEKOIXBFCxrCwsJO9e/f+Dtr4defOnc5nAvGlgrMVRFwx1iF6GjoX2AeQbDKMRTG8bwI8oxX6bWGVAHmkwMDAYni2ImjPBHU4KstfWFhYD/LUQyGIYwTjusF72UNkzJgxpe+9996feXl5nViZEOv40UcfhcE5FyUbHHrsMrzHoseY43tnhHH//ttvvx2C92CM6up0Olx/8RtXHh2Mez6+d9B3HUhC93uN7Vvfeeedz+H7oTsIwFYYNZafn99l7ty5IyFtMfuXEuqv0tqkG7M6oUbBa3Pd7WgUBhhzdUV5QdQ7Zjw8yAgv3xwzZmHS+Tr+d1402idKstzTZBXrVaeH+CPtr+SzBF74KTbMb96fMwaln2NXh+sz8yUe7Z9a3qvYIj5rc0jdbJLUUK7BcPkpBRNkXxvhr1wWGxy6YtUHvUvSq1HO19J8sXDMh+MuRvybiGOXJRSSyEhEXTdweTvPpesqyuMJLneHy8a5ad++/RVlsM5GjRqxivBV5mpIS0srd41terZb1X5QvupAPJ8P/lLnM48n2E5lvwmDSwJ6L3mIY+Q5ttVZNpEgCIIgCIIgCIIgfNGpbfujF7P/OKNgYicGE8qBAZptGo3iJK/gHEolX6pQKAtVCrU+Iji0qF79Bjm1QsIKaofxpTExMUVuYVDT/Vtc+c1wHHMdv54+fTq4tMDYMj39fFuT0dgyUOPXGupuZDYYYuw2u1rJgYeAgxMlXsKNQVCMYF18mRBy6QoQSbxTRCnBcQhO4SRfEk+gQ8pey+VklOue7KyzTEo5xVS5PGULt8nO9LKWL7fLuWY80WqBpkKDIqmgNdFi18gmSyAPWsDuz1s1oVGrWEyMmd0EQIKcgkn+JywWix9IDUurVq1OfPfdd5fSk5KSSj/77LN3YNxTMBoMnIi6efPmJSkpKdyZM2cKQaQ8A/LKD/PiUnu4TxQIEYygKdcOCIXcFi1aGN3Xn3zyyXk4Ja5evfrTP//8sy3MadR3OBx8QECAtVevXun333//QfjsWFz7MTnftv/85z/7R44c+QDkEzC6B/eI8ozycV9j+yCdcH5YnjJlyorHH388FdNBqFh69uxZMGfOnCvGYcCAAdrdu3ffD/MrQbg0XnBwsHP8ob08EDfj8dkwugfqzfD8HI8dO1acPXv2G5mZmUtAUvEoe2CC/tLyXPHx8Sh79sAz3APttkxNTW1jNBo16CAHDhx4EvpzFJ5X79kXEHSWt99+ezQKK4wkAtF14ptvvrmiz506dbrw1ltvPYDLFGK7QUFBZx944AFWEXfcccfJ119//XHopxrzQztn77qr4mlwSC967bXXnsHngrETQ0JCrphzd42FDALuM3gv12OfoR82lGg41wXjN71Hjx4oLqVmzZqdhjyeZfG9XQefuzF4DaIJy+Kyj87x/fDDDz87d+7cb7g0IhyWo0ePllv2DJ7lwtq1a+8HeRWGEVuu900HQrHG3zX/K5z4cmQou8HkfDXSBKcm1c2/aNFYFJCproP1fnVtnYIi6x1mUWoEb1K0ihfqWG0irxQ4ZpflfIHn8oKU/PmwAPWO+ADVhaSkeMd5dv04+PnIrXDCg/V8JiWm0M51MctSC05k0fBlUrvEIjq/z8P8FfB9wuXCT36un4K/UDtY2NdSWyfjq68621HIHa1Bm54zujgIcR7Xz8Exm1WNu9w09s+OiEL5lsD++c9xtbifHyPh3D+saBoyGFElstevuaBg2bx586Vr3INo/vz57O+Id18TExPZtGnTLl2jtPGWXfAHa6XyCf+Qhb9ksMrA8fDcmwn3bho/fnylZeAvKuXkVXXa9e4rtum5NxXWh/V6wtUw7psgCIIgCIIgCIL4dwD//Fe/+cHnX17ILRinVCgc4WHBHz4wctTHqjr+jhaRkbgUlh2jJthNAuVEXl6ef15GXlh+bn5YQX5JeGBgQHSQv6YBiKW6TLSHyg5bMGRT4LQ2L7hkkXNOUGYKWcEUHC8JztgojFYqExo8+DJFWYwT40S4XxbV5DQhgmtlMcHVA6dkgnSMBbsksSQJI6q4MvHEc86bMq7VxzmL4CVIKNHKMweu+Sc6HArBZGskF2jbMJuocASrSrjYOo9E3tdvKfubcDUS8VaCMoR57DNUw7JXPKv3HlTsX4TneFzt5+Cf9vkhiOuNr4goDCfA0I1ZrtdpjPhfJ5aVSShkNCuTcXFwjGP/TilHEARBEARBEARBEARxBbhU2LxfVm24kFN6r9UiajhZ6Pvn/tOzn27bz3ArJpldbRpdRxa7BjxFg3cz1bxf1S91yt55/Dzum1ftvctUaponWWxhjuCAv8Jqx+xnfyP+aRLhWvbW8vWs/2aJ4vnsVzsOJKGIfzu+RBRGQSWwMhGBIRw12S+qIjDCZpyrTne0TQYcy1j19mMKdZUdxcqkCXP1CcsuYNUjzlW+w1WWd/cDN9trzy4/B8o6fI60atYRy8rG17sOjIfNqEGbGMJyvfaySnSdM1z14pjEudrFflX1/o929Q/LpjHf73dlz+jZB3d7sezKcUp2tVFRHQRBEARBEARBEARBEDcUq8Hyp79/cGZBkbFFTl5ph7p1de1hkvkP9g+nkonyGz6BLu/Zoyw+l9nN32AL5jiFaPJXrdPEtbwmsUYQBFET7np9821+aub4+Y0+pyvKg8K+/9S13UNCgy8ueb1nJqsGY9/6o6fIeNPiN+OqJdfjElMVx04XNYhtGKrd/X7/ouqUaTVmoapQydfThGhKzn8xvKSq/LEJqRqTrSjGv1ZEccbs+NJK+hJoyHfUatRGkb/o6XgDuwb4Cu7j+lgZrEwGXGsILEqKdFYmuPB1nOtIcNWdzi7LJV9g3v2uvAke5bGuZFf50ZWUD3WVxbW3plRQPpZVDfYf38REVv45prjqnl9FPaGuOtIrqAPvz2KXpQvSoZL87rGr7NmrQyy7vCTjNNc5mV1eom9yNeoY5Srbx1Ufvl+zWcXP6ItpriPElRfr8H7uZFY21uMYQRAEQRAEQRAEQRDELaBt09sLVWrVWo5nDrPN7n8uM+PePSBSGHFV4MRu1jlbLdloHyjYGS/yvCG8aeOVkHTTljgkCILYm1P0wZqT+ae6TF7TpaI8c+eeUZ0sNs/bdip3b92Hl0SwarAvW5/455nCTaMTl1Zr76rajNWzcfJZg878KqsmlmD1C1imoVrRqDr5BbV2gSxwxx02XWRFeRYulIWzWaVbLxh1O/bsM1XrWSujIhGVwcpkFBLHLguKmpLAyoQJDnKaq65Y1zGaXZZdqay8gPEsn+rKk+Yq4y6PdaWwy7JsCvNNKrssa6axsgivWNd5mqvditr3rAOFTCm7vGyduw63tEvw6Ks3oT7q8OzHbNd9fAa3ZIlll8duto8201zXIezaiHPVk8HKR4e59webwqpPLLs8ltNY+fcq2aO++ZXUgc/mXhYyjvn+vCSzf7iMwn2XcKVkzwPveYL7NHnnqenha88l7zye+0MhSUlJ5dK994dC8J5nHtzfyRPcdwm3zfI8vMG+VdVXb3D/J88ynntZVYR3X7375r0/FEEQBEEQBEEQBEFURnx8I0vb1g0WBvnL52wOGyspKR2+dc+ROxhxtQihWtMEVYm5uYU5RFV0xB9BvVqepqXMCIK4mQxrGpWg4LicHIN1flxiqk9BM2lSM2uTCP+nHUz24wTu29RUWVFVvYEKxXS7KIftOX+lY4F5SUXC+ztiOz+9akDzicseazZxxetbMopfwTSDRewfM37xh7GPpvy35RPLE3pOWhn/9DvbGrr2f7vEhJe2Bmnt9heC1Io9W2YP3ldVf+pPWJ5QZLCPDVJzM7I+H3WmonxvbFr+vt7iaN8w0v+Z9G+HVSv6qzIqG6g0OJ5jZVIg0XWdxqpPLLssHKaxK/caws7jknbJrEwqTPbKU53ym119m8Z872mVwC4vxdfRle5ZHq9RvmD0TUWRRdNYmRDJgOOuCupIY5clFPY53quOWa5+ZLjSMnzUgUvSjXKdmSt/LLv8PnjnT2ZlEUib2bXhXhIv2es+9gOlkXtZxDRWNQms7Nk6siufcbPrmO/KV9GyjJNdffG2Et6fl9mu6wpDBwmCIAiCIAiCIAiCIG4Ed3YcvO/48VNLirXF/zWa7bVyC0vvhcnBrdeyL8+/FV3a0VhrTv4g3mBVS6EBebYwv19IQlWMey8vGiOCuL588Urvko5TVj+SXWxaevp8yeefrD790KShzaze+TZPH7ylzdOr3skqNb333NJVOH8+o7J6D3w2dGP9CSmHbQ7pkYaPLr5gdbDGCp67zWqXmo39rri2Q5IU7h9mnsMf77KfbYNVbAs/8e3MdjsrhTu5cO9YsZn9Nm6JqW7CkiyFwPYJPH9qfVFBuCjKEVEhqhcvsMrp+vza9hmFxhmBKuGvhzo2fz+pgnxNH095ushkf8FPwc/e/fGQRew6wFeRjpP9aa7XGJ0Ty6qPp+BIqiQfvlnuaKDQqyifxC5LlMQK+jCNlRdInmSw8qLHk9ga1IGCCZ8jjpUJJTd4neB67S2hvOuY43Hd3uN+RVyrhEpgl9/TBV5p+CzJrteJrPrg+5hRQVoyuxxpVdGSf9huRe+Hu/6aLBtIEARBEARBEARBEARxXWnWjLPWbhD1vUYlXLRYRcW59KwHflv1ZwtG1AiUKubT2WPMJcaOIsxS2jXC7qieHdczgiCIW8D+2UPXBGmUbxpt4piZi4++U1G+Z9tFzwjxU6RdKLa81WHSyh6+8iQkpoZ2mLxqQN2EpZ9bHVK0VZQCtWZphk2UH7E45AZqhXAgWCPMDlDzk2KC1Q+0ru0/sHGg8vYeDUOdbiHKX1jSrV7I7fWD1HfEhgXcFRWofDJQrXrDX8H9bpfkQqijb4nJ/obB4ngG8xebbU81fmzZK22fWdXWLaw96fT44joXikwLwXNJ/krFw0lPt/G559OdU1cP1FnFN4P8lJvjYsPfZdeJKkPHWFkUEEYMxTLf0T6+QEmQ4HqdVEVelAoprvwY4bPM1Za7/BxWNUns8v5RDVlZ9Ewcq1iyeJPMrtyfCXGLjrRq1JHByiTLNFYmS5a57o/zaCODVR+39EqA4yC7LHCuJ1X1DZ/Zc1+tNFY52OdlVeTxrNP9XnniXqawIkrZ5XHGKLaqPl8EQRAEQRAEQRAEQRDXnf+LuyPj/OmshTpT3lMGixyc+sefz6WkbH1h9OheekZUi+y0Q3XF9NxnObPdz+DPa8Nj6/7GGofpGHEFOLFcmpwSsve1jzo269Ae5wqLGUEQ150z80bObPn08hYFOvsLLZ9YVXTiy2EfeOeZOLGzvfcrq8eeyjbvztVZUzo9u/qOvXOHnn183h7ljn0FnQ2yLWHd+ZKhZptYT6XgrApeOCYzppdk1rhvi/D+rexp25OSknxG0L48a0fJ1oxiJgh8/poPBuyvqJ/PfnJavfH4iU9zdJZHNUrhsNEq1nPIjvdKzPZ3609YurnFxBW/1Q3k1/wxc1jmxwu3+32+Mf9zm2RvGhOoevLwFyNP+Kqzw6QVzQ5fNH6lVvCmEp1pwi9fjSpk14nqiCic+HfLqDhWJmyeq6JMB4/XcaxqQj3yLvMon8EqjkLyxJ2vg6sOlB3uiKIDrHoCKI1duTyfux8prHps9ip3NXW4WcYu76uFYz6ZXRZiaezaiWWX35uKZM4Bjz6426+MqtLddbojmnBsMn2kV4Wvcf5bgXsXee75FBsbWy49NDSUzZ8//4p7nowePfqKcjUF+5CQkMCuBezXrFmzKs1TWlparp0OHTqwKVOmVFoG8/fp04fVBNy/ynsvLU+wXe9xfe6555z9IwiCIAiCIAiCIIjrSaNGjSzzFq6an5VTNMZkZ/UKC0uHns098xskbWJElcgHcwMupO15QioxRqkkjqnCg3eqQsI30pJzFbBoRf2itI2vSefOD9aXFH8v79nzFuvUSaTlIAni+gI/U+JTn6VO3nBI37jAaH77jhfXWnbMGHxFkMiW94cWxE9d/+ChHN2qPKN1aeyjKd+s3HnhIbPN0UngOTvIoT2Rger3m0UFrFv9dt9zbZ9ZPSyr1LRi+9nSRxfNT9paVT9ARImVpW/PzAoqNFpHaRT82U+GNu98tMSiWHKoIM5ssw7T28Qh+QbLFyVm3hj76NLfZ63NlwxW++hAleL9w1+M+spXfT2mrm5yOs+0WinwAeHBQp9jc+/LYNeR6ogoBOWAe78onF1GEVCZWPGcUZ/Pqk+o1zmDVR/3THOsVx3VnYH2lS+2kjRfZHi0Heoq16GGdXiC0We4LF4CuxwlluBqJ42VCaQMdnW4l9tLq6IObCOOlUk69zNVRE3G2j1G3mSwqvHM4yuq6pYTFxdXaTrKnaoEEUoVPK6F5ORkp7y5FqrTVxRvCxZcDhrMzMysUkShhKqpJMPnqUxE+eor9o1EFEEQBEEQBEEQBHEjeHzM0KP7/jq6LDur5DG9UYref+DUyy8mfREs2WXnBKIsS5zAcN8PGeSKyASmkCSlgsPXCoYpNpxtxJWS4P9leTEPL/EyU4hMgrOS52WFwPMCzEqq4KzgYZYUMiolQeYkUXJAGY1wWUZIMi9rYCZVxQReoQCrA9cCtoX/5+D/nJ1TQZ3YQegNFyBhe0oZ++DsEvYX2hV46LPzKcrmQsF3cDzUpZCgcsZDXwQm2eEe1FVWCvJhvY6y/HgfJx5tooNXyNBv6DuD/KID14ySHTkrdzUQ8kruV5olhS1QKA2MrDU/YGSbfEZcAUinyL1f/zhZPHc2vl6DxtsyT54YZfx11fnm+fnfQ7KVEQRxXfn86XjD/e9vuXtXevH6U3mG6R0nrxT2zxk+0ztfs6bh+8/rzH8UGWwYyDMHvh1LowJVX4f7qeftmDVoP4r1M5DAlS3yt7LxY8s2ay32+9tMXvPxkTlDDrFroEinfVGUWGT7usHjx45tA3+Y4B8obDUeiYmy4recFWNNoji51OxwroqmVgqlsVF+Kb72ker07OomZwvMa+DbOap1reDhaTMHHGPXmeqKKAStH86KY8dRLlUn0si9jFp1Oeh1HcpqzvWcca5pXaE+ylYmXapDkuvAtSFRBsWxy1IKX1e271RFxLLLSx9msKr3gPLck+lGL4UXxqoWS55jqWUEQRAEQRAEQRAEQRC3AIxGmf1DytySon29TGZb+6xcQ/+84nO9y2J6JAbCxblPBy+gDALPw4Pp4ZxSB9QMz8H/GPoZTIMynJJzmiKmgHyQzHj4H/gn52slHJyAJZzuylmGZzJzaiF8jWdIVUB9SsbLahleQ1sKDssrnHkZ5gcF5XwtO9Nku6hgGugd1oF9dvaXldWJ/kyGewLkFSBJAboKsyjg0RxS2ebzoiy7xwJTnbXgGdMwSSXJDH+vn5fQt0lwlnGZOQY+iikdokalAsMVHbkhfEC/tRQNdSWyvFCwp1nrme1yo3rDhkyNGTRys+nHH+7JKszvXpsPXcxIRBHEDeHnV3qXgIwauDu9ZFVmkWV6w0eXhGd8fdfr7u+pJhNS4lfuOP+eyS52VwpcFkih2mold6xlRMCby9/rn8f5sCJhavlZnYXt1xrMc1nZNkVXxZ3PbWh7rLB0aoifavXGDwes8k5PSuIcibL867ePLGsLl13VSj4Tvn7DjuUYtsckLP1cHaCamf7ZMOcc/O0vrOt0vsDwmyxLUbFhgfeBhKoyWutqqImIQjDEAQcoFo6lrOL9ojyXV8M9nmoqdDJc51hWdRSOmw5ebWd63a+KWB/33Mv94VHVHlG++uB+HedKq2r/pMpYxi6Xx/cgmdVs3y5PPMVTAqs++P5X9n5WZ6zx/Yx1vc7wkY5LKh5glRPrOpey6yseCYIgCIIgCIIgCIIgasTkB0ed0efr39y6ff9CqySoLTabRgDxgxZGoVSijGJl+8ZzTBJB7qBQQgGFOginMzm8B9cc6qGyexLGDLnK4FmpUDi1FkOJg7dFvkxoCcwpn3in5IL/OhOdegpMUZlQkkFIyWCBZK5MVmF0FNosTFNiXqhLFMs0FefSUU5lhX3AvsnOJ2BcmUxyCikBX8tlR5l6KnvNuc9lFUB/oV1RBpGFQWAyU4NgA/PlFFzOgCvIaIzyPxZUK+hdrgn3t/plY9yT6e8gxjhuLLg++VCvuB5jyq45vP62adncoMgIgrhhoIx69pOdg9cdzZ+fb7C+Wu/RlNDeL61dkF5ofqnE5hit5Lmi2iGaZ5sEh/50rKjwQZ1Fmn4gV7+i49Orxux3iR5P9n46+nCzicv/W2CwTr/j+XUTdnw86LuK2rbbJKWv+w+9uC5gc7FhIXwr6+D74ClfeRLnp2t+eHz5uwar/fmIAOWvI+o0fHKvKa/xhWLLNL3N/rSol+5r+njKe36CIiszX/+xwHGqppEBI3fMGrKZ3SBqKqJw0h+lB+4XhdKhokiaDHZ5byGM5KmOxPEkjdUsCifBlTeDXd4/KIWVSZpQVz/SKikfy3zvZZXCLi+Hl8Sqlh6TXWdPkZLmqrsqiVMT8BnxfUh31V1dWecmznVOqUG50a52MCJuTiX1VtWX0a4z5vH1wU5gVX9eRrnOaexvSkpKyi1ZDg6XBPTcVwpfey9Vh8vbVYavJQGrKoNL8V0ruOReWlrapWtcZg/3yaqMgwcPluubrzJ4rdVqy7XjWQbHqKqlFAmCIAiCIAiCIAiiIlAMpKenr8/Oylt67lzuWKsDHAt4F16hkJUCn8kLdptzAg4kEkooZ+QSvBQEXOgOdY9TTslCWRARJyhUslIhYLayG5wg8zyuh1eWg3f6KRHvg1Pine7JGcckyBh1JYtwxUMZG97nJLiHqZgV9RY4KbBAKK0UzrKuFQNFBnfK1uLjUb7AAdVx+H/QUBIqLjv2WZJ5BVwpROiSjDqtTFtxZe4K1wGUXQv1yU7D5igTOgoUV3aOc4hymCA6QtROoQZ1+iss/m0afRjaOei6LwN1tchlBlCYO3eu/3//+18hLCzM8dJLLxmqklKrV69WHz58WGUymYQmTZrYNRqNZezYsT5F0cKFC4UxY8ZcWk5xx44dmnXr1qn9/f3Ffv36WTp37mz3zI+Rd65+cXv27FFOmzZNTEpKcvioU3bnXbNmjerQoUOaxo0bm6EfNu9n3Lt3r2Ljxo3+ZrOZg3kRS3x8vIURBHEFcyd1182bt+c/7+7Kfk1vsb957KLxSVGWuNpB6p+jlKFTtsy9s+CEK2vXyWtM6SWmTy5ozX90e2Hd2F0zB+31rm9UT/UXP2+yP3S20PBhv1c2bt30fv9TrAZs11qe01sdLaMDlVNPzBt53ju96bOrg7/dsv9bo036v1pB6lntiyxTZ3/VEb+L9sExstdzqwafKrbMKTTaPwbdxfyU/ImW4QH/Sf148EF2A+E8XqeyMpGQwKoWAShVZrleu4XRNFZeGCWwMhGUwapePs6XvHC3gfc7VlI+lpX1PdZHH9zPlMYqjxqazy5HBk3zqiPdVXcyHOMrqQPLucVcI1Z+v6h013k2K9trqyI8xyHWdc6oJL/7D8AwVn2hlMAuvy+NWPXBZ5vGyiRbR680z/Gr7Bnx+VBixrIrx9PzD3N8r9IqqKODqw4EjcO1RJldN2RZLveXERQbmzffMIFcIfPnz69y3yUM2a+MxMRE575KblDcNGpU+UcFZY7n3k34/KmpqZW2691XlEPjx48vVyf8Rb5cmarG1VcZb7BNz/2sKuhr5YNEEARBEARBEARBEF689PrXt505m/5DodbcCaQN02hU1p49OiTeM3LAj4LA8ZLRLIOckI2ySdZIfvBauryvE6gDnuecWK0WXkBTBFgsHAdFZExXqzXO/DgHwZk5zm63Qq2YrpHNzMzUarWEAUjMxJifxg/yGkEh+csBGJDlJ0vuuQt8FRIWwhfnFfsxKOfHwf+8HwbKmE2XL/38Gc4ickxvK9tFyk/DMTt4KJvt8r+f1WrGrFbGVK45Elxf0GQXytbhU4rMIIaWrNk5x5yZ091flDi7RrBbG4f/Xq//2Ie5eM7BbjHuCKjnn3++O0icu3mexyWtAuDQwhhv7d+//+oPPvjgiLeQgjkFxcqVKzsuW7bsMchXB24F4j4xdrv9wD333LPwnXfeOe6dH+ZextaqVUu3aNGiVffdd99QEFijoL0mUM4GYug0yKgfv/zyy93e/Zv6ynPxmzds69+6bevvYR7lhEeaACLpP8XFxYrvvvtuEfSzz9GjR4cJgtAiOjo6ddOmTe951vXEE0/EbdmyBX/RuwUcfjab7WJkZOQf77333m9Qj4ERBOGTpo8tf0prs3/gcEiaWoHKSSfnjf7SO8+d/1098Hi2+Xv86o0OUr959PMRX3vnafXE0q65BseuII1ic8bXo+M9v1denrUjdt6erPRglTDv/Py7nyhX98sb2h7J1h4MUAm7L3x3V3fveuMSU2ufzSpdZrQ5OtcN1rx3+LMRb3jnGfDS+phjhYbfjFaxl79SWN8kSPPglrlDC9gNpqYRUW5QNjRkZbKoor2PkllZ9EwcKxNCvmRUqKuOya7zAq82RnmUx3Rv6YBpKEFiXXV7R049xy7LqKWu6wyv9qexMoniFmre3OWqI8F1nVRBHe5oqCle6aUedUxx3ZtTQR34vO5xSnT1G+/7EoPTXOcDrGbRUG5ZlsZqxhxXmx1YxRFmGazsGbXscv/cxLKy9yCW+X6vPOtYyq78PDB2+X1EktnfREIRBEEQBEEQBEEQBEF8+PajJ19556tXi/86vECWhGirzao+tH//YyX5F49++tHzq/6N+x+5o3jYir2a9L3nn1DmFHZS2mTOjklh/jtCWjd56+8godyMGjVqPAie18LDwy+0adPmDz8/P2N6enrDU6dO3f/VV189uWvXrsnwTCsw6gjzw2vFnXfe+cyRI0eeCwkJOVGvXr29IHQKT5482TAvL+//5s+fP2rIkCGvgdha49GMoqCgoC/IH/WIESPa7N+/f0zDhg23Qdl1mZmZ9XNycnosX758SNeud7y5a9f2X92fGzw/9NADt53PzhwXXScyDW5dElFnzpxRHDp0aBjk8Xv55ZcjDhw48Ag8Q7pCoTgfFhaW5eqrM9ILRNOUxYsXPxkaGnq6ZcuW2wMDA4179uzpdOLEicTHH388/sEHH5z6448/5jCCIK7gzNcjP+/y8trNuQXmhXkG+xeNHl3WN0jDvXzo05GXfjP+zw+Grm/59Ko79WZrSq7OOq/ho0tiX32iwbSJHpGOx768a3fLJ5e/B+mvNpm47B249Zp3W7LXnxhtn1wZdjxHuxK+UbW1Q/3HXCiXV+Y6TV47+ui54u9wNdQ6wZonQEKVE2DPfrJa/ecZx9iDufpZoiz71w/zf+WOttEzv5pYPgLzRnG1IgpBkRDHKt8XCAUMiiKMXME3I41dXrbOvfeSW/5UJoEwX4qP8nGu1wdceb3B+8959CHOo45Ydnm5uWmu64QK6hjPLkf9jK6gDuaqx9eydWmuOjDCa4qrzAEfdaBQ6sPKR0UlszIp524z1OvZK4vS8mY0uxxplcRqBvYpxVVHIvMtopJd/cP0cezyM8axy++1W8xlVNCOe6yxrgTm+/3OuIr+EwRBEARBEARBEARB3DBQTsyfn/qnyWSYvvfA6bc4ThNQXGRpItlzZ/yyIhXnxY6yfxmcc7E+mcs9XTxeyCx9gNPZVJLAydYo/5yg2DofBt3X6RS7n/0tmDp1aus//vjj/aZNmy6aMmXKtHHjxhW5Rdqbb77Z9rvvvpt17NixaXPmzMGVepzLYc2aNeu2o0ePTq5du3bazJkznx06dKgOyyxatIjftm1bUxA+vxw+fHjGhQsX0urXr2/GMmq1mpMkiYe6hsO9uuPHj/9Pu3btzo0Z49wCir3zzjsNFixY8O2pU8dn/fXXXzgvmuvRTRGj1QSBlzz7brVaZZBODpPJ1AtEVkTfvn0nJiYmHmjdujW2iaFezvfikUceGblv377XbrvttrkTJkyYCeJJh88HIkv52GOPDQaZ9S1Isr9YxdtyEMS/nr8+HHz0pQ+3dv/lVNEreqtjqtnO9Y8Zv/SDgQ1Cv0pOinfO65/4bNip4a9tGrA3W/u61iy++tZnF/6vxwsbH9o+s/9f7nru7dr27a/+3Dew1Gz/721PLT8Ht9Rmu9T016N57TDdJsv9Gz26NJnn2WG1IBwzSuJDDpHVb1kr4LEdHw+65KEa3P9TWP0JKfOMNvGeABV/sUnt4Ps2v99/izsdv5O6vrD+jt/3G98x28T4AJVwuGlI4JTtswf9cZjdPK5FRLmFAn75hlaRJ4FdjvCJ80pHyeIdIeSZ3rEa5SuTEsmsTJrMd5UdzcrvU5TAyiJv5ldSBwqYA64+JHjVwVz1T2O+9zzy7oe7jlgfdaCEyXBdj3eVmeLRnnf+51j5/aiqYrJHXzJYzZnDLgu9OOZbRmGfcD3JROa7z57P6Av8i1k8uzxOcR5pnp+XmkSB3XJw7yI8rjeey+FdL3BvK8968bXnvlPue57gs1WVpyq86/Cur6IynuNanTIEQRAEQRAEQRAEcaMYP965z87Hj01OqnX6dM5ki8RrCkukFr/+tOH7ed+temrihGG7MIoGpMDfJgroRiLvLArO+2hTgnl/1vtqrcVfpRCYKURxQtmm/nNhk/tvcEcW/R1QqVStYmJiskEOvYMSCu+5opHwOAii5uOlS5d+9fvvv+Mk8XlcDq9fv36dQCzJ8fHxXw8ZMsTgXt6PoTBi7OTo0aP/C0LqhwMHDjTHOjA9LS1NduUr7N69+wsgnk57dSV92LBhT+v1+rUPP/zwVMg71T1OFUXVgXBiAq/ECAplnTp13gMRthWOcnlApNV/+eWXX69bt+7awYMHfwASyuzxfNY9e/asfvDBB3/ZvXv3+IULF/42duzYXEYQhE8+ermXHk6v9nph3eKLOvMnxSb7h6vTi55s8tjSmQ/2afN90oPNdCvf7ZcNP79PdX1hzaHzReZ3zhTq0po8unzWwCZhMz//b6/S+JdWt1Tzgt4MYjpHa/0GrbeC5x0gnnC1sXRRljUmu/R/dlF6WJIdzmVQlQpeKrFI5tGJqaFKxhwni4z35ugsH0kOKTgsQPlT4zD/Zza+3x/LOwVU31fW3153fEqixSEOgW8QQ6PwgBfrhju+WJk0yMRuMp4iKp7VnAxWtj9RVSS7DoxqwSX9cOYYZUV1JUryNZbPYGXPF+sqH+uj/HhWeXRRhisdRUt7Vx0oQzaz6kuRjBrWsdl1hLryu2fcsd+ZrOZczXvsSRorv69YRSS7Dozucvf5WsfpoOv+P0pAuYG/eDj3RLreoHjJzLyaj0LFzJkzx3l4tuG975J3u5MnTy633xP8parKfaW8wTHCoyZgu577WREEQRAEQRAEQRDE34HOrdrM0emNDbNzSv9PFJVKrc7SYcXqtE9Wbdz1ECSfZf8CYBKUL/z4j3u1B9Nf99NL/mg7DErZxMdGv1/nbyahkMDAwE1Dhw7dN2vWrDxf6R06dMgDCSWVlJQE4jX0X4R5DKvdbvcDiRPp63lAbG2HcsPMZvMpVxkZ96nGs8PhKH711VfPffvtt1e0BdIra9euXXsNBsPtX375ZSTcymdVAeMdFhZ6fPjw4Qc3bdp0RfKPP/54G7wndW677bYPk5KSTDCfIsC15JZbnTp1EqG/e0tLS4csX768GSsfiUUQhA+2zhy0F049u09ZlXBBa3uhyOSY+9m6gy82fmzZvNqhyoXw84Xf91/UuX/xaoWGfVBktr7229G8h1ISluTbRLkDzLTLgSrFLo2SS4nQ+G1gGjGvdUSw9tuXehr27t2reGuTRaMvssVk6w2NRYc0ymgTB+TqTD8VG605vCCbLTapsULgikJUbPS5r0atwrCqxxOX+/9VrOhSd8LS/1rscn/4crBEB6h+rReieXnDRwMv7me3hmuJiLoa3Eu13aryGa5jM7t63OLoZtZRyq6tvVvFtfb5eow1QRAEQRAEQRAEQRDETWXixP/L2bnz8JT35n6lKsjXjbTbgxUlpWKXb+an/LJz+6HHQQDs+1/eM0pedzAgd/rGh3V7zrzjb+LC7ZKdiSHqQlWrmHcbdG6x8O8moRCQQrgUXwmIKOf16dOn1VqtVoOvQ0JC5PXr16uh3wKgwnsYbbB69erU7du35168ePGjwYMHS/fdd9+Bhx9+OAufzxX1hFFS+8qyO5f5c/7yriRJjOd5ptPpfP7CNwguff/+/XecOHHiCRBS4cwlorBK/B1xWRauLMczTqFQmRo2bGjzVScItK4mk0nTqFEj/umnn77jqaeectbxxBNPOKO4nnzySS4qKgrb8i8oKAhgBEFUm52zhyU/9OK6RQfN0ogSs/nJEpPtPYPV8Vr98Uu2qxTCoh4xkcsmxPV4aPxPy2qXmu1xoswi/JT8Z+GBmhkHPxmSjT+DZ1x17YLju5edL+2u46TrWPP443uUfyhyBjs4x6ulZrE7ZmoSFXTf4MDmW1ZNWRGXp3MMX55hH2N1WBsoBb403F/xZYNaytl/vDP07HF2a7nZIoogCIIgCIIgCIIgCIIg/ufp3r1t3vSvF764ffMOW3GRbaxdFPisi6UdGDv7xetvff42iIk1kE38XxNSWQuOR5zbcu5x+UzOJH+dFM6BM7GHqor9m0R9Wq9312+4+FpW9jflkUceCQCZ1P3cuXMj+/bt28xisfjB++RMA3EUCCInDETUpfxDhw7NGzly5JM7d+6ccujQoZkHDx7Uvv3222fGjBmzdcKECX+kpqZiJJTk+R5jRBSrxopDzZo1yz98+HAwyCh/7zTvz8yZM2c4h8MOXeN5h8PB+6ovICAgDNL8f/311zeUSqVDFEXucnWcjHIMDrXdbse9pmSPZQYJgqgGP8wYZITTr3GJib+bdF3uyC61/8chy/fqTbYBa9JzZ649uzgXrpvBN4i5a/3AvivfHbw7Cwpwc6vfxldfdUYxtSJx4ZF189ef/lBndkw5V2BI+axgb6Eosfo8J8t+SsWuED9hpr9S9cv+uUMLzrC/BySiCIIgCIIgCIIgCIIgCOIGMPWxsempe04+++Wn32jyC8zDZEmpzMsxdBat5xe8+sZXr3Xs1/MHyGZgf2PckTwuvAUKXrujm7iSRXtbF2w5+LYq2zqI04sakeOZLUBh4ptGv12vb2OUUH/bZ33nnXfqL1y4cGZ6enq/2rVr/xEWFrY2MjJSC3ZHRmnj5+dXf9euXQ0lNDbssgyC8cEAhodef/31OzZu3NixtLS0M+R72mAwJO3Zs+eXfv36zWBXsVd7cHCwGaSQAM3xVeVt2rRpdYSRwt/fv+DFF198KjAwUG82mwUQUs4EfD4QbQ6M+MJoLrVa/XeZuyaIfxxpSUm4B+AWPPq9svHNnGJjL71dHGUX2SCHQ8YN5Px2ZxnX1x73+xm1QsiEL5PjKp7P91Py+ZIo59YO1ljqRPg5LHYrfz7PynNqISpXZwkXRTmcZ3I9SZLbfr7yRDNRkmOwPVwGVclzGYFq4dvoMC5l8PSRR5L+hlGnJKKI6wEuoZfBrm3/pgz2LwL+UlLj/ZA6duzI3OHh1QXDva91DyXsa1xcXLl7WCfuE+XmwIED5fJotdoq68V9qJKTk1lNOHjwYLnrBQsWOJ/RTWhoKEtJSam0jilTppTbzwrLEARBEARBEARBEMSNIr5zi8Lp07+fuO/48Zfz8nSPOUQhUGuwhP21/8j7RcW6Ya+8+XWuzDiVSqlw8DIPJsAZiiLzTJBx+Ta8Af+VFQIuyOZckg0DX3iO8ZwC8gmYjv/DOzwnQZKEesFflDlBgtvYCagSykI98D+XQMFJQQn+h/E9MLkJ9xnMd6p4geEEJpSDTnHQk+OfbBJ4mOhUw7XgwOxlYkqGMw/1Q24ROm5TWkRefz6/g5hraiHYoAjHZKF2QKa6SfS0Bm8O/Bmeyc7+pqSmpioee+yxd0pKSrrHx8ePb9myZeqHH35o8IwI+uGHH9rv3Lnzce+ymAdwvPvuu3/CecuKFSv8/vzzz8DTp0/3h3oT16xZ037r1q1De/XqpfcuWlmf8vPzg0GCWWDewu7dnndejIhi+JZUAognLYgtuXv37hlwZFYV7TR+/HhGEMS1sen9/kVwWobHHc9t9ysyFLZRKOVuRUZHWwXPdzU7pAF2Ub7bHXmJZBssjF28PM3uToKfWaYWeCvI6WyVwB0WFIpfI0PUu0Fu/eVe3i8D8u2awf6WkIgirgfPuY5roRH7F4FyZ/Pmmm19hV82NSUjI6PG7Xjjq68okDxFFMqgmraD8upawefDw41nnyqiQ4cOjCAIgiAIgiAIgiBuJlOnPpz/wbyFb50/k5F39FDmK5ysCbVLLOTUmaxhQno2U6mVTAEKSIB/+ztNE5551EbOJeEYiCdIR/XEMz+1mik4FEqs7Iz5wBqBrHLWgfkEcBIakTHczAhfC5AP6wTJ5PwfyCjGS5yzfhXkEyQUUjxTKZUMqnLed2oKCf4jSpAX6nPITO3wsCcwO8rBfZwkhaokHtJVVsYrRbjw42RHLc0J/8bRr8bcMXAlzGk42N+Y3bt3NwMJ1SU8PPy3Bx98cO3YsWNtH330Ubk8VquVhwlgzukAXezZs0fZqVMnXHpPxGuX3DG5jp9BPin27t379bZt2zrDdapnfa7AKp/ApLTQvn37lhqNJr9Vq1b69evXM4/6MYKpxkvmORyOUyC2lFBXIxRRjCCIm8qOWT3McPrLdbDExER+ZU6vIFWArYHBxsL0Fod/iIaPydVZhXoRfpGlJqvRITJDVECASWu1XFSqlIW1FaK2d/DwvKSksu/U8666a7K8362CRBRBEARBEARBEARBEARB3GD+O3GsFgTD9A+m/3Zg+86D7xlNtvZMVilsNjvjBZA6ChsoI6cmwk2FQA6BQuIUzgCksvXvUDgJzGEDgYHiCZwEh07EGfLEo6UAGyTisk/OWmxwYOySgqGEkpgSyqJQEmSOuYuh1kCZJKCUgrMEfXEWgvuCM01ynp0CC8yZ03/gfcijxIZQRsGhwO6AEJNBlFhrKfSOYH55q4F3vKsa0fzkP2GfIa1W66dQKNQBAQHZY8aMuSJy68cffwz+/PPPh4HMCXYLpOXLl/tPmjRprsFgCFi9evW4oUOHltv7CmUSCJ+jIJNKs7KyYrz3XIL2Ards2RLIfKww9J///Ce2oKAgDvpzCMRY7uzZs911cti+13KJ1eKee+7567PPPiv55Zdf/q+0tHQn3DJXlJf2hyKIG09SUhJ+meCyUoe90/I8Xnta42Nw/MH+mZCIIgiCIAiCIAiCIAiCIIibgGsZt43T3rdm5FzMS8w6f3EETPsHcrLESSKGGwlOSSSxMvmk8fM3+KlVeiaLCpUC03hO4DlO6Vw0T+IVvCgr0Egx2bm5Dw8toDhSgDpS8rwsYJSVwDsjqWQOriUUSDJKI1zKT8b19XgMacJeQR9QK0kopZwSCvyYyOHe91irQ7YrmM1ki5AdEq9ycEzkypb0gxLwQmR2QXTwIf7n/VrUmik1DFgIEqronyIz2rZtmysIQr5er+8PwulXGIxL88CvvPJKKMibBzMyMh4AEQXDyjs3VoqJibEbjcZTcH/ynDlzhkGZ5Rj55ZZE06ZNU8PrQZAnuE+fPnu9mpRtNlsDEFzPJQIwIe3cO2vhwoVCZmam5vfff7+vpKTktgceeOClTp06mdl14PXXXz/7xx9/fLF37943jh8/vnPevHlLJk6caHJ2BvoMz6F+9913u/j5+eEeBqtYFUv9EQRB1AQSUQTxLwP+flOj/Lg0H+7nVBNwibxx48ZVmmfZsmWVLs+HezdNnjy5siqcywF67hHlC/ytIXyGisC+eu4ZRRAEQRAEQRAEQRA3Eq5sE/lTR44cmfj9T2uXXswpfV1bYm4jSioBo6Gc4geXx1PIYkx0xKmevbvNDw5WHpJtZmekjuzcIkqSeF6QFILNKQs4keMUCqXzLHIOkFEKWSEIzjQVmBObXRIUznwiB8LFqZ3QPmgEhewQHZwCzsyBKz3ZmQyv0bQoJZBQNonHnaD8NKpg7YmSkfn7zj/IdOZAAaOnQLeI8CjomkRBtAU1q7U4vHXDT2s9eMdO5zPez/4RuMRR7g8//JAMombuzJkzv4XXK4KDg20gZ+qLothHrVYbHn300dch7TO73R6O5Tp37mxfuXLlV1OmTOnx119/fdWqVas7+/bte+DJJ58sPHXqVJ2LFy/2zcrKGtirV6/Z//d//3fau12NRpMLMqrpggULfuvYseParl27Znz11VdRWO78+fND4N68GTNm/AGHd9HKoqEqSxMjIyO/g3622LZt28dnz57tN2TIkNTo6Ghdjx49ogsLC7uDiBtYq1atnyHvGoY+lCAI4jpBIoog/mVMmzatJtmdezBdjYiqqh2styoRVVUdmF4dEZWZWfHSx3FxcSSiCIIgCIIgCIIgiJtOmzZtDCBBFs/6/McD2Rk5z5w9m/eAzWGPcIAsUvFqJtl54UJGTvuU/NXTQsMCDrVp3fQnyWLZMHBUl3z4d7eNlUWsCAx90HWOPEI5c2bNriBDRmn9EFlOuHgqa5CokxtzFhagRFlWtmKgLAuyyIL8joU1bzKvafeGP7CeLQz/tCXdXP2VQQzOT0xMlEDSTD569Ojr4O9A9vGGnj17/t6+ffuvx40bp/v11193NG/eHPM6yw4fPrxk48aNE+bNmzchNTV1PEik0YcPH5YdIPUCAwMLBw4cOCUgIGCJew8pz2ZBQhW++uqrT4GImghtPgvzJALuQQWCyty7d++3ofw3ngXwPQHpVQTi6ERISIjOM61p06b2mJiY0wqFwgiHVMlzGl588cWXIO++LVu2PLtjx4543GPMarVyderUOTd48OCpINxW/N339CII4p8HiSiCIAiCIAiCIAiCIAiCuAW45MCZ06dPv7xwceqazMzsJ0qL9H2tZilYEFS4BZNgt4kRcC9+1/Z9vUPCgjJyvineGhYWtKNb10476zYKOF2vXj1Jdi6fd20CCOrg2RkWeOHAvvY7P1jaWpTEvpYiXU+tzhKtMokCL/JMgCwYciOqOVEMUZ33Cw9fVL/tbb+Ejml9yBXp9Y8FxKANxuCb3bt3Lzl58mQdf39/uWXLljmtW7cuwbF99913cYzuxbxwfalc//79i+A0/cSJE1/C+1i7oKAgKCIiQteuXbusRo0aWSpqTxAEqWPHjvqxY8e+uWvXrjnYZnBwsB2EUGHXrl1LfI3n7NmzF4OwWgEi0vrzzz97JskHDhx4FwSajM9R2XPOmDHDCKdvQab9durUqRjob2CDBg2Ko6Ki8nEZQNobiiCIGwGJKIIgCIIgCIIgCIIgCIK4hTRr1swKp3WpqanbDh7Nizt26NR4k9HW1Wqy1+UwPAXjU2RBoS0xN9WW6JsUFhY/cO7s+WKNRp3TIKb2ET8/zV+fvT3/lB+n0TWoX9cQHBFq8A8IMgn+SrtGFSCGBIfKJayEhes4TqvX+ll1Or+i7JIAU1FeoF9IYF1O5G5fP+2XLjatoYEfU4QzsyOIt4tK3ipxPC5dBwLKoWSyjbdZFBplVmCd8MWK8MCfbmvW4jQb0tT2vyIvXM9R5Drcy/Z5pl8heTAPlgNppYdLvec9VgmiCHKP5531g3gqxqOyMu7ILTgsFaRZWQ3AiDw4nWIEQfhk5MiRQQ6HI0ClUllSUlJK2TUwZMgQNfychsFhXbVqVQm7jsTFxWlAnIfC945pzZo1Ol95QDIrGzZsGAkC3LFo0aICdg2MGTNGsNvtoTA2nMFgKE1LS6tWBCWJKIL4HwaXt8Nl8jypaik7b3AJPW8OHjxY7n5lS99V1K53GewrHm6w31X1Ffd+8nw+LO9dRqvVMoIgCIIgCIIgCIL4JxAfH49yYOXp06f//O23TR30WmlscUnRUKvZUl8SrQpJUjJBoeTMZqtSwQvRDiuLPmPI6sBJ8gMBGo0tVCNabcZMmDBNLwU3UapQCiZBUNg4Jsky4yXeIfGCzELVEhfmJ7Nw2WIPMWTrlZwoq1E4CQ7IKTmYQpSYilcwB7NDewqZUzJjQGTQMUeQML92bP1t9R644+g/PQKqOlRHsPnKU51yGMVWUlJS7fwEQVxfQDQNgJ++FHjpX1xcFL9169Y0vD98+KgRPC+/DGk9ce89SZIh7+gDPM8mgpDa7auu0aNHz4R8z8NPdq5Op2sE85NOYYzSxmq1ToO6psKlGu+NGDHqCGPSYytWrNjpKhsKZa+QU/AdsXbFiuVDKur/3XffXQ9k0DT4KpnAucI04ZnWgOB+CvqZ4dG3flD/zw6HWAsOyDNqlyxL90H76V7PgP14H14+YbNZ09auXRvv1V5Du118wWq1TYDLAJ4XWHBw8Dvw+g1WDUhEEcT/MPAF4jw88Qwfv5Z6PfGWXb6Av0xXWef8+fMvXaPoatSoUaVlEhMTWXr65e9MlFBVtUMQBEEQBEEQBEEQf3eaNWuGv9X+Jx7w717NmjU7B2acPT/MbpW6OmyqJpIkBYiSgxdlUEUOOwtQaDjZLqoNZq3aLLFgBcc1wH/9KxQ8UygVjMMF9TicCOSZUuJAMHHMJjLGO/WUxDAuR8nwmjn/a1eIdtlPKFEEBh+yaJR/duzRKSVsYJMTl/YOepAR1wjOz4SFhTGCIG4uMJ/I79t3cBKonlm+c8h9UELBz2gmyKBsuNEC7nUQRbYG5i+beEdHwb3mIHAm+arJarW/DnXBwYogz/cgiW4D79wLvmeXwb3azOmb5CCPIgb3C18RmJd6KMvcqFGjNkCulnBlgjP0U64P5yGiKK2ELG0xG8ijxiCf1sJrBZQ5CHVGwOtuHMcv7tSpU7e9e/fasb4hQ4Y0EUX5N/ha6uSrvaFD724If+5sgPRmcIm/9b8FnscqCFy1o6tIRBEEQRAEQRAEQRAEQRDE3xTXPkPLs7OzN25YubtOZnZp4+Ag/975efk97XZ7jILjgwWHFMZEGbySpGACz+H/OEl2+idZlBhcMgEklIrjZZBUIJ9khgvuiUyUZCUnCxrB4uBYgcQJhZrgoAxVoP92Da/cEVmv3vnYMa3z/w3RTzcTPz+/osDAwPyCggKKhCKImwt34MBBEC7yPfD6DHy3NQRBo/TMAAL/HZAuy5ctW4a/DOAWTSDiWTjkjYFbl0QULt8HLv8XeOnzOxLaaSs7f8rlL1auXP7GsGHDwgRBUQw3avXr16/Rpk2bzqEckssylS5fvsynnR4x4v9aM+Z4GSXT6tUrFmIUJbR9L9T7dHFx0Yvbtm3Tg5jqD9WALOJaQ1qd5cuXX4TneJiVOaBdK1Ys7z58+PBInhfOwnXHOnXqdIbzDpBV3R0OaTnUFQX9OAblW3m3r1A4pksS1wzG4AetVvu4O+KrJpCIIgiCIAiCIAiCIAiCIIi/OXXr1jXB6azr2AAThopdu87Uzr2Q1+hCRkZ9u14fLXByowB1YBQnOurIdkcUk3mFABoKdzrCCBwVr3ColAqjmlfCRKicLdrtmQ6bpbRWnejshrc1Pl7/ttvSWTQzk3i6ccTHx1sOHjyYGBMTw0dFRekZQRA3E/jqlI4zxv8lSY6hgiBke2dwRTz96b4GmRPlVEoyy5QkMaN8bj4Rqrwdvl6TIT3BR2O7oOz/wXfq2P79x8zgefuDZVu9yRd79eqVASKK2Wy22rgEIFCCokqpVMreUVc873gV6r9fqRTuhMuFeA9E0yE4TXTnEUWxGJfLQ6xWtVMUORxie57noR8sDa9XrlxZCMJqK1wP5TgBl5XaAc93AvpjBKGWBFk1cG+GZ9sDBw4MgB7EQR4LPM/TINLr3nXXXX4Wi+X0mjVrqr03HYkogiAIgiAIgiAIgiAIgviH4VomL8t1OJdqYmeYaq92ryBc0KsO515QBcJ9wapwrtEvqjXOX7kPjg4WI7gIsVb9WraYTjE2No1J3FMknm4m7du3NzKCIG4JIHDehBMeuF8S7yvP6NGjO4CgeQO+ZwNB2vSF79dzosjGr1690uTOM3z48K4gtZ4HCfUjx/GbIE+Cdz0ggb6WJHkI1BEfEGAvcEVfXYDz2KSkJOf3rkqlqo37UAGNMFqqbE+qUWeh7hdWrFixzFXVKjj6QNqiip4LJNTkslfyH+vWLcKoKyYIfCwGW4FgKnTng7ZzcK1WWRab4jVKryFDhrREqQSS6r+yV5wm9K+dK1rqBGZXKlV9RVFicM4dMWL0hBUrUtawakAiiiBuAbinkufeRjcK+CJhU6ZMqTIP/AXo0vXs2bPZnDlzLl1jX1NTU9m14v282K9ly5YxgiAIgiAIgiAIgiCuHVyqCU7u3043MYIgCOJqCYVv1btdUsYGsumiUsnFMlek1JgxY8KtVtt8kDMXzGb2skYjDgQZdUUltWrVMubm5p6EuuI9lgA0wff1JTFks0m5CgUrgDwoiBwgfVrD7Sbw+tehQ4e2X7169SmYQ/0Z7v1cUWdHjhz9BpR7GNqAeuRH3fcliamh7xh1Zb+cm3O+Bknm575TWWQT9LW+69wS6ldD/e/A1Si41Rb+2PkWzjGsGpCIIohbBAqeG01paSnLzMysNE9ISEi5voSGhl6R53r01bsOX+0QBEEQBEEQBEEQBEEQBEHcSmBOdWtgYGCUUqmMEkV5KNyaAVKq66hRo86AFNpusdjeBsHTCu59pNHIDUDrNCorySmCg4O7tmrVauexY8dseXn5IGq4hyDhmCRxT/O8c2+qp0Fa/emKQtKtXr18Ldyr5W578ODBsSqV+gSIH41CoRgIt05V1lfo0yQQRG/ByyJB4AempKRcigaAPpbgGZ5D5XFPg4JNFMWaRmZaoewdy5cvzxs+fMyXPG/DaNw6I0aMaL1ixYqjVRXmGUEQBEEQBEEQBEEQBEEQBEEQBMHS0tIcuJ/S0qVLj9vt1k9BCqF0UYGU6onpHCf3xTPPcy+BVNoBguZNV9FISN3ctGnTdmPGjAH5I+M+TCB9+HtWrkxJW7582bOQjnv81VGpVGN9tb127doMaO8gvpYkKbCyfo4YMfpZkEpzoL48WZb6gIQ64JkOaafKznKdy3e5FmXPwB1i1UAQhAxXHSJKKHxtMBQUudNBaAVWpx6KiCIIgiAIgiAIgiAIgiAIgiAI4l/PyJEjca+lP3U63WG8VqvV/5EkuS6+5nl2Fs8gpGaAhIp0lwEx1Rn+i9FOBpBSH8DrPIPBwCmVKr4s3d4RTseHDBmiAqETjsvliWLZEqogkx4RBIby6bDdbjfwvGIc5Onsqvov/M+wYcPagBACiYVbXC3H/aLckVC4v4oBNNGb8Dpq+PDhcZimUCgyQEpBnfIuaD0BjodHjx79CYitRpCvm6vunawamEymo35+fiDiuHojRoz6YPnylFegz4+7ku1Q3/Hq1EMiiiBuAmDRWUJCArveaLVa9k/B+/lxqb758+dfus7IyLgij2e6L66mzIIFC5zvB0EQBEEQBEEQBEEQBEEQRHm4/8J/ZgcHh+BeShxIKKdDAeGyT6NRr8fXq1at+NazxIgRIxJAJIGIkg1arW4mzD1ayu6P+h6k0395XlgwatToV+BWDIooOM4rlcJGzMPz8mBJYlgWXgvYkrvadSCA0vCFICiwTw/IMhuEzYPQUmMklCtfIMfx81BuuYH6n4HTZzzP/wr9nwJ9awHndHgcd5ZVK1eu3M2qwfr1640g596CsnOgjZfhOV4EISc4R4pjH+PygtWph0QUQdwEUJjg8W8GBZAnKIw8JVJycjJLSkq6dI2iCu9VxrRp08rVW50yJKEIgiAIgiAIgiAIgiAIggCVspzjZN5sNudevifjMnt3g7wJA9mDEUzZIHr2Qr6ZixYtMviqBYRPDpxSIH8xnB3u+xERYUklJSW4rN9IjFiC81E477Va5U9WrFiaj3kcDvaNIHAaqD8Kyqvh1nk47yoszJ+1Y8cOsax+LhVEUmfGpN/xun79+lJeXl5KRU8lSdI5PKekpJSCROoD9b0Lz9MGxJENpNd2vV77jq9yssyf4jgpBfKUW+Jv+fLlX48aNQr6JU+BMasNt/Ig94Zly5Z/zAiCuHnIXvTp0wfV9U0/QO6U6wdeV1UmNTW1XJnExMRy6SB35OtBTftanXavpq/jxo0rVyYuLk720VeCIAiCIAiCIAiCIAiCIAjiOsAzgiAIgiAIgiAIgiAIgiAIgiAIgrgB0NJ8BHED6NChA+M8F+a8SeDSdJ6EhoayuLi4SstgHu86PMt413m1ePejqr5Wp92r6at3mfbt2zOCIAiCIAiCIAiCIAiCIAjixnDzZ8oJ4n8QWs7tfwvuVlhEgiAIgiAIgiAIgiAIgiCI/0FoaT6CIAiCIAiCIAiCIAiCIAiCIAjihkAiiiAIgiAIgiAIgiAIgiAIgiAIgrghkIgiCIIgCIIgCIIgCIIgCIIgCIIgbgj/D9scGLpuJiEzAAAAAElFTkSuQmCC";
  String base64Logo =
      "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";
  final String _disclaimer =
      "Disclaimer : The report does not provide medical advice.";
}

extension DateTimeExtension on DateTime {
  String format([String pattern = 'dd/MM/yyyy', String? locale]) {
    return DateFormat(pattern, locale).format(this);
  }

  String getAgeYears() {
    DateTime endDate = DateTime.now();
    return "${((endDate.year - year) * 12 + (endDate.month - month) + 1) ~/ 12} years";
  }
}
