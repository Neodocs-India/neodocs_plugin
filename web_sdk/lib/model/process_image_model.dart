import 'dart:convert';
//import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../provider/neodocs_api.dart';

import 'package:web_socket_channel/web_socket_channel.dart';

class ProcessImageModel {
  var request = PublishSubject<Map<String, dynamic>>();
  final String apiKey;
  ProcessImageModel(this.apiKey) : api = NeoDocsApiImpl(apiKey);

  Stream<Map<String, dynamic>> get endpoint => request.stream;

  var image = PublishSubject<Map<String, dynamic>>();
  Stream<Map<String, dynamic>> get upload => image.stream;

  var result = PublishSubject<Map>();
  Stream<Map> get updates => result.stream;
  late NeoDocsApi api;

  late WebSocketChannel socket;
  void createRequest(Map<String, dynamic> document) async {
    try {
      Map<String, dynamic> response = await api.createRequest(document);
      request.sink.add(response);
    } catch (e, st) {
      await Future.delayed(const Duration(milliseconds: 500));
      debugPrint("createRequest error  : $e\n$st");
      request.sink.addError(e, st);
    }
  }

  Future<WebSocketChannel> createConnection(Map action) async {
    socket = WebSocketChannel.connect(
        Uri.parse('wss://jg32vow333.execute-api.ap-south-1.amazonaws.com/production'));
    socket.stream.listen((event) {
      debugPrint(event.toString());
      result.sink.add(json.decode(event));
    });
    final map = json.encode(action);
    socket.sink.add(map);
    return socket;
  }

  void getUpdates(String uId, String imageId) async {
    try {
      Map<String, dynamic> response = await api.getUpdates(uId, imageId);
      result.sink.add(response);
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 500));
      debugPrint("getUpdates error  : $e");
      result.sink.addError(e);
    }
  }

  void uploadImage(
      Uint8List fileData, String url, Map<String, String> fields) async {
    try {
      Map<String, dynamic> response =
          await api.uploadImage(fileData, url, fields);
      image.sink.add(response);
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 500));
      debugPrint("uploadImage error  : $e");
      image.sink.addError(e);
    }
  }

  void closeObservable() {
    result.close();
    request.close();
    image.close();
  }
}
