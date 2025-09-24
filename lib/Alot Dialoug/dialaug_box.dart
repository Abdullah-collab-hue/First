import 'package:flutter/material.dart';

class DialaugeBox extends StatefulWidget {
  const DialaugeBox({super.key});

  @override
  State<DialaugeBox> createState() => _DialaugeBoxState();
}

class _DialaugeBoxState extends State<DialaugeBox> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xff27436A),
          title: null,
          // Remove the title
          content: SingleChildScrollView(
            child:Column(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10,),
                Icon(Icons.wifi_off,color: Color(0xffFFCD43),size: 32,),
                SizedBox(height: 20,),
                Text("Wifi Disabled",style: TextStyle (fontSize: 16,fontWeight: FontWeight.w500,color: Colors.white),),
                SizedBox(height: 20,),
                Text("Please Enable the Wifi!",style: TextStyle (fontSize: 12,fontWeight: FontWeight.w400,color: Colors.white),),
                SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Container(
                    height: 41,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xff2C5FA6),
                      borderRadius: BorderRadius.circular(21),
                    ),
                    child:
                    Center(child: Text("Connect Now",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 12),)),
                  ),
                ),
                SizedBox(height: 20,),
            ],)

          )
        );

  }
}
