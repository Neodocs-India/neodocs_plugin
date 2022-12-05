import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BioMarkerTile extends StatelessWidget {
  final Map<String, dynamic> bioMarker;
  final bool margin;

  const BioMarkerTile({
    Key? key,
    required this.bioMarker,
    this.margin = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return InkWell(
      child: Container(
          margin: margin == true ? EdgeInsets.only(top: 20.h) : null,
          height: size.height * 0.1,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow,
                offset: const Offset(3, 1),
                blurRadius: 5,
                spreadRadius: 0,
              ),
              BoxShadow(color: Theme.of(context).colorScheme.primaryContainer)
            ],
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                bioMarker['user_value_flag_text'].toString().toUpperCase(),
                style: TextStyle(
                  fontSize: 10.sp,
                  color: getBiomarkerColor(bioMarker['user_value_flag_text']),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(
                height: 1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      bioMarker["display_name"].toString(),
                      style: Theme.of(context)
                          .primaryTextTheme
                          .headlineSmall
                          ?.copyWith(
                              color: Theme.of(context).colorScheme.secondary),
                      maxLines: 3,
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text.rich(
                    TextSpan(
                        text: bioMarker['estimated_value'].toString(),
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: getBiomarkerColor(
                                bioMarker['user_value_flag_text'])),
                        children: [
                          TextSpan(
                            text: bioMarker['unit'].toString().isEmpty
                                ? " "
                                : " ${bioMarker['unit'].toString()}",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                          )
                        ]),
                  ),
                ],
              ),
              const Spacer(),
            ],
          )),
      onTap: () {},
    );
  }

  Color getBiomarkerColor(final value) {
    Color color = const Color(0XFF2CBEA6);
    switch (value?.toString().toLowerCase()) {
      case "low":
        color = const Color(0XFFFCDC64);
        break;
      case "good":
        color = const Color(0XFF81CBB7);
        break;
      case "high":
        color = const Color(0XFFFFA51E);
        break;
      default:
        color = const Color(0XFF81CBB7);
    }
    return color;
  }
}
