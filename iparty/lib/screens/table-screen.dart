import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:iparty/widgets/geo-field.dart';

class NewTableScreen extends StatefulWidget {
  static final routeName = '/new-table';

  @override
  _NewTableScreenState createState() => _NewTableScreenState();
}

class _NewTableScreenState extends State<NewTableScreen> {
  var _lights = false;
  var _numberPlayers = RangeValues(2, 5);
  final _controllerGeo = TextEditingController();
  DateTime selectedDate;
  TimeOfDay selectedTime;
  var formatter = new DateFormat('dd-MM-yyyy');

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controllerGeo.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nueva mesa'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 150.0,
              color: Theme.of(context).accentColor,
              child: FittedBox(child: Icon(Icons.photo)),
            ),
            Form(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: <Widget>[
                    Text(
                        'Rellene la siguiente información para crear su actividad: '),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Nombre de la mesa',
                          hintText:
                              'Servirá para que otros usuarios la reconozcan'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Tipo de mesa:'),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            Text('Mesa'),
                            Switch(
                                value: _lights,
                                onChanged: (bool value) {
                                  setState(() {
                                    _lights = value;
                                  });
                                }),
                            Text('Rol'),
                          ],
                        ),
                      ],
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Juego', hintText: '¿A qué vais a jugar?'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Wrap(
                          children: <Widget>[
                            Icon(Icons.people),
                            SizedBox(width: 3.0,),
                            Text('Jugadores:'),
                          ],
                        ),
                        Expanded(
                          child: RangeSlider(
                            values: _numberPlayers,
                            min: 1,
                            max: 10,
                            onChanged: (RangeValues values) {
                              setState(() {
                                _numberPlayers = values;
                              });
                            },
                            divisions: 9,
                            labels: RangeLabels(
                                '${_numberPlayers.start.round()}',
                                '${_numberPlayers.end.round()}'),
                          ),
                        ),
                      ],
                    ),
                    AddressWidget(_controllerGeo, LatLng(40.974737, -5.672455)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Fecha y hora:'),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            if (selectedDate != null)
                              Text('${formatter.format(selectedDate)}'),
                            IconButton(
                              onPressed: () => _selectDate(),
                              icon: Icon(Icons.calendar_today,
                                  color: Theme.of(context).accentColor),
                            ),
                            if (selectedTime != null)
                              Text('${selectedTime.format(context)}'),
                            IconButton(
                              onPressed: () => _selectedTime(),
                              icon: Icon(Icons.access_time,
                                  color: Theme.of(context).accentColor),
                            ),
                          ],
                        )
                      ],
                    ),
                    Text('Chips'),
                    Text('Descripción'),
                    Text('Una sesión/Más de una sesión'),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<Null> _selectDate() async {
    var now = DateTime.now();
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: new DateTime(now.year, now.month, now.day + 1),
        firstDate: new DateTime(now.year, now.month, now.day + 1),
        lastDate: new DateTime(now.year, now.month + 3, now.day));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  _selectedTime() async {
    final picked = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
    );

    if (picked != null && picked != selectedTime)
      setState(() {
        selectedTime = picked;
      });
  }
}
