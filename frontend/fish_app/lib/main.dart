//import 'dart:html';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:pubnub/pubnub.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final pubnub = PubNub(//PubNub Connect
    defaultKeyset: Keyset(
        subscribeKey: 'sub-c-97a08f8e-2899-11eb-862a-82af91a3b28d',
        publishKey: 'pub-c-bfdbe3c0-b733-4969-93d2-57e89cd78fb2',
        uuid: UUID('Client-u1ddb')
    )
);
var myChannel = pubnub.channel('Channel-m957c9mdt');

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fish Hub',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Fish Hub'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool pressed = true;
  bool pressedFeed = false;
  String flag = '';
  String last = '';
  String m = '';
  String finalMessage = '';
  String ledMessage = '';
  String finalLedMessage = 'LedOff';
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: Text(widget.title,
          style: GoogleFonts.pacifico(
            fontSize: 40
          ),
        ),
        flexibleSpace: Image(
          image: AssetImage("images/fishTop.png"),
          fit: BoxFit.cover
        ),
      ),
      body:Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("images/fish.jpg"),
              fit: BoxFit.cover
          ),
        ),
        child: Column(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        children: [
          Padding(
            padding: EdgeInsets.all(15),
          ),
          Row(

            children:<Widget>[
              Padding(
                padding: EdgeInsets.all(8),
              ),

             ButtonTheme(
               height: 80,
               minWidth: 140,
               buttonColor: Colors.blueAccent,
               splashColor: Colors.yellow[300],
               shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(30.0)),

               child:
               RaisedButton.icon(
                 icon: Icon(Icons.waves_rounded, color:Colors.white, size: 35,),
                 label: Text('Feed', style: TextStyle(fontSize: 30, color: Colors.white)),

                 onPressed: () async{

                   var subscription = await pubnub.subscribe(channels: {'Channel-m957c9mdt'});
                   subscription.messages.listen((envelope) {
                     //m = "${envelope.payload}";
                     if(envelope.payload["requester"] == "pi"){
                       finalMessage = envelope.payload["message"];
                       print(finalMessage);
                     }
                     setState(() {
                       pressedFeed = !pressedFeed;
                       if(pressedFeed){
                         last = finalMessage;
                       }
                       else{
                         last = finalMessage;
                       }
                     });
                   });
                   pubnub.publish('Channel-m957c9mdt' , {"requester":"App",'message':'feed'});
                 },
               ),
             ),
              Padding(
                padding: EdgeInsets.all(8),
              ),

              Container(
                height: 80,
                width: 210,
                decoration: new BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.grey,
                ),

                child: Text(
                    last,
                    style: TextStyle(fontSize: 23, color: Colors.deepPurple),
                    textAlign: TextAlign.center)
              )
            ],

          ),
          Padding(
            padding: EdgeInsets.all(8),

          ),
          Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8),
              ),

              ButtonTheme(
                height: 80,
                minWidth: 140,
                //buttonColor: Colors.green,
                splashColor: Colors.yellow[300],
                shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),

                child:
                RaisedButton.icon(
                  icon: Icon(Icons.lightbulb, color:Colors.white, size: 35,),
                  label: Text('Light', style: TextStyle(fontSize: 30, color: Colors.white)),
                  color: pressed ? Colors.grey : Colors.green,
                  onPressed: ()async{

                    var subscription = await pubnub.subscribe(channels: {'Channel-m957c9mdt'});
                     subscription.messages.listen((envelope) {
                       //ledMessage = "${envelope.payload}";
                       if(envelope.payload["requester"] == "ledpi"){
                         finalLedMessage = envelope.payload["message"];
                         print(finalLedMessage);
                       }
                     });

                    setState(() {
                      pressed = !pressed;
                    });
                    setState(() {
                      if (pressed){
                        pubnub.publish('Channel-m957c9mdt' , {"requester":"LedOff",'message':'off'});
                      }
                      else if(!pressed){
                        pubnub.publish('Channel-m957c9mdt' , {"requester":"LedOn",'message':'on'});
                      }
                    });
                  },
                ),

              ),
              Padding(
                padding: EdgeInsets.all(8),

              ),

              Container(
                  height: 80,
                  width: 210,

                  decoration: new BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.grey,

                  ),

                  child: Icon(Icons.lightbulb,

                    color:
                    pressed ? Colors.white : Colors.yellow, size: 85,),

              )

            ],
          )
        ],
      ),
      ),
    );
  }
}
