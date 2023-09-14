// import 'package:flutter/material.dart';

// import '../../constants/app_colors.dart';

// class DarkBackButton extends StatelessWidget {
//   final VoidCallback? onPressed;
//   final Color color;
//   final EdgeInsets? margin;
//   const DarkBackButton(
//       {Key? key,
//       this.onPressed,
//       this.margin,
//       this.color = const Color(0XFFF4F4F4)})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 40,
//       width: 40,
//       margin: margin ?? const EdgeInsets.only(top: 10, left: 20),
//       padding: EdgeInsets.only(left: 5),
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: const BorderRadius.all(Radius.circular(10)),
//       ),
//       child: IconButton(
//           padding: const EdgeInsets.all(8),
//           icon: Icon(
//             Icons.arrow_back_ios,
//             color: Colors.white,
//           ),
//           color: color,
//           highlightColor: AppColors.primaryColor.withOpacity(0.5),
//           splashColor: AppColors.primaryColor.withOpacity(0.5),
//           visualDensity: VisualDensity.compact,
//           onPressed: onPressed ??
//               () {
//                 Navigator.of(context).pop();
//               }),
//     );
//   }
// }

import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class DarkBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color color;
  final EdgeInsets? margin;
  const DarkBackButton(
      {Key? key,
      this.onPressed,
      this.margin,
      this.color = const Color(0XFFF4F4F4)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      width: 20,
      margin: margin ?? EdgeInsets.zero,
      padding: const EdgeInsets.only(left: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: IconButton(
          padding: const EdgeInsets.all(8),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.primary,
          ),
          color: color,
          highlightColor: AppColors.primaryColor.withOpacity(0.5),
          splashColor: AppColors.primaryColor.withOpacity(0.5),
          visualDensity: VisualDensity.compact,
          onPressed: onPressed ??
              () {
                Navigator.of(context).pop();
              }),
    );
  }
}
