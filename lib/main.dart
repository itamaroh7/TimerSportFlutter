import 'dart:async';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/ProgramPlate.dart';
import 'package:flutter/cupertino.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_app/settings.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:after_layout/after_layout.dart';

void main() {
  runApp(new MaterialApp(
    home: new mainApp(),
  ));
}

class mainApp extends StatefulWidget {
  @override
  _mainAppState createState() => _mainAppState();
}

class _mainAppState extends State<mainApp> with AfterLayoutMixin<mainApp>{
  @override
  initState() {
    _initSharedPrefences().then((value)async{
      await _initialTimer();
    });
    super.initState();
    ctrl = FixedExtentScrollController();
    audioCache = AudioCache(fixedPlayer: audioPlayer);
    audioPlayer.onPlayerStateChanged.listen((PlayerState s) {
      setState(() {
        audioPlayerState = s;
      });
    });
  }

  @override
  void afterFirstLayout(BuildContext context)async {

  }

  Future _initSharedPrefences()async{
    prefs=await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer.release();
    audioPlayer.dispose();
    audioCache.clearAll();
  }

  IconData startOrStop = Icons.play_circle_filled;
  bool visibleRefresh = false;
  bool visibleAlarm = false;
  bool alarmOn = false;
  int chosenPlate;
  FixedExtentScrollController ctrl;

  Timer timerAlarmBefore;
  Timer timer;
  bool btnStartPressed = false;

  List<int> timeCounters = [];
  List<int> timerCountersToInitilalize = [];
  int indexOfExeOrRest = 0;
  List<PickerExeOrRest> pickerExeOrRest = [];

  bool disableCuperPick = false;
  double opacityCupertino = 0.9;

