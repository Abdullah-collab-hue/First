import 'package:flutter/material.dart';
class Notificationss extends StatefulWidget {
  const Notificationss({super.key});

  @override
  State<Notificationss> createState() => _NotificationssState();
}

class _NotificationssState extends State<Notificationss> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff0D1622),
      appBar: AppBar(
        title: Text("Notifications",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w500,fontSize: 14),),
        centerTitle: true,
        backgroundColor: Color(0xff1A293E),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 28),
          child: Container(
            height: 311,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xff1A293E),
              borderRadius: BorderRadius.circular(16)
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                  child: Text("Lorem ipsum dolor sit amet, consect adipising elit, sed do eiusmod",
                    style: TextStyle(color: Colors.white,fontSize: 14,fontWeight: FontWeight.w500),),
                ),
                Image.asset("asset/images/imge.png",fit: BoxFit.fitHeight,height: 165,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                  child: Text("Lorem ipsum dolor sit amet, consecteturipiscing elit, sed do eiusmod tempor incid unt ut labore et dolore magna aliqua",
                    style: TextStyle(color: Colors.white,fontSize: 12,fontWeight: FontWeight.w400),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

