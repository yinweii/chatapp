import 'package:chatapp/utils/global.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomTextField extends StatelessWidget {
  final String lable;
  final Icon preIcon;
  dynamic controller;
  final IconButton? sufIcon;
  final String hintext;
  dynamic validator;

  bool obstype;

  CustomTextField({
    required this.lable,
    required this.preIcon,
    this.sufIcon,
    required this.hintext,
    required this.obstype,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: lable,
            style: kLabelStyle,
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        SizedBox(height: 10),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          child: TextFormField(
            validator: validator,
            obscureText: obstype,
            controller: controller,
            style: TextStyle(color: Colors.lightBlue),
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
