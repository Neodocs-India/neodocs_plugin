import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:simple_timer/simple_timer.dart';
import '../../constants/app_colors.dart';
import '../../widgets/bullet_text.dart';
import '../../widgets/dark_button.dart';
import '../camera/capture_screen.dart';
import 'dialog_start_timer.dart';
import 'dialog_waited_enough.dart';

class StepStartTimer extends StatefulWidget {
  final PageController controller;
  final Map user;

  const StepStartTimer(
      {Key? key, required this.controller, required this.user})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _StepState();
}

class _StepState extends State<StepStartTimer>  with TickerProviderStateMixin {

  late TimerController _timerController;

  bool _isStarted = false;

  String timeLeft ="60";

  bool isComplete = false;

  late DateTime _startTime;
  @override
  void initState() {
    super.initState();
    _timerController = TimerController(this);
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.topCenter,
        color: Colors.transparent,
        margin:  EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
                flex: 6,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      Row(
                        children: [
                           CircleAvatar(
                            backgroundColor: Colors.white,//Theme.of(context).textTheme.black87,
                            radius: 20,
                            child: Text("4",style: Theme.of(context).textTheme.titleLarge,)
                            ),
                          const SizedBox(width: 20,),
                          Flexible(child: Text("Place the wellness card on the control pad, and start the timer",style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),))
                        ],
                      ),
                      Expanded(
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.6,
                                  height: MediaQuery.of(context).size.width * 0.6,
                                  child: Center(
                                    child: SimpleTimer(
                                      duration: const Duration(seconds: 60),
                                      controller: _timerController,
                                      onStart: (){},
                                      onEnd: (){
                                        setState(() {
                                          isComplete = true;
                                        });
                                      },
                                      valueListener: (duration){
                                        setState(() {
                                          timeLeft = "${duration.inSeconds}";
                                        });
                                      },
                                      backgroundColor: Colors.white.withOpacity(0.1),
                                      progressIndicatorColor: Colors.white,
                                      displayProgressText: false,
                                      strokeWidth: 15,
                                    ),
                                  )),

                              isComplete?
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.2,
                                    height: MediaQuery.of(context).size.width * 0.2,
                                    child: const Image(
                                      fit: BoxFit.scaleDown,
                                      image: ExactAssetImage(
                                          "packages/neodocs_package/assets/images/ic_white_tick.png"),
                                    ),
                                  ):
                              Text.rich(TextSpan(
                                text: timeLeft,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white,fontSize: 40),
                                children: [
                                  TextSpan(text: "\nseconds", style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white,fontSize: 14),)
                                ]
                              ),
                              textAlign: TextAlign.center,)
                            ],
                          ),
                        ),
                      )
                    ],
                  )

                )),
            isComplete?
            Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    color: Colors.white,),
                  padding: EdgeInsets.symmetric(horizontal: 30,vertical: 15),
                  clipBehavior: Clip.hardEdge,
              alignment: Alignment.bottomCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      RichText(
                        text:  TextSpan(text:'Please scan the card immediately.',
                          style: Theme.of(context).textTheme.bodyLarge,

                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 40,),

                      DarkButton(
                          onPressed: _startCapture,
                          child: const DarkButtonText("Scan my card")),

                    ],
                  ),

                ):
           Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    color: Colors.white,),
                  padding: EdgeInsets.symmetric(horizontal: 30,vertical: 15),
                  clipBehavior: Clip.hardEdge,
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      _isStarted?

                      Column(
                        children: [
                          BulletText(
                            child: RichText(
                              text:  TextSpan(text:'',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  children: <TextSpan>[
                                    TextSpan(text: 'Scan the card immediately after the timer ends for accurate results.' ,
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ]

                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                          BulletText(
                            child: RichText(
                              text:  TextSpan(text:'',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  children: <TextSpan>[

                                    TextSpan(text: 'If you weren\'t able to start the timer within a few seconds of dipping, click the ' ,
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    TextSpan(text:  "I have waited enough",
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        )),
                                    TextSpan(text: ' button below to ensure card is scanned in the window of 60-90 seconds post dipping.' ,
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ]

                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                        ],
                      ):
                      Column(
                        children: [
                          BulletText(
                            child: RichText(
                              text:  TextSpan(text:'',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  children: <TextSpan>[
                                    TextSpan(text: 'This 60 seconds timer will help you to scan the card between 60-90 seconds of dipping in the sample.\n' ,
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ]

                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                          BulletText(
                            child: RichText(
                              text:  TextSpan(text:'',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  children: <TextSpan>[
                                    TextSpan(text: 'This is assuming there’s a small gap of a few seconds between dipping the card and starting this timer.' ,
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ]

                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ),

                        ],
                      ),
                      SizedBox(height: 20,),

                      _isStarted?
                      TextButton(
                        onPressed: _showWaitedEnoughDialog,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "I have waited enough",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          primary: Colors.teal,
                          onSurface: Colors.yellow,
                          side: const BorderSide(color: AppColors.primaryColor, width: 2),
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(15))),
                        ),
                      )
                          :
                      DarkButton(
                          onPressed: (){
                            _showTimerDialog();

                          },
                          child: const DarkButtonText("Start timer")),

                    ],
                  ),

                )
          ],
        )
    );
  }

  void _showTimerDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return  StartTimerDialog(onStarted: _startTimer);
        });
  }
  void _showWaitedEnoughDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return  WaitedEnoughDialog(onPressed: _startCapture);
        });
  }
  void _startTimer(){
    _startTime = DateTime.now();
    _timerController.start();
    setState(() {
      _isStarted = true;
    });
  }
  _startCapture() async {
    List<CameraDescription> cameras = await availableCameras();
    final results =  await Navigator.of(context).push(MaterialPageRoute(builder: (_)=> CaptureScreen(cameras: cameras, startTime: _startTime,user: widget.user)));
    if(results!=null){
      widget.controller.jumpToPage(0);
    }
  }
}