  AudioPlayer audioPlayer = AudioPlayer();
  PlayerState audioPlayerState = PlayerState.PAUSED;
  AudioCache audioCache;
  String pathAssetsExe = "ring 3.mp3";
  String pathAssetsRest = "ring 1.mp3";
  String pathAssetsTone = "ring 3.mp3";
  bool blBefExe = false;
 SharedPreferences prefs;
  FlutterTts flutterTts = FlutterTts();
  String chosenLang;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          leading: IconButton(
            onPressed: () async {
              List<dynamic> language1 = new List<dynamic>();
              language1 = await flutterTts.getLanguages;
              List<String> language = language1.cast<String>().toList();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Settings(
                            language: language,
                          ))).then((value) {
                setState(() {
                  _initialTimer();
                });
              });
            },
            icon: Icon(Icons.settings),
            alignment: Alignment.centerLeft,
          ),
          title: new Text('SportTimer'),
          centerTitle: true,
          actions: <Widget>[
            new IconButton(
                icon: new Icon(Icons.edit),
                padding: new EdgeInsets.fromLTRB(0, 5, 40.0, 5),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => programPlate())).then((value) {
                    setState(() {
                      _initialTimer();
                    });
                  });
                }),
          ],
        ),
        body: new Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              Text(
                '${_printDuration((timeCounters.length > 0) ? timeCounters[indexOfExeOrRest] : 10)}',
                style: TextStyle(fontSize: 100),
              ),
              ButtonTheme(
                  minWidth: 200.0,
                  height: 100.0,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                            padding: EdgeInsets.only(right: 50, left: 20),
                            child: Visibility(
                              visible: visibleAlarm,
                              maintainSize: true,
                              maintainAnimation: true,
                              maintainState: true,
                              child: IconButton(
                                onPressed:
                                    audioPlayerState == PlayerState.PLAYING
                                        ? () {
                                            setState(() {
                                              audioPlayer.stop();
                                              if (timerAlarmBefore.isActive)
                                                timerAlarmBefore.cancel();
                                              blBefExe = false;
                                              visibleAlarm = false;
                                            });
                                          }
                                        : null,
                                icon: Icon(Icons.alarm_off),
                                iconSize: 40,
                              ),
                            )),
                        IconButton(
                          onPressed: (btnStartPressed)
                              ? () {
                                  pauseTimer();
                                }
                              : () {
                                  startTimer();
                                },
                          icon: Icon(startOrStop),
                          iconSize: 130,
                          color: Colors.cyan,
                        ),
                        Visibility(
                          visible: visibleRefresh,
                          child: IconButton(
                            onPressed: () {
                              refreshTimer();
                            },
                            icon: Icon(Icons.refresh),
                            iconSize: 50,
                          ),
                        ),
                      ])),
              AbsorbPointer(
                  absorbing: disableCuperPick,
                  child:buildChosenExeOrRestPicker()),
            ])));
  }

  List<Widget> modelBuilder<M>(
          List<M> models, Widget Function(int index, M model) builder) =>
      models
          .asMap()
          .map<int, Widget>(
              (index, model) => MapEntry(index, builder(index, model)))
          .values
          .toList();

  Widget buildChosenExeOrRestPicker() => SizedBox(
        height: 170,
        child: CupertinoPicker(
          scrollController: ctrl,
          magnification: 1.3,
          useMagnifier: true,
          itemExtent: 45,
          diameterRatio: 1.1,
          looping: false,
          onSelectedItemChanged: (index) {
            setState(() {
              this.indexOfExeOrRest = index;
              if (timeCounters[indexOfExeOrRest] ==
                  timerCountersToInitilalize[indexOfExeOrRest]) {
                visibleRefresh = false;
              } else {
                visibleRefresh = true;
              }
            });
          },
          selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
            background: (pickerExeOrRest.length > 0)
                ? Colors.cyanAccent.withOpacity(0.12)
                : Colors.transparent,
          ),
          children: modelBuilder<PickerExeOrRest>(
            pickerExeOrRest,
            (index, value) {
              final isSelected = this.indexOfExeOrRest == index;
              final color = isSelected ? Colors.pink : Colors.black;

              return Center(
                child: Text(
                  '${value.time + ', ' + value.name}',
                  style: TextStyle(
                      color: color.withOpacity(opacityCupertino), fontSize: 24),
                ),
              );
            },
          ),
        ),
      );

  int timeAlaramPlaying = 6;

  _playMusicAlarmBefore(int mode) {
    if (timeCounters[indexOfExeOrRest] < 6)
      timeAlaramPlaying = 6 - timeCounters[indexOfExeOrRest];
    if (pathAssetsTone.split('/').length > 1)
      audioPlayer.play(pathAssetsTone, isLocal: true);
    else
      audioCache.play(pathAssetsTone);
    timerAlarmBefore = Timer.periodic(Duration(seconds: 1), (timer1) {
      setState(() {
        if (timeAlaramPlaying > 0) {
          timeAlaramPlaying--;
        } else {
          timeAlaramPlaying = 6;
          if (mode == 1) blBefExe = false;
          audioPlayer.stop();
          timerAlarmBefore.cancel();
          visibleAlarm = false;
        }
      });
    });
  }

  _initTimerCountersAtIndexAndPickerER() {
    timeCounters[indexOfExeOrRest] =
        timerCountersToInitilalize[indexOfExeOrRest];
    pickerExeOrRest[indexOfExeOrRest].time =
        _printDuration(timeCounters[indexOfExeOrRest]);
  }

  _disableCupertino() {
    disableCuperPick = true;
    opacityCupertino = 0.5;
  }

  _enableCupertino() {
    disableCuperPick = false;
    opacityCupertino = 0.9;
  }

  refreshTimer() {
    setState(() {
      _initTimerCountersAtIndexAndPickerER();
      visibleRefresh = false;
    });
  }

  pauseTimer() {
    setState(() {
      timer.cancel();
      btnStartPressed = false;
      visibleRefresh = true;
      startOrStop = Icons.play_circle_fill;
      _enableCupertino();
    });
  }

  Future _speakTts(String text) async {
    if (text.isEmpty) return;
    await flutterTts.setLanguage(chosenLang);
    await flutterTts.setPitch(1);
    await flutterTts.speak(text);
  }

  _updateRingsPath() async {
    final prefs = await SharedPreferences.getInstance();
    var lsRings = prefs.getStringList('RingsList');
    try {
      pathAssetsExe = lsRings[prefs.getInt('RingExe') ?? 0];
      pathAssetsRest = lsRings[prefs.getInt('RingRest') ?? 1];
    } catch (e) {
      pathAssetsExe = "ring 3.mp3";
      pathAssetsRest = "ring 1.mp3";
    }
  }

  void startTimer() async {
    blBefExe = false;
    timer = Timer.periodic(Duration(seconds: 1), (timer1) {
      setState(() {
        if (!blBefExe) {
          if (timeCounters[indexOfExeOrRest] > 0) {
            startOrStop = Icons.pause_circle_filled;
            btnStartPressed = true;
            timeCounters[indexOfExeOrRest]--;
            pickerExeOrRest[indexOfExeOrRest].time =
                _printDuration(timeCounters[indexOfExeOrRest]);
            _disableCupertino();
          } else {
            if (indexOfExeOrRest == pickerExeOrRest.length - 1) {
              indexOfExeOrRest = 0;
              timeCounters = []..addAll(timerCountersToInitilalize);
              pickerExeOrRest[pickerExeOrRest.length - 1].time =
                  _printDuration(timeCounters[pickerExeOrRest.length - 1]);
            } else {
              _initTimerCountersAtIndexAndPickerER();
              indexOfExeOrRest++;
            }
            ctrl.jumpToItem(indexOfExeOrRest);

            visibleAlarm = true;
            if (pickerExeOrRest[indexOfExeOrRest].kind == 1) {
              pathAssetsTone = pathAssetsExe;
              blBefExe = true;
              _playMusicAlarmBefore(1);
            } else {
              pathAssetsTone = pathAssetsRest;
              _playMusicAlarmBefore(2);
            }
            _speakTts(pickerExeOrRest[indexOfExeOrRest].name);
          }
        } else {}
      });
    });
  }

  String _printDuration(int num) {
    var now = Duration(seconds: num);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(now.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(now.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  int _convertTimeToSeconds(String time) {
    var min = time.substring(0, 2);
    var sec = time.substring(3, 5);
    return int.parse(min) * 60 + int.parse(sec);
  }

  Future _initialTimer() async {
    int numOfPlates = prefs.getInt('numOfPlates') ?? 0;
    if (numOfPlates == 0) {
      await Navigator.push(
              context, MaterialPageRoute(builder: (context) => programPlate()))
          .then((value) => {});
    }

    timeCounters = [];
    pickerExeOrRest = [];
    timerCountersToInitilalize = [];
    audioCache = AudioCache(fixedPlayer: audioPlayer);

    chosenPlate = int.parse(prefs.getString('chosenPlate'));
    if (chosenPlate == -1) return null;
    var value = prefs.getStringList('plate' + chosenPlate.toString());
    setState(() {
      for (int i = 0; i < value.length; i++) {
        var ls = value[i].split(',');
        timeCounters.add(_convertTimeToSeconds(ls[1]));
          pickerExeOrRest.add(PickerExeOrRest(name:ls[2],time: ls[1],kind: int.parse(ls[0])));
      }
    });

    timerCountersToInitilalize = []..addAll(timeCounters);
    chosenLang = prefs.getString('chosenLang') ?? 'en-US';
    _updateRingsPath();

  }
}

class PickerExeOrRest {
  String name;
  String time;
  int kind;

  PickerExeOrRest({this.name, this.time, this.kind});

}


