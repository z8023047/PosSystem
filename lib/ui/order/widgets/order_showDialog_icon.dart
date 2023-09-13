import 'package:flutter/material.dart';

class SpecialIconCard extends Card {
  
  SpecialIconCard({Key? key, required BuildContext context, required IconData icon})
      : super(
          key: key,
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Padding(
            padding: EdgeInsets.all(1),
            child: Icon(
              icon,
              color: Color.fromARGB(255, 0, 0, 0),
              size: 30,
            ),
          ),
        );
}