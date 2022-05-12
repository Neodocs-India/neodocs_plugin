package in.neodocs.sdkexample;

import android.app.Application;
import android.util.Log;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MyApplication extends Application {
    private FlutterEngine flutterEngine;
    public static String FLUTTER_ENGINE_ID = "NEODOCS_MODULE_ENGINE";
    private static final String METHOD_CHANNEL = "app.channel.neodocs/native";

    @Override
    public void onCreate() {
        super.onCreate();
        initFlutterEngine();
    }

    void initFlutterEngine(){
        flutterEngine = new FlutterEngine(this);
        flutterEngine.getDartExecutor().executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault());
        FlutterEngineCache.getInstance().put(FLUTTER_ENGINE_ID,
                flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), METHOD_CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.contentEquals("getExtraData")) {
                                getExtraData(result);
                            } else if(call.method.contentEquals("nativeCallback")){
                                callback(call);
                            }
                        }
                );
    }

    void callback(MethodCall call){
        if(call.argument("status")=="0"){
            // user exited from the process
            Log.i("data",call.argument("data").toString());
        }else if(call.argument("status")=="200"){
            //test complete with result
            Log.i("data",call.argument("data").toString());
        } else{
            //test complete wait error
            Log.i("data",call.argument("data").toString());
        }
        //todo: do your thing
    }

    void getExtraData(MethodChannel.Result result){
        Map<String,String> data = new HashMap<String, String>();
        data.put("userId","userId");
        data.put("firstName","firstName");
        data.put("lastName","lastName");
        data.put("gender","gender");
        data.put("dateOfBirth",System.currentTimeMillis()+"");
        data.put("apiKey","NCqeTHkBa2QTdwM3H2UXO4H9iQbb4N1eXNKbzVi0");
        result.success(data);
    }
}
