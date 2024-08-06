import 'package:active_flutter_delivery_app/custom/lang_text.dart';
import 'package:flutter/material.dart';
import 'package:active_flutter_delivery_app/my_theme.dart';

class Offline extends StatefulWidget {
  @override
  _OfflineState createState() => _OfflineState();
}

class _OfflineState extends State<Offline> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.splash_login_screen_color,
      body: buildBody(context),
    );

  }

  buildBody(context){
    final _screen_width = MediaQuery.of(context).size.width * (3/4);
    return Stack(children: [
      Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: _screen_width,
          child:Image.asset("assets/splash_login_background_logo.png",color: Color.fromRGBO(225,225,225, .1),),
        ),

      ),
      Container(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(padding: const EdgeInsets.only(top: 40,),
                 child: Container(width:75,child: Image.asset("assets/delivery_app_logo.png")),
              ),
              Padding(padding: const EdgeInsets.only(top: 80,),
                child: Container(width:120,child: Image.asset("assets/offline_cloud.png")),
              ),
              Padding(padding: const EdgeInsets.only(top: 40,),
                child: Text(LangText(context).local!.your_app_is_now,style: TextStyle(fontSize: 22,color:Colors.white ),),
              ),
              Padding(padding: const EdgeInsets.only(top: 10,),
                child: Text(LangText(context).local!.offline_ucf,style: TextStyle(fontSize: 28,color:Colors.white,fontWeight: FontWeight.w600 ),),
              ),
              Padding(padding: const EdgeInsets.only(top: 10,),
                child: Text(LangText(context).local!.you_are_currently_offline,style: TextStyle(fontSize: 14,color:Colors.cyanAccent ),),
              ),
              Padding(padding: const EdgeInsets.only(top: 0,),
                child: Text(LangText(context).local!.please_turn_on_your_internet_connection,style: TextStyle(fontSize: 14,color:Colors.cyanAccent ),),
              ),

            ],
          ),
        ),
      )

    ],);
  }
}
