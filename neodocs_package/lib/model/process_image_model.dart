
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:web_socket_channel/io.dart';

import '../provider/neodocs_api.dart';


class ProcessImageModel {
  var request = PublishSubject<Map<String,dynamic>>();
  final String apiKey;
  ProcessImageModel(this.apiKey):
    api = NeoDocsApiImpl(apiKey);

  Stream<Map<String,dynamic>> get endpoint => request.stream;

  var image = PublishSubject<Map<String,dynamic>>();
  Stream<Map<String,dynamic>> get upload => image.stream;

  var result = PublishSubject<Map>();
  Stream<Map> get updates => result.stream;
  late NeoDocsApi api;

  late WebSocket socket;
  void createRequest(Map<String,dynamic> document) async {
    try {
      Map<String,dynamic> response = await api.createRequest(document);
      request.sink.add(response);
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 500));
      debugPrint("createRequest error  : $e");
      request.sink.addError(e);
    }
  }

  Future<WebSocket> createConnection(Map action) async {
    socket = await WebSocket.connect('wss://jg32vow333.execute-api.ap-south-1.amazonaws.com/production');
    socket.listen((event) {
      debugPrint(event.toString());
      result.sink.add(json.decode(event));
    });
    final map =json.encode(action);
    socket.add(map);
    return socket;
  }

  void getUpdates(String uId,String imageId) async {

    try {
      Map<String,dynamic> response = await api.getUpdates(uId,imageId);
      result.sink.add(response);
    } catch (e) {
      await Future.delayed(Duration(milliseconds: 500));
      debugPrint("getUpdates error  : $e");
      result.sink.addError(e);
    }
  }

  void uploadImage(File file,String url,Map<String,String> fields) async {
    try {
      Map<String,dynamic> response = await api.uploadImage(file,url,fields);
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


