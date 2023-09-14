import 'package:flutter/material.dart';
import 'package:web_sdk/widgets/new_elevated_button.dart';

import '../../widgets/dark_button.dart';

class NoCardDialog extends StatefulWidget {
  const NoCardDialog({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _DialogState();
  }
}

class _DialogState extends State<NoCardDialog> {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      child: Container(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 10,
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.width * 0.5,
                  child: const Image(
                      fit: BoxFit.fitHeight,
                      image: ExactAssetImage(
                          "assets/images/img_no_card_found.png")),
                ),
              ),
              Container(
                height: 10,
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  "Oops!\nWe're unable to clearly see your wellness card",
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                height: 20,
              ),
              Text(
                "Please retake the photo. Make sure the entire wellness card is clearly visible and in focus.\n",
                style: Theme.of(context).textTheme.labelLarge,
                textAlign: TextAlign.center,
              ),
              Container(
                height: 20,
              ),
              NewElevatedButton(
                text: "Okay",
                onPressed: () => Navigator.pop(context),
              ),
              Container(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
