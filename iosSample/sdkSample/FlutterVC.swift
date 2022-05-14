//
//  FlutterVC.swift
//  sdkSample
//
//  Created by Avinash Joshi on 14/05/22.
//
import Flutter
import Foundation

class FlutterVC: FlutterViewController {
    var methodChannel : FlutterMethodChannel?
    init() {
        let flutterEngine = (UIApplication.shared.delegate as? AppDelegate)?.flutterEngine
        
        methodChannel = FlutterMethodChannel(name: "app.channel.neodocs/native", binaryMessenger: flutterEngine!.binaryMessenger)
        
        super.init(engine: flutterEngine!, nibName: nil, bundle: nil)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func getExtraData(result: FlutterResult){
        var args = [String: String]()
        args["userId"] = "iosUser"
        args["firstName"] = "firstName"
        args["lastName"] = "lastName"
        args["gender"] = "gender"
        args["dateOfBirth"] = "1651047119"
        args["apiKey"] = "NCqeTHkBa2QTdwM3H2UXO4H9iQbb4N1eXNKbzVi0"//change API Key
        
        result(args)
    }
    
    private func nativeCallback(call: FlutterMethodCall){
        if let args = call.arguments as? Dictionary<String, Any>,
           let status = args["status"] as? String{
            if(status == "0"){
                // user exited from the process
                //args["data"] has details of the test if required
            }else if(status == "200"){
                //test complete with result
                //args["data"]
            } else{
                //test complete wait error
                //args["data"]
            }
            print(args);
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        methodChannel?.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
            // Note: this method is invoked on the UI thread.
            if call.method == "getExtraData"  {
                self?.getExtraData(result: result)
            } else if call.method == "nativeCallback"{
                self?.nativeCallback(call: call)
            } else{
                result(FlutterMethodNotImplemented)
            }
            
        })
    }
}
