import"package:flutter/material.dart";

import "../bottom_navigationBar/bottom_navigation.dart";
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff0D1622),
      body:Column(
        children: [
          SizedBox(height: 263,),
          Center(
            child: Container(
              width: 117,height: 117,
              decoration: BoxDecoration(
                color: Color(0xff27436A),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          SizedBox(height: 26,),

          Text("WiFi Analyzer",style: TextStyle(

            color: Color(0xffF7F7F7),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),),
          SizedBox(height: 236,),
          Center(
            child: InkWell(onTap: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> BottomNavigationBarExample()));
            },
              child: Container(
                width: 134,height: 40,
                decoration: BoxDecoration(
                    color: Color(0xff27436A),
                    borderRadius: BorderRadius.circular(20)
                ),
                child: Center(
                  child: Text("Lets Start",style: TextStyle(
                      color: Color(0xffF7F7F7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500
                  ),),
                ),
              ),
            ),
          )

        ],
      ),
    );
  }
}

