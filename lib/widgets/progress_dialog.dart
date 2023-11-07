import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget {
  ProgressDialog({this.message});

  String? message;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black54,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(6)),
        child: Row(children: [
          SizedBox(
            width: 6,
          ),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
          SizedBox(
            width: 6,
          ),
          Text(
            message!,
            style: TextStyle(color: Colors.black, fontSize: 12),
          )
        ]),
      ),
    );
  }
}
