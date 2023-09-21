/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import React, { useRef } from 'react';
import type {PropsWithChildren} from 'react';
import {
  Button,
  PermissionsAndroid,
  SafeAreaView,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  useColorScheme,
  View,
} from 'react-native';

import {WebView} from 'react-native-webview';
import { WebViewMessageEvent } from 'react-native-webview/lib/RNCWebViewNativeComponent';

import {
  Colors,
  DebugInstructions,
  Header,
  LearnMoreLinks,
  ReloadInstructions,
} from 'react-native/Libraries/NewAppScreen';

type SectionProps = PropsWithChildren<{
  title: string;
}>;

function Section({children, title}: SectionProps): JSX.Element {
  const isDarkMode = useColorScheme() === 'dark';
  return (
    <View style={styles.sectionContainer}>
      <Text
        style={[
          styles.sectionTitle,
          {
            color: isDarkMode ? Colors.white : Colors.black,
          },
        ]}>
        {title}
      </Text>
      <Text
        style={[
          styles.sectionDescription,
          {
            color: isDarkMode ? Colors.light : Colors.dark,
          },
        ]}>
        {children}
      </Text>
    </View>
  );
}

function App(): JSX.Element {
  const isDarkMode = useColorScheme() === 'dark';
  
  const backgroundStyle = {
    backgroundColor: isDarkMode ? Colors.darker : Colors.lighter,
  };

  const webviewRef = useRef();
  let webRef;
  
  // const sdkUrl = "http://localhost:59027/#/";
  const sdkUrl = "https://neodocs-test--sdk-react-native-a9t0skoi.web.app";
  // const sdkUrl = "https://neodocs-test--sdk-2co6klqs.web.app";
  
  const granted = PermissionsAndroid.requestMultiple([
    PermissionsAndroid.PERMISSIONS.CAMERA,
    // PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION,
    // PermissionsAndroid.PERMISSIONS.ACCESS_COARSE_LOCATION,
  ]);
  // granted.then((val) => console.log(`GRANTED: ${JSON.stringify(val)}`));

  const msgListener = function (e: any) {
      console.log('got message from webview');
    // if (e.source === sdk) {
      // e.preventDefault();
      const data = JSON.parse(e.data);
      if (!("message" in data)) {
        return console.log("Data from Flutter: ", data);
      }

      const msg = data["message"];

      console.log("Message from Flutter: ", msg);

      if (msg.toLowerCase() == "userdata") {
        const obj = {
          userId: "userId",
          firstName: "firstName",
          lastName: "lastName",
          gender: "male",
          dateOfBirth: "1651047119",
          apiKey: "NCqeTHkBa2QTdwM3H2UXO4H9iQbb4N1eXNKbzVi0",
        };
        console.log("Sending data");
        webviewRef.current.postMessage(JSON.stringify(obj), '*');
      }
    // } else {
    //   console.log(`Received message from ${e.origin}: ${e.data}`);
    // }
  };

  const objStr = JSON.stringify({
    userId: "userId",
    firstName: "firstName",
    lastName: "lastName",
    gender: "male",
    dateOfBirth: "1651047119",
    apiKey: "NCqeTHkBa2QTdwM3H2UXO4H9iQbb4N1eXNKbzVi0",
  });

  
  const run = 
  `function setUser() {
    window.user = JSON.stringify({
      userId: "userId",
      firstName: "firstName",
      lastName: "lastName",
      gender: "male",
      dateOfBirth: "1651047119",
      apiKey: "NCqeTHkBa2QTdwM3H2UXO4H9iQbb4N1eXNKbzVi0",
    });
    console.log('USER FROM RUN: ', window.user);
    alert('set user');
  }
  setUser();
  true;
  `

  return (
    <SafeAreaView style={backgroundStyle}>
      <StatusBar
        barStyle={isDarkMode ? 'light-content' : 'dark-content'}
        backgroundColor={backgroundStyle.backgroundColor}
      />

      {/* <View style={{width: '100%', height: '100%'}}>
        <WebView
          // geolocationEnabled={true}
          // mediaPlaybackRequiresUserAction={false}
          // injectedJavaScript='console.log(`iJ RNWV - ${window.ReactNativeWebView}`)'
          // injectedJavaScriptBeforeContentLoaded='console.log(`iJBL RNWV - ${window.ReactNativeWebView}`)'
          // injectedJavaScriptForMainFrameOnly={true}
          // injectedJavaScriptBeforeContentLoadedForMainFrameOnly={true}
          javaScriptEnabled={true}
          scalesPageToFit={true}
          mixedContentMode="compatibility"
          onMessage={msgListener}
          // onMessage={(e) => alert(e.nativeEvent.data)}
          ref={(r) => {r?.postMessage(objStr);}}
          source={{uri: sdkUrl}}/>
      </View> */}

      {/* <ScrollView
        contentInsetAdjustmentBehavior="automatic"
        style={backgroundStyle}>
        <Header />
        <View
          style={{
            backgroundColor: isDarkMode ? Colors.black : Colors.white,
          }}>
          <Section title="Step One">
            Edit <Text style={styles.highlight}>App.tsx</Text> to change this
            screen and then come back to see your edits.
          </Section>
          <Section title="See Your Changes">
            <ReloadInstructions />
          </Section>
          <Section title="Debug">
            <DebugInstructions />
          </Section>
          <Section title="Learn More">
            Read the docs to discover what to do next:
          </Section>
          <LearnMoreLinks />
        </View>
      </ScrollView> */}
    </SafeAreaView>
  );

}

const styles = StyleSheet.create({
  sectionContainer: {
    marginTop: 32,
    paddingHorizontal: 24,
  },
  sectionTitle: {
    fontSize: 24,
    fontWeight: '600',
  },
  sectionDescription: {
    marginTop: 8,
    fontSize: 18,
    fontWeight: '400',
  },
  highlight: {
    fontWeight: '700',
  },
});

export default App;
