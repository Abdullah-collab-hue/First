import 'package:flutter/material.dart';
class WifiInfo extends StatefulWidget {
  const WifiInfo({super.key});

  @override
  State<WifiInfo> createState() => _WifiInfoState();
}

class _WifiInfoState extends State<WifiInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff0D1622),
      appBar: AppBar(
        backgroundColor: Color(0xff1A293E),
        title: Text("WiFi info", style: TextStyle(color: Color(0xffF7F7F7)),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 28,),
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xff1A293E),
                  radius: 14,
                  child: Icon(Icons.wifi,color: Color(0xff5178AE),),
                  
                ),
                SizedBox(width: 15,),
                Text("New Heaven",
                  style: TextStyle(color: Color(0xffF7F7F7),fontSize: 14,fontWeight: FontWeight.w500),),
              ],
            ),
            SizedBox(height: 10,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Container(
                width: double.infinity,
                height: 187,
                decoration: BoxDecoration(
                  borderRadius:BorderRadius.circular(7),
                  border: Border.all(color: Color(0xff27436A)),
            
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Mac:",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 12,color: Colors.white),),
                          Text("08:47d0:b1:b5:48",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 12,color: Colors.white),),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Security:",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 12,color: Colors.white),),
                          Text("WPA/WPA2 PSK:",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 12,color: Colors.white),),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Signal Strength",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 12,color: Colors.white),),
                          Text("-42",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 12,color: Colors.white),),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Channel",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 12,color: Colors.white),),
                          Text("0",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 12,color: Colors.white),),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Frequency",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 12,color: Colors.white),),
                          Text("2447",style: TextStyle(fontWeight: FontWeight.w400,fontSize: 12,color: Colors.white),),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 25,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: InkWell(onTap: (){},
                child: Container(
                  width: double.infinity,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Color(0xff27436A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(child: Text("Connect Now",style: TextStyle(color: Colors.white,fontSize: 12,fontWeight: FontWeight.w500),)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
