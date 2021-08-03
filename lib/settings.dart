import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';

class Settings extends StatefulWidget {
  List<String> language=[];
  Settings({@required this.language});

  @override
  _SettingsState createState() => _SettingsState(language);
}

class _SettingsState extends State<Settings> {
  String _filePath;
  List<String> lsRings = [];
  List<RingClass> lsRingExe = [];
  List<RingClass> lsRingRest = [];

  RingClass selectedRingClassExe, selectedRingClassRest;
  int nmSelecRingExe;
  int nmSelecRingRest;
  FlutterTts flutterTts=FlutterTts();

  String chosenLang;
  List<String> language=[];
  bool flagTts=false;


  _SettingsState(this.language);
  @override
  void initState() {
    super.initState();
    _read();
  }

  setSelectedRingExe(RingClass r) {
    setState(() {
      selectedRingClassExe = r;
    });
  }

  setSelectedRingRest(RingClass r) {
    setState(() {
      selectedRingClassRest = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SportTimer'),
        centerTitle: true,
      ),
      body: Container(
        alignment: Alignment.topRight,
        padding: EdgeInsets.only(left: 16, top: 25, right: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Settings',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                Text(
                'Alarms',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
              ),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.alarm,
                    color: Colors.cyanAccent,
                  ),

                ],
              ),
              SizedBox(
                height: 10,
              ),
              Divider(
                height: 15,
                thickness: 2,
              ),
              InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            'Alert before exercise',
                            textAlign: TextAlign.left,
                          ),
                          content: Container(
                            height: 300,
                            child: Scrollbar(
                              isAlwaysShown: true,
                              child: SingleChildScrollView(
                                child: StatefulBuilder(builder:
                                    (BuildContext context, StateSetter setState) {
                                  return Column(
                                    children: [
                                      for (final item in lsRingExe)
                                        Container(
                                          height: 50,
                                          child: RadioListTile(
                                            value: item,
                                            groupValue: selectedRingClassExe,
                                            secondary: Text(
                                              '${item.name.split('.')[0]}',
                                              style: TextStyle(fontSize: 15),
                                            ),
                                            onChanged: (currentItem) {
                                              setState(() {
                                                setSelectedRingExe(currentItem);
                                              });
                                            },
                                            selected:
                                                selectedRingClassExe == item,
                                          ),
                                        )
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ),
                          actions: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                      onPressed: () {
                                        _addRingFromExplorer();
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Add',
                                        style: TextStyle(color: Colors.blue),
                                        textAlign: TextAlign.left,
                                      )),
                                  TextButton(
                                      onPressed: () {
                                        _saveRingsSelectedExe(
                                            selectedRingClassExe.num);
                                        _readRingsSelected();
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Select',
                                        style: TextStyle(color: Colors.blue),
                                        textAlign: TextAlign.right,
                                      )),
                                ]),
                          ],
                        );
                      },
                    ).then((value) {
                      _readRingsSelected();
                    });
                  },
                  child: Container(
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Alert before exercise',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 20),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  )),
              SizedBox(
                height: 25,
              ),
              InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            'Alert before rest',
                            textAlign: TextAlign.left,
                          ),
                          content: Container(
                            height: 300,
                            child: Scrollbar(
                              isAlwaysShown: true,
                              child: SingleChildScrollView(
                                child: StatefulBuilder(builder:
                                    (BuildContext context, StateSetter setState) {
                                  return Column(
                                    children: [
                                      for (final item in lsRingRest)
                                        Container(
                                          height: 50,
                                          child: RadioListTile(
                                            value: item,
                                            groupValue: selectedRingClassRest,
                                            secondary: Text(
                                              '${item.name.split('.')[0]}',
                                              style: TextStyle(fontSize: 15),
                                            ),
                                            onChanged: (currentItem) {
                                              setState(() {
                                                setSelectedRingRest(currentItem);
                                              });
                                            },
                                            selected:
                                                selectedRingClassRest == item,
                                          ),
                                        )
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ),
                          actions: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                      onPressed: () {
                                        _addRingFromExplorer();
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Add',
                                        style: TextStyle(color: Colors.blue),
                                        textAlign: TextAlign.left,
                                      )),
                                  TextButton(
                                      onPressed: () {
                                        _saveRingsSelectedRest(
                                            selectedRingClassRest.num);
                                        _readRingsSelected();
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        'Select',
                                        style: TextStyle(color: Colors.blue),
                                        textAlign: TextAlign.right,
                                      )),
                                ]),
                          ],
                        );
                      },
                    ).then((value) {
                      _readRingsSelected();
                    });
                  },
                  child: Container(
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Alert before rest',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 20),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  )),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Text to speech',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.auto_awesome_motion,
                    color: Colors.cyanAccent,
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Divider(
                height: 15,
                thickness: 2,
              ),SwitchListTile(
              value: flagTts,
                onChanged: (val){
                  setState(() {
                    flagTts=val;
                    _saveFlagTts(val);
                  });
                },
                title: Text('Supported language',style: TextStyle(fontSize: 19,),),
      ),

              Container(
                height: 100,
                child:Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: EdgeInsets.only(left: 16,right: 16),
                        child: DropdownButton(
                          hint: Text('שפה נתמכת'),
                          dropdownColor: Colors.white,
                          elevation: 5,
                          icon: Icon(Icons.arrow_drop_down),
                          isExpanded: true,
                          itemHeight: 60,
                          isDense:false,
                          iconSize: 26,
                          underline: SizedBox(),
                          value: chosenLang,
                          onChanged:flagTts? (val){
                            setState(() {
                              _saveLanguageTts(val);
                              chosenLang=val;
                            });
                          }:null,
                          items: language.map((val){
                              return DropdownMenuItem(
                                  child:Text(val),
                                value: val,
                              );
                        }).toList(),
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  _saveRingsSelectedExe(int num) async {
    final prefs=await SharedPreferences.getInstance();
    setState(() async {
     // final prefs = await SharedPreferences.getInstance();
      prefs.setInt('RingExe', num);
    });
  }

  _saveRingsSelectedRest(int num) async {
    setState(() async {
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt('RingRest', num);
    });
  }

  _saveRingsUserAdd(String newRingPath) async {
    lsRings.add(newRingPath);
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('RingsList', lsRings);
  }

  _saveLanguageTts(String chosenLang)async{
    final prefs=await SharedPreferences.getInstance();
    prefs.setString('chosenLang', chosenLang);
  }

  _readRingsSelected() async {
    setState(() async {
      final prefs=await SharedPreferences.getInstance();
      nmSelecRingExe = prefs.getInt('RingExe') ?? 0;
      nmSelecRingRest = prefs.getInt('RingRest') ?? 1;
      for (final item in lsRingExe) {
        if (item.num == nmSelecRingExe) selectedRingClassExe = item;
      }
      for (final item in lsRingRest) {
        if (item.num == nmSelecRingRest) selectedRingClassRest = item;
      }
    });
  }

  _read() async {
    final prefs = await SharedPreferences.getInstance();
    lsRings = [];
    lsRingExe = [];
    lsRingRest = [];
    lsRings = prefs.getStringList('RingsList');
    if (lsRings == null) {
      lsRings = [
        'ring 1.mp3',
        'ring 2.mp3',
        'ring 3.mp3',
      ];
    }
    for (int i = 0; i < lsRings.length; i++) {
      var st=lsRings[i].split('/');
      lsRingRest.add(RingClass(st[st.length-1], i, 2));
      lsRingExe.add(RingClass(st[st.length-1], i, 1));
    }
    chosenLang=prefs.getString('chosenLang')??'en-US';
    setState(() {
      flagTts=prefs.getBool('flagTts')??false;
    });
    _readRingsSelected();
  }

  _addRingFromExplorer() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      _filePath = file.path;
      _saveRingsUserAdd(_filePath);
      _read();
    } else {
      // User canceled the picker
    }
  }

  _saveFlagTts(bool flag) async{
    final prefs=await SharedPreferences.getInstance();
      prefs.setBool("flagTts", flag);
  }
}

class RingClass {
  String name;
  int num;
  int kind;

  RingClass(this.name, this.num, this.kind);
}
