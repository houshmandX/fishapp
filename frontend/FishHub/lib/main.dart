//import 'dart:html';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:pubnub/pubnub.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:number_inc_dec/number_inc_dec.dart';

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
  int light = 1;
  String flag = '';
  String last = '';
  String m = '';
  String finalMessage = '';
  String ledMessage = '';
  String finalLedMessage = 'LedOff';
  double tempC = 0.0;
  double tempF = 0.0;
  double celsius = 0.0;
  double fahrenheit = 0.0;

  _MyHomePageState(){
    var oneMin = const Duration(seconds: 60);
    Timer.periodic(oneMin, (Timer timer) async {

      var subscription = await pubnub.subscribe(channels: {'Channel-m957c9mdt'});
      subscription.messages.listen((envelope) {
        //m = "${envelope.payload}";
        if(envelope.payload["requester"] == "tempi"){
          celsius = (envelope.payload["message"]);
          print(envelope.payload["message"]);
          fahrenheit = ((envelope.payload["message"]) * 9/5) + 32;
          print(fahrenheit);
        }
        setState(() {
          pressedFeed = !pressedFeed;
          if(pressedFeed){
            tempC = double.parse((celsius).toStringAsFixed(1));
            tempF = double.parse((fahrenheit).toStringAsFixed(1));
          }
          else{
            tempC = double.parse((celsius).toStringAsFixed(1));
            tempF = double.parse((fahrenheit).toStringAsFixed(1));
          }
        });
      });
      pubnub.publish('Channel-m957c9mdt' , {"requester":"Apptemp",'message':'temp'});

    });
  }

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
                  color: Colors.grey[600],
                ),

                child: Text(
                    last,
                    style: TextStyle(fontSize: 23, color: Colors.white70, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center)
              )
            ],

          ),
          SizedBox(   //Use of SizedBox
            height: 10,
          ),
          Row(
              children:<Widget>[
                SizedBox(   //Use of SizedBox
                  height: 15,
                  width: 95,
                ),
                Container(
                    height: 30,
                    width: 197,
                    decoration: new BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.grey[600]
                    ),
                    child:Center(
                    child:Text(
                        "PWM",
                        style: TextStyle(fontSize: 19, color: Colors.white, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center)
                    )
                ),
              ]
          ),
          SizedBox(   //Use of SizedBox
            height: 1,
          ),
          Row(
              children:<Widget>[
                SizedBox(   //Use of SizedBox
                  height: 20,
                  width: 95,
                ),
                Container(
                  height: 110,
                  width: 248,
                  decoration: new BoxDecoration(
                    //color: Colors.orange,
                  ),
                  child:
                  PWM(),
                )
              ]
          ),
          Padding(
            padding: EdgeInsets.all(0.2),
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
                  color: pressed ? Colors.grey[600] : Colors.green,
                  onPressed: ()async{

                    var subscription = await pubnub.subscribe(channels: {'Channel-m957c9mdt'});
                     subscription.messages.listen((envelope) {
                       //ledMessage = "${envelope.payload}";
                       if(envelope.payload["requester"] == "ledpi"){
                         finalLedMessage = envelope.payload["message"];
                         setState(() {
                         if(finalLedMessage == "LedOff"){light = 1;}
                         else if(finalLedMessage == "LedOn"){light = 0;}
                         });
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
                    color: Colors.grey[600],

                  ),

                  child: Icon(Icons.lightbulb,

                    color:
                    light == 1 ? Colors.white : Colors.yellow, size: 85),

              )

            ],
          ),

          Padding(
            padding: EdgeInsets.all(8),

          ),

          Padding(
            padding: EdgeInsets.all(8),

          ),
          Row(

            children:<Widget>[
              Padding(
                padding: EdgeInsets.all(8),
              ),

              ButtonTheme(
                height: 80,
                minWidth: 140,
                buttonColor: Colors.orange[600],
                splashColor: Colors.yellow[300],
                shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(30.0)),

                child:
                RaisedButton.icon(
                  icon: Icon(Icons.thermostat_outlined, color:Colors.white, size: 35,),
                  label: Text('Temp', style: TextStyle(fontSize: 30, color: Colors.white)),

                  onPressed: () async{

                    var subscription = await pubnub.subscribe(channels: {'Channel-m957c9mdt'});
                    subscription.messages.listen((envelope) {
                      //m = "${envelope.payload}";
                      if(envelope.payload["requester"] == "tempi"){
                        celsius = (envelope.payload["message"]);
                        print(envelope.payload["message"]);
                        fahrenheit = ((envelope.payload["message"]) * 9/5) + 32;
                        print(fahrenheit);
                      }
                      setState(() {
                        pressedFeed = !pressedFeed;
                        if(pressedFeed){
                          tempC = double.parse((celsius).toStringAsFixed(1));
                          tempF = double.parse((fahrenheit).toStringAsFixed(1));
                        }
                        else{
                          tempC = double.parse((celsius).toStringAsFixed(1));
                          tempF = double.parse((fahrenheit).toStringAsFixed(1));
                        }
                      });
                    });
                    pubnub.publish('Channel-m957c9mdt' , {"requester":"Apptemp",'message':'temp'});
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
                    color: Colors.grey[600],
                  ),

                child: Center(

                  child: Text(
                      tempC.toString() + "\u2103" + "\n" + tempF.toString() + "\u2109",
                      style: TextStyle(fontSize: 28,fontWeight: FontWeight.bold,
                          color:
                          (tempC >= 24.00)&&(tempF <= 80.00) ? Colors.white70 : Colors.red),
                      textAlign: TextAlign.center)
                )
              )
            ],
          ),

        ],
      ),
      ),
    );
  }
}
class PWM extends StatelessWidget {
  const PWM({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NumberInputWithIncrementDecrement(
      controller: TextEditingController(),
      onIncrement: (num newlyIncrementedValue) {
        double pwm = double.parse((newlyIncrementedValue).toStringAsFixed(2));
        //print('Newly incremented value is $newlyIncrementedValue');
        pubnub.publish('Channel-m957c9mdt' , {"requester":"PWM",'message':pwm});
        print(pwm);
      },
      onDecrement: (num newlyDecrementedValue) {
        double pwm = double.parse((newlyDecrementedValue).toStringAsFixed(2));
        pubnub.publish('Channel-m957c9mdt' , {"requester":"PWM",'message':pwm});
        print(pwm);
        //print('Newly decremented value is $newlyDecrementedValue');
      },
      numberFieldDecoration: InputDecoration(
        border: InputBorder.none,
      ),
      isInt: false,
      initialValue: 0.5,
      incDecFactor: 0.050,
      min: 0.1,
      max: 0.9,
      scaleWidth: .80,
      scaleHeight: 0.75,
      incDecBgColor: Colors.orange,
      style: TextStyle(fontSize: 70,fontWeight: FontWeight.bold, color: Colors.white70),
      widgetContainerDecoration: BoxDecoration(
          color: Colors.grey[600],
        borderRadius: BorderRadius.all(
          Radius.circular(15)
        ),
        border: Border.all(
          width: 0,
          color: Colors.grey[600]
        ),
      ),
        incIconDecoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(10),
          ),
        ),
      separateIcons: true,
      decIconDecoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
        ),
      ),
      incIconSize: 48,
      decIconSize: 48,
      //incIcon: Icons.plus_one,
      //decIcon: Icons.exposure_neg_1,
    );

  }
}