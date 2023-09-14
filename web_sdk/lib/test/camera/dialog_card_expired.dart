import 'package:flutter/material.dart';
import 'package:web_sdk/widgets/new_elevated_button.dart';

import '../../constants/app_colors.dart';
import '../../widgets/bullet_text.dart';
import '../../widgets/dark_button.dart';

class CardExpiredDialog extends StatefulWidget {
  final VoidCallback onPressed;

  const CardExpiredDialog({Key? key, required this.onPressed})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _DialogState();
  }
}

class _DialogState extends State<CardExpiredDialog> {
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
                          "assets/images/img_card_expired.png")),
                ),
              ),
              Container(
                height: 10,
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  "Wellness card expired!",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Container(
                height: 20,
              ),
              BulletText(
                child: Text(
                  "This wellness card has expired. Using an expired wellness card may lead to inaccurate results.",
                  style: Theme.of(context).textTheme.labelLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              BulletText(
                child: Text(
                  "Please purchase a new wellness card and test again to get correct results.",
                  style: Theme.of(context).textTheme.labelLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                height: 20,
              ),
              NewElevatedButton(
                text: "Buy wellness card",
                onPressed: () {
                  Navigator.pop(context);
                  widget.onPressed();
                },
              ),
              Container(
                height: 10,
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  //Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  side:
                      const BorderSide(color: AppColors.primaryColor, width: 2),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Close",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              Container(
                height: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
