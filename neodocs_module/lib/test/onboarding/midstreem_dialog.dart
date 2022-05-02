import 'package:flutter/material.dart';

import '../../widgets/bullet_text.dart';
import '../../widgets/dark_button.dart';

class MidStreamDialog extends StatefulWidget {
  final VoidCallback? onPressed;
  const MidStreamDialog({Key? key, this.onPressed}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MidStreamState();
  }
}

class _MidStreamState extends State<MidStreamDialog> {
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
                child: Text("Collect mid-stream urine",style:  Theme.of(context).textTheme.titleLarge,),
              ),
              Container(
                height: 30,
              ),
              Text(
                "A mid-stream urine sample means you don't collect the first or last part of urine that comes out.\n"
                "This reduces the risk of the sample being contaminated with bacteria from :",
                style:  Theme.of(context).textTheme.labelLarge,
                textAlign: TextAlign.justify,
              ),
              Container(
                height: 4,
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child:

                Column(
                  children: [
                    BulletText(
                      child: Text(
                        "your hands",
                        style:  Theme.of(context).textTheme.labelLarge,
                        textAlign: TextAlign.justify,

                      ),
                    ),

                BulletText(
                  child: Text(
                        "the skin around the urethra, the tube that carries urine out of the body",//⚈
                    style:  Theme.of(context).textTheme.labelLarge,
                    textAlign: TextAlign.justify,

                  ),
                ),
                  ],
                ),
              ),
              Container(
                height: 30,
              ),
              DarkButton(
                  child: const DarkButtonText("Okay"),
                  onPressed: widget.onPressed ?? ()=> Navigator.pop(context),
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
