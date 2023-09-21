import { StatusBar } from "expo-status-bar";
import { useRef } from "react";
import { Button, StyleSheet, Text, View } from "react-native";
import WebView from "react-native-webview";
import { CookieManager } from "react-native-cookies";

const html = `<!DOCTYPE html>
<html>
  <head>
    <title>WebView Example</title>
  </head>
  <body>
    <h1>Hello from WebView</h1>
    <button id="sendMessageButton">Send Message</button>
    <p id="messageReceived">this should change</p>
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

export default function App() {
  const webViewRef = useRef(null);

  useEffect(() => {
    CookieManager.set({
      name: "name",
      value: "nimit",
      domain: "abcd",
      origin: "abcd",
      path: "/",
      version: "1.0",
    })
      .then((res) => {
        console.log("Cookie set:", res);
      })
      .catch((error) => {
        console.error("Error setting cookie:", error);
      });
  }, []);

  const sendMessageToWebView = () => {
    const message = "Hello from React Native!";
    const jsCode = `window.postMessage('${message}', '*');`;
    try {
      webViewRef.current.injectJavaScript(jsCode);
    } catch (err) {
      console.error(err);
    }
  };

  const handleWebViewMessage = (event) => {
    console.log(event);
    document.body.style.backgroundColor = "red";
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

  return (
    <View style={styles.container}>
      <Text>React Native App</Text>
      <Button title="Send Message to WebView" onPress={sendMessageToWebView} />
      <View style={{ flex: 1 }}>
        <WebView
          ref={webViewRef}
          source={{ html: html }}
          // source={{ html: html }}
          onMessage={handleWebViewMessage}
        />
      </View>
      <StatusBar style="auto" />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    padding: "4rem",
    flex: 1,
    backgroundColor: "#fff",
    alignItems: "center",
    justifyContent: "center",
  },
});
