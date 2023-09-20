import 'dart:convert';

import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:web_sdk/test/camera/opencv_interop.dart';

class Comm {
  static void sendMessage(String msg) {
    // final parent = html.window.opener!;

    // final parent = rnWebView;
    // if (parent == null) return print('Could not send message');

    final parent = html.window;
    debugPrint('Sending message ($msg) to HTML');
    final data = jsonEncode({'message': msg});
    // parent.postMessage(data, '*');
    parent.postMessage(data, '*');
  }
}
