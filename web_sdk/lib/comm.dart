import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';

class Comm {
  static void sendMessage(String msg) {
    final parent = html.window.opener!;
    debugPrint('Sending message ($msg) to HTML');
    final data = jsonEncode({'message': msg});
    // parent.postMessage(data, '*');
    parent.postMessage(data, '*');
  }
}
