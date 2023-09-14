import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

abstract class NeoDocsApi {
  Future<Map<String, dynamic>> createRequest(Map<String, dynamic> map);
  Future<Map<String, dynamic>> getUpdates(String uId, String imageId);
  Future<Map<String, dynamic>> uploadImage(
      Uint8List fileData, String url, Map<String, String> fields);
}

class NeoDocsApiImpl implements NeoDocsApi {
  final String key;
  http.Client client = http.Client();
  static const BASE_URL = "api.neodocs.in";
  static const REQUEST = "/uploadimage";
  static const RESULT = "/getresult";

  NeoDocsApiImpl(this.key);

  @override
  Future<Map<String, dynamic>> createRequest(Map<String, dynamic> body) async {
    /*HttpClient http = HttpClient();
    http.badCertificateCallback =
    ((X509Certificate cert, String host, int port) => true);

    debugPrint("createRequest  request");
    */
    Map<String, String> header = {
      "x-api-key": key,
      HttpHeaders.contentTypeHeader: 'application/json',
      // "Access-Control-Allow-Origin": "*",
      // "access-control-allow-origin": "*",
    };
    debugPrint("createRequest body : ${body}");
    try {
      final response = await client.post(
        Uri.https(BASE_URL, REQUEST),
        body: json.encode(body),
        headers: header,
      );
      debugPrint("createRequest response : ${response.body}");
      debugPrint("createRequest  statusCode : ${response.statusCode}");
      if (response.statusCode == 200) {
        // If the call to the server was successful, parse the JSON
        final json = jsonDecode(response.body);
        return json;
      } else {
        throw Exception(response.statusCode);
      }
    } on TimeoutException catch (e) {
      print('Timeout Error: $e');

      throw Exception('No Internet connection');
    } on SocketException catch (e) {
      throw Exception('No Internet connection');
    }
  }

  @override
  Future<Map<String, dynamic>> getUpdates(String uId, String imageId) async {
    debugPrint("get Insights  request");
    Map<String, String> header = {
      "x-api-key": key,
      HttpHeaders.contentTypeHeader: 'application/json',
      "Access-Control-Allow-Origin": "*",
    };

    final bodyData = {"uId": uId, "image_id": imageId};
    try {
      final response = await client.post(Uri.https(BASE_URL, RESULT),
          body: json.encode(bodyData), headers: header);
      debugPrint("response : ${response.body}");
      debugPrint("createWooOrder  statusCode : ${response.statusCode}");
      if (response.statusCode == 200) {
        // If the call to the server was successful, parse the JSON
        final json = jsonDecode(response.body);
        return json;
      } else {
        throw Exception(response.statusCode);
      }
    } on TimeoutException catch (e) {
      print('Timeout Error: $e');

      throw Exception('No Internet connection');
    } on SocketException catch (e) {
      throw Exception('No Internet connection');
    }
  }

  @override
  Future<Map<String, dynamic>> uploadImage(
      Uint8List fileData, String url, Map<String, String> fields) async {
    var request = http.MultipartRequest('POST', Uri.parse(url));

    final fileName = fields['fileName'];
    fields.remove('fileName');
    //extra fields
    request.fields.addAll(fields);

    request.files.add(http.MultipartFile(
      'file',
      Future.value(fileData).asStream(),
      fileData.lengthInBytes,
      filename: fileName,
    ));
    try {
      var streamResponse = await request.send();

      debugPrint(
          "uploadMediaFiles streamResponse: ${streamResponse.toString()}");
      http.Response response = await http.Response.fromStream(streamResponse);

      debugPrint("uploadMediaFiles response body : ${response.body}");
      final map = {
        "statusCode": response.statusCode,
        "body": response.body,
      };
      debugPrint(map.toString());
      return map;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
