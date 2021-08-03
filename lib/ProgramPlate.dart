import 'package:flutter/material.dart';
import 'package:flutter_app/createPlate.dart';
import 'package:shared_preferences/shared_preferences.dart';



class programPlate extends StatefulWidget {
  @override
  _programPlateState createState() => _programPlateState();
}

class _programPlateState extends State<programPlate> {
  List<PlateCard> lsPlates = new List<PlateCard>();
  int numsOfPlates;
  int groupVal=1;
  String kSpPlateCards='plateCards';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _read();
    });
  }

  PlateCard selectedPlate;
  setSelectedPlate(PlateCard plateCard){
    setState(() {
      selectedPlate=plateCard;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.timer),
            onPressed: () {
              // _save();
              Navigator.pop(context);
              //Navigator.push(context,MaterialPageRoute(builder: (context)=>mainApp()));
            },
          ),
          title: Text('Programs'),
          centerTitle: true,
        ),
        body: new Container(
            child: SingleChildScrollView(
          child: new Column(
            children: <Widget>[
              for (final item in lsPlates)
                Container(alignment: Alignment.center,
                  height: 120,
                  child: RadioListTile(
                    value:item,
                      groupValue:selectedPlate,
                     title: GestureDetector(
                          onTap: () async {
                            Navigator.of(context)
                                .push(MaterialPageRoute(
                                    builder: (context) => popUpPlateName(
                                          numPlate: item.numPlate,
                                          numOfPlates: numsOfPlates,
                                        )))
                                .then((value) {
                              setState(() {
                                initState();
                              });
                            });
                          },
                          child: Text(
                            '${item.name}',
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,),
                        ),
                        secondary:IconButton(
                            onPressed: () {
                              setState(() {
                                String valToDel = item.numPlate.toString() +
                                    "," +
                                    item.name +
                                    "," +
                                    item.operate.toString();
                                _deletePlate(valToDel);
                                lsPlates.remove(item);
                              });
                            },
                            icon: Icon(Icons.delete)),
                    onChanged: (currentItem){
                      setState(() {
                        lsPlates.forEach((element) {
                          element.operate = false;
                        });
                        item.operate = true;
                        _chosenPlateChkBox(item.numPlate);
                      });
                      setSelectedPlate(currentItem);
                    },
                    selected: selectedPlate==item,
                      )),

            ],
          ),
        )),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () async {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (context) => popUpPlateName(
                            numPlate: -1,
                            numOfPlates: numsOfPlates,
                          )))
                  .then((value) {
                setState(() {
                  _read();
                 // initState();
                });
              });
            }));
  }

  _updateChosenPlate(){
    for(final item in lsPlates){
      if(item.operate)
        selectedPlate=item;
    }
    _saveChosenPlate();
  }

  _chosenPlateChkBox(int _numPlate)async{
    final prefs = await SharedPreferences.getInstance();
    var value=prefs.getStringList(kSpPlateCards);
    for(int i=0;i<numsOfPlates;i++){
      var lsVal=value[i].split(',');
      value[i]=lsVal[0]+','+lsVal[1]+','+'false';

    }
    var lsVal=value[_numPlate].split(',');
    value[_numPlate]=lsVal[0]+','+lsVal[1]+','+'true';
    prefs.setStringList(kSpPlateCards, value);

    _saveChosenPlate();
  }

  _deletePlate(String valToDel) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> value = prefs.getStringList(kSpPlateCards) ?? List<String>();
    int index = value.indexOf(valToDel);


    if(index==numsOfPlates-1&&numsOfPlates>1){
      var lsVal=value[0].split(',');
      value[0]=lsVal[0]+','+lsVal[1]+','+'true';
    }else if(numsOfPlates>1){
      var lsVal=value[index+1].split(',');
      value[index+1]=lsVal[0]+','+lsVal[1]+','+'true';
    }

    value.remove(valToDel);
    for (int i = 0; i < value.length; i++) {
      var ls = value[i].split(',');
      value[i] = i.toString() + ',' + ls[1] + ',' + ls[2];
    }
    prefs.setStringList(kSpPlateCards, value);
    numsOfPlates--;
    prefs.setInt('numOfPlates', numsOfPlates);
    lsPlates = new List<PlateCard>();
    for (int i = 0; i < value.length; i++) {
      var ls = value[i].split(',');
      lsPlates.add(PlateCard(int.parse(ls[0]), ls[1], ls[2] == 'true'));
    }

    for (int i = 0; i <= value.length; i++) {
      if (i > index) {
        var tmp = prefs.getStringList('plate' + (index).toString());
        prefs.setStringList('plate' + (index).toString(),
            prefs.getStringList('plate' + i.toString()));
        prefs.setStringList('plate' + i.toString(), tmp);
        index++;
      }
    }
    prefs.remove('plate' + (value.length).toString());
    _updateChosenPlate();
  }

  Future<Null>_read() async {
    lsPlates = new List<PlateCard>();
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final List<String> value = prefs.getStringList(kSpPlateCards) ?? List<String>();
      for (int i = 0; i < value.length; i++) {
        var ls = value[i].split(',');
        lsPlates.add(PlateCard(int.parse(ls[0]), ls[1], ls[2]=='true'));
      }
      numsOfPlates = prefs.getInt('numOfPlates') ?? 0;
    });
    _updateChosenPlate();
  }

  _saveChosenPlate() async {
    final prefs = await SharedPreferences.getInstance();
    for(final item in lsPlates){
      if(item.operate){
        prefs.setString('chosenPlate', item.numPlate.toString());
        break;
      }
    }
    if(lsPlates.isEmpty){
      prefs.setString('chosenPlate', '-1');

    }
  }
}

class PlateCard {
  int numPlate;
  String name;
  bool operate;

  PlateCard(this.numPlate, this.name, this.operate);
}
