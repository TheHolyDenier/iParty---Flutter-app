import 'package:flutter/material.dart';

// import 'package:provider/provider.dart';

import '../models/party.dart';
// import '../providers/logged-user.dart';
import '../widgets/drawer.dart';

class HomeScreen extends StatelessWidget {
  static final routeName = '/home-screen';
  ThemeData _themeOf;

  var _parties = Party(
    date: '18/03/2020',
    headquarter: 'Mi casa',
    isCampaign: false,
    isOnline: false,
    isRpg: false,
    players: {'min': 2, 'max': 5},
    title: 'Partida de Carcassonne',
    uid: 'partidilla',
    game: 'Carcassonne',
    imageUrl:
        'https://morethanjustmonopoly.files.wordpress.com/2016/10/img_3366-v2b.jpg?w=1254',
    summary:
        'Carcassonne is a tile-based German-style board game for two to five players, designed by Klaus-Jürgen Wrede and published in 2000 by Hans im Glück in German and by Rio Grande Games and Z-Man Games in English. It received the Spiel des Jahres and the Deutscher Spiele Preis awards in 2001.',
  );

  @override
  Widget build(BuildContext context) {
    _themeOf = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Mesas disponibles'),
      ),
      body: RefreshIndicator(
          child: ListView.builder(
            itemBuilder: (context, index) {
              String isCampaign = _parties.isCampaign ? 'Campaña' : 'Partida';
              String isRpg = _parties.isRpg ? 'rol' : 'juego de mesa';
              String isOnline = _parties.isOnline ? 'onlinr' : '';
              return Container(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 5.0,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Column(
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            Image.network(
                              _parties.imageUrl,
                              fit: BoxFit.cover,
                              height: 170,
                              width: double.infinity,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              left: 0,
                              child: Container(
                                padding: EdgeInsets.only(left: 5, right: 5),
                                color: Colors.black54,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Text(
                                      '$isCampaign de $isRpg $isOnline',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                    Text(
                                      _parties.title,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right,
                                      style: _themeOf.textTheme.title.copyWith(
                                          color: Colors.white, height: 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5.0),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(Icons.supervised_user_circle),
                                        SizedBox(width: 5),
                                        Column(
                                          children: <Widget>[
                                            Text(
                                                '${_parties.players['min']} - ${_parties.players['max']}'),
                                            Text(
                                              'Jugadores',
                                              style: TextStyle(
                                                  color: Colors.black54,
                                                  fontStyle: FontStyle.italic,
                                                  height: 1),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Icon(Icons.calendar_today),
                                      SizedBox(width: 5),
                                      Column(
                                        children: <Widget>[
                                          Text('${_parties.date}'),
                                          Text(
                                            '${_parties.date}',
                                            style: TextStyle(
                                                color: Colors.black54,
                                                fontStyle: FontStyle.italic,
                                                height: 1),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 5.0),
                              Text(
                                _parties.summary,
                                softWrap: true,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            itemCount: 10,
          ),
          onRefresh: () async {
            return true;
          }),
      drawer: MyDrawer(),
    );
  }
}
