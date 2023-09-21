import React, { useRef } from 'react';
import { Button, Text, View } from 'react-native';
import {WebView} from 'react-native-webview';

const html = `<!DOCTYPE html>
<html>
  <head>
    <title>WebView Example</title>
  </head>
  <body>
    <h1>Hello from WebView</h1>
    <button id="sendMessageButton">Send Message</button>
    <p id="messageReceived"></p>
    <script>
      const sendMessageButton = document.getElementById('sendMessageButton');
      const messageReceived = document.getElementById('messageReceived');

      sendMessageButton.addEventListener('click', () => {
        try {
          window.ReactNativeWebView.postMessage('Hello from WebView!');
        } catch(err) {
          console.error(err);
        }
      });

      window.addEventListener('message', event => {
        console.log(event);
        const message = event.data;
        messageReceived.textContent = 'Received message from React Native: ' + message';
      });
    </script>
  </body>
</html>
`;

const WebViewComponent = () => {
  const webViewRef = useRef(null);

  const sendMessageToWebView = () => {
    const message = "Hello from React Native!";
    const jsCode = `window.postMessage('${message}', '*');`;
    try {
      webViewRef.current.injectJavaScript(jsCode);
    } catch(err) {
      console.error(err);
    }
  };
  
  const handleWebViewMessage = (event) => {
    console.log(event);
    const message = event.nativeEvent.data;
    alert(`Received message from WebView: ${message}`);
  };

  return (
    <View style={{ flex: 1 }}>
      <Text>React Native App</Text>
      <Button title="Send Message to WebView" onPress={sendMessageToWebView} />
      <View style={{ flex: 1 }}>
        <WebView
          ref={webViewRef}
          source={{ html: html }}
          onMessage={handleWebViewMessage}
        />
      </View>
    </View>
  );
};

export default WebViewComponent;