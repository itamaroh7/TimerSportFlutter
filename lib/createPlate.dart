import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:ui';

class popUpPlateName extends StatefulWidget {
   int numPlate;
   int numOfPlates;

   popUpPlateName({Key key, this.numPlate,@required this.numOfPlates}) : super(key: key);

  @override
  _popUpPlateNameState createState() => _popUpPlateNameState(numPlate,numOfPlates);
}

class _popUpPlateNameState extends State<popUpPlateName> {
  _popUpPlateNameState(this.numPlate,this.numOfPlates){
   //  _read();
  }
  @override
  void initState() {
    // TODO: implement initState
    _read();
    super.initState();
  }

  bool saveSuccess=true;
  int numOfPlates;
  int numPlate;
  String plateName = "";
  Duration duration = Duration(minutes: 0, seconds: 0);

  List<ExeOrRestCardc> exeOrRestCards = new List<ExeOrRestCardc>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Create Program'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.done),
              onPressed: () {
                saveSuccess=true;
                _save();
                if(saveSuccess)
                Navigator.pop(context);
              },
            )
          ],
        ),
        body: ReorderableListView(
          header: Container(
              child: Column(children: [
            TextFormField(
              onChanged: (String txt) {
                  plateName = txt;
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(20.0),
                hintText:(plateName!='')? '$plateName':'',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                      padding: EdgeInsets.all(20),
                      child: ElevatedButton(
                        child: Icon(FontAwesomeIcons.running),
                        onPressed: () {
                          setState(() {
                            exeOrRestCards.add(ExeOrRestCardc(
                                UniqueKey(), "00:00", FontAwesomeIcons.running, "", 1));
                          });
                        },
                      )),
                  ElevatedButton(
                      child: Icon(FontAwesomeIcons.bed),
                      onPressed: () {
                        setState(() {
                          exeOrRestCards.add(ExeOrRestCardc(
                              UniqueKey(), "00:00", FontAwesomeIcons.bed, "", 2));
                        });
                      })
                ])
          ])),
          children: <Widget>[
            for (final item in exeOrRestCards)
              Container(
                height: 120,
                key: ValueKey(item),
                child: Card(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(item.iconEOrR),
                      Expanded(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          new GestureDetector(
                            onTap: () {
                              showSheet(context, child: buildTimerPicker(),
                                  onClicked: () {
                                setState(() {
                                  item.time = formatDuration(duration);
                                });
                                Navigator.pop(context);
                              });
                            },
                            child: new Text(
                              "${item.time}",
                              style: TextStyle(fontSize: 45),
                            ),
                          ),
                          Container(
                              width: 150,
                              child: Theme(
                                data: Theme.of(context)
                                    .copyWith(splashColor: Colors.transparent),
                                child: TextField(controller: TextEditingController()..text=item.name,
                                  textAlign: TextAlign.center,
                                  autofocus: false,
                                  style: TextStyle(
                                      fontSize: 16.0, color: Colors.white),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.blueGrey,
                                    hintText: (item.kind==1)?'exercise':'rest',
                                    hintStyle: TextStyle(color:Colors.white) ,
                                    contentPadding: const EdgeInsets.only(
                                        left: 14.0, bottom: 8.0, top: 8.0),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.green),
                                      borderRadius: BorderRadius.circular(25.7),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red),
                                      borderRadius: BorderRadius.circular(25.7),
                                    ),
                                  ),
                                  onChanged:(val) {
                                   // setState(() {
                                      //TextEditingController()..selection = TextSelection.fromPosition(TextPosition(offset: TextEditingController().text.length));
                                      item.name = val;
                                   // });
                                  },
                                ),
                              )),
                        ],
                      )),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              exeOrRestCards.remove(item);
                            });
                          },
                          icon: Icon(Icons.delete,size: 35,))
                    ],
                  ),
                ),
              ),
          ],
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final ExeOrRestCardc card = exeOrRestCards.removeAt(oldIndex);
              exeOrRestCards.insert(newIndex, card);
            });
          },
        ));
  }

  _read() async {
    if (numPlate == -1) {
      plateName='program ${numOfPlates+1}';
      return;
    }
      final prefs = await SharedPreferences.getInstance();
      final key = "plate" + numPlate.toString();
      setState(() {
        final List<String> value = prefs.getStringList(key) ?? List<String>();
        for (int i = 0; i < value.length; i++) {
          var ls = value[i].split(',');
         // String stRest=(ls[2]=='rest')?'rest':ls[2];
          exeOrRestCards.add(
              ExeOrRestCardc(UniqueKey(), ls[1], (ls[0] == '1') ? Icons.mail_sharp
                  : Icons.mail_outline, ls[2], int.parse(ls[0])));
        }

        List<String> plateNameList = prefs.getStringList('plateCards')??List<String>();
        for (int i = 0; i < plateNameList.length; i++) {
          var ls = plateNameList[i].split(',');
          if (ls[0] == numPlate.toString()) {
            plateName=ls[1];
            break;
          }
        }
      });
    }


  _save() async {
    if(exeOrRestCards.length==0){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Program cannot be empty.'),
      ));
      saveSuccess=false;
      return;
    }
    for(final item in exeOrRestCards){
      if(item.time=='00:00'){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Time cannot be 00:00.'),
        ));
        saveSuccess=false;
        return;
      }
    }
    final prefs = await SharedPreferences.getInstance();
    setState(() {
    bool newPlate=false;
    if(numPlate==-1){
      newPlate=true;
      numPlate= numOfPlates;
      numOfPlates++;
      prefs.setInt('numOfPlates', numOfPlates);
    }

    final String key = "plate" + numPlate.toString();
    List<String> ls = new List<String>();
    for (final item in exeOrRestCards) {
      String st=item.name;
      if(item.kind==2&&(item.name==''||item.name=='rest'))
        st='rest';
      if(item.kind==1&&(item.name==''||item.name=='exercise'))
        st='exercise';
      ls.add(item.kind.toString() + "," + item.time + "," + st);
    }
    prefs.setStringList(key, ls);

    String st = numPlate.toString() + ',' + plateName + ',';
    List<String> value = prefs.getStringList('plateCards')??List<String>();
    if(!newPlate) {
      for (int i = 0; i < value.length; i++) {
        var ls = value[i].split(',');
        if (ls[0] == numPlate.toString()) {
          value[i] = st + 'true';
        }else{
          value[i]=ls[0]+','+ls[1]+','+'false';
        }
      }
    }else{
      for (int i = 0; i < value.length; i++) {
        var ls = value[i].split(',');
        value[i]=ls[0]+','+ls[1]+','+'false';
      }
      value.add(st+'true');
    }
    prefs.setStringList('plateCards', value);
    });

  }

  Widget buildTimerPicker() => SizedBox(
      height: 180,
      child: CupertinoTimerPicker(
        initialTimerDuration: duration,
        minuteInterval: 1,
        secondInterval: 1,
        mode: CupertinoTimerPickerMode.ms,
        onTimerDurationChanged: (duration) {
          setState(() {
            this.duration = duration;
          });
        },
      ));

  static void showSheet(
    BuildContext context, {
    @required Widget child,
    @required VoidCallback onClicked,
  }) =>
      showCupertinoModalPopup(
          context: context,
          builder: (context) => CupertinoActionSheet(
                actions: [
                  child,
                ],
                cancelButton: CupertinoActionSheetAction(
                  child: Text('Save'),
                  onPressed: onClicked,
                ),
              ));

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return '$minutes:$seconds';
  }


}

class ExeOrRestCardc {
  Key key;

  ExeOrRestCardc(this.key, this.time, this.iconEOrR, this.name, this.kind);

  String time;
  IconData iconEOrR;
  String name;
  int kind;
}

