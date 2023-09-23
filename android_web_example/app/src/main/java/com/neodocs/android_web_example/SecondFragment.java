package com.neodocs.android_web_example;

import android.os.Build;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.JavascriptInterface;
import android.webkit.PermissionRequest;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;

import com.neodocs.android_web_example.databinding.FragmentSecondBinding;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

public class SecondFragment extends Fragment {

private FragmentSecondBinding binding;
    private WebView webView;

    @Override
    public View onCreateView(
            LayoutInflater inflater, ViewGroup container,
            Bundle savedInstanceState
    ) {

      binding = FragmentSecondBinding.inflate(inflater, container, false);
      return binding.getRoot();

    }

    public void onViewCreated(@NonNull View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        /*binding.buttonSecond.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                NavHostFragment.findNavController(SecondFragment.this)
.navigate(R.id.action_SecondFragment_to_FirstFragment);
            }
        });*/

        webView = binding.webview;

        // Enable JavaScript in the WebView
        WebSettings webSettings = webView.getSettings();
        webSettings.setJavaScriptEnabled(true);

        // Enable DOM Storage (if needed)
        webSettings.setDomStorageEnabled(true);

        webSettings.setAllowFileAccessFromFileURLs(true);
        webSettings.setAllowUniversalAccessFromFileURLs(true);
        webSettings.setJavaScriptCanOpenWindowsAutomatically(true);
        webSettings.setJavaScriptCanOpenWindowsAutomatically(true);
        webSettings.setBuiltInZoomControls(true);
        webSettings.setAllowFileAccess(true);
        webSettings.setSupportZoom(true);

        // Add a JavaScript interface to receive callbacks from the web page
        webView.addJavascriptInterface(new WebAppInterface(), "Android");



        
        // Load the web page with query parameters
        String apiKey = "your_api_key";
        String data = "key1=value1&key2=value2";
        webView.loadUrl("https://neodocs-test--sdk-2co6klqs.web.app");
        //webView.loadUrl("http://localhost:61961");

        // Handle JavaScript alert dialogs (optional)
        //webView.setWebChromeClient(new WebChromeClient());
        webView.setWebChromeClient(new WebChromeClient() {
            @Override
            public void onPermissionRequest(final PermissionRequest request) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    request.grant(request.getResources());
                }
            }

        });

        webView.setWebViewClient(new WebViewClient() {
            @Override
            public void onPageFinished(WebView view, String url) {
                super.onPageFinished(view, url);

                // Once the page is loaded, send a message to JavaScript
                //sendMessageToJavaScript("{\"userId\": \"id123\",\"firstName\": \"Jon\",\"lastName\": \"Doe\",\"gender\": \"male\",\"dateOfBirth\": \"1651047119\",\"apiKey\": \"NCqeTHkBa2QTdwM3H2UXO4H9iQbb4N1eXNKbzVi0\"}");
                sendMessageToJavaScript(getExtraData());
            }
        });
    }


    String getExtraData(){
        Map<String,String> data = new HashMap<String, String>();
        data.put("userId","id123");
        data.put("firstName","Jon");
        data.put("lastName","Doe");
        data.put("gender","male");
        data.put("dateOfBirth",System.currentTimeMillis()+"");
        data.put("apiKey","NCqeTHkBa2QTdwM3H2UXO4H9iQbb4N1eXNKbzVi0");

        JSONObject jsonObject = new JSONObject(data);
        String orgJsonData = jsonObject.toString();
        return orgJsonData;
    }

    private void sendMessageToJavaScript(String message) {
        // Use evaluateJavascript to send a message to JavaScript
        webView.evaluateJavascript("receiveMessage('" + message + "')", null);
    }

@Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }

}
class WebAppInterface {
    @JavascriptInterface
    public void onCallback(String message) {
        // Handle the callback from the web page
        // You can perform actions in your Android app based on the message received
    }
}