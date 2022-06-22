import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../widgets/bullet_text.dart';

class WaitedEnoughDialog extends StatefulWidget {
  const WaitedEnoughDialog({Key? key, required this.onPressed}) : super(key: key);
  final VoidCallback onPressed;
  @override
  State<StatefulWidget> createState() {
    return _DialogState();
  }
}

class _DialogState extends State<WaitedEnoughDialog> {
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
              Align(
                alignment: Alignment.center,
                child: Text("Note",style:  Theme.of(context).textTheme.titleLarge,),
              ),
              Container(
                height: 30,
              ),
               Text(
                  "You should only use this if you think 60 seconds have already passed after you dipped the card in the sample and took it out.\n",
                  style:  Theme.of(context).textTheme.labelLarge,
                  textAlign: TextAlign.justify,
                ),
              Container(
                height: 4,
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: BulletText(
                  child: Text(
                    "Scanning the card before 60 seconds may cause the test results to be inaccurate.",
                    //⚈
                    style:  Theme.of(context).textTheme.labelLarge,
                    textAlign: TextAlign.justify,

                  ),
                ),
              ),
              Container(
                height: 30,
              ),
              TextButton(
                onPressed: (){
                  Navigator.of(context).pop();
                  widget.onPressed();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Yes, I have waited enough",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                style: TextButton.styleFrom(
                  primary: AppColors.primaryColor,
                  side:  const BorderSide(color: AppColors.primaryColor, width: 2),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                ),
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
