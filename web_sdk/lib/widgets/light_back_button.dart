
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class LightBackButton extends StatelessWidget{
  final VoidCallback? onPressed;
  final Color color;
  final EdgeInsets? margin;
  const LightBackButton({Key? key, this.onPressed,  this.color = Colors.white, this.margin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      margin: margin??EdgeInsets.zero,
      padding: const EdgeInsets.only(left: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius:const BorderRadius.all(Radius.circular(10)),
      ),
      child: IconButton(
        padding: const EdgeInsets.all(8),
        icon :Icon(Icons.arrow_back_ios,color: AppColors.primaryColor,),
        color: color,
        highlightColor: AppColors.primaryColor.withOpacity(0.5),
        splashColor: AppColors.primaryColor.withOpacity(0.5),
        visualDensity: VisualDensity.compact,
        onPressed: onPressed ?? (){
          Navigator.of(context).pop();
        }
      ),
    );
  }



}