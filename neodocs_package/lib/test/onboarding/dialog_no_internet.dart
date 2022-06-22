import 'package:flutter/material.dart';

import '../../widgets/dark_button.dart';

class NoInternetDialog extends StatefulWidget {
  const NoInternetDialog({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _DialogState();
  }
}

class _DialogState extends State<NoInternetDialog> {
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
                    child:  const Image(
                        fit: BoxFit.fitWidth,
                        image: ExactAssetImage("packages/neodocs_package/assets/images/imd_no_internet.png")),
                  ),
               ),
              Container(
                height: 10,
              ),
              Align(
                alignment: Alignment.center,
                child: Text("No Internet :(",style:  Theme.of(context).textTheme.titleLarge,),
              ),
              Container(
                height: 20,
              ),
               Text(
                  "Please check your internet connection and try again.\n",
                  style:  Theme.of(context).textTheme.labelLarge,
                  textAlign: TextAlign.center,
                ),
              Container(
                height: 20,
              ),
              DarkButton(
                child: const DarkButtonText("Okay"),
                onPressed: ()=> Navigator.pop(context),
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
