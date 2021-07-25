import 'package:chatapp/utils/global.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomTextField extends StatelessWidget {
  final String lable;
  final Icon preIcon;
  final IconButton? sufIcon;
  final String hintext;

  bool obstype;

  CustomTextField({
    required this.lable,
    required this.preIcon,
    this.sufIcon,
    required this.hintext,
    required this.obstype,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(lable),
        SizedBox(height: 10),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          child: TextFormField(
            obscureText: obstype,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 1)),
              hintText: hintext,
              hintStyle: kHintTextStyle,
              prefixIcon: preIcon,
              suffixIcon: sufIcon,
            ),
          ),
        ),
      ],
    );
  }
}
