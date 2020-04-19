import 'package:flutter/material.dart';

class NewTableScreen extends StatefulWidget {
  static final routeName = '/new-table';

  @override
  _NewTableScreenState createState() => _NewTableScreenState();
}

class _NewTableScreenState extends State<NewTableScreen> {
  var _lights = false;
  var _numberPlayers = RangeValues(2, 5);

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
                          labelText: 'Juego',
                          hintText:
                          '¿A qué vais a jugar?'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('Jugadores:'),
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
                    Text('Seleccionar base de operaciones'),
                    Text('Hora primera sesión'),
                    Text('Fecha'),
                    Text('Rol/partida'),
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
}
