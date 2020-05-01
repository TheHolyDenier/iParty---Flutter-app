import 'package:flutter/material.dart';
import 'package:iparty/models/party.dart';
import 'package:iparty/models/user.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';

import './table-screen.dart';
import './loading-screen.dart';
import '../providers/logged-user.dart';
import '../providers/users.dart';
import '../widgets/drawer.dart';
import '../widgets/loading-parties.dart';

class HomeScreen extends StatefulWidget {
  static final routeName = '/home-screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _isInit = true;
  UsersProvider _users;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _users = Provider.of<UsersProvider>(context, listen: true);
    if (_isInit) {
      Provider.of<AuthService>(context, listen: false)
          .getUId()
          .then((authUser) {
        setState(() {
          _users.addOneUser(authUser.uid, true);
          _isInit = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isInit
        ? LoadingPage()
        : Scaffold(
            appBar: AppBar(
              title: Text('Mesas disponibles'),
            ),
            body: PartiesWidget(_isPartyOk),
            drawer: MyDrawer(),
            floatingActionButton: FloatingActionButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(NewTableScreen.routeName),
              child: Icon(Icons.add),
            ),
          );
  }

  bool _isPartyOk(Party party, User user) {
    var owner = party.playersUID[0] != user?.uid;
    var rpg = party.isRpg ? user.rpg : true;
    var table = !party.isRpg ? user?.table : true;
    var safe = user.safe ? party.isSafe : true;
    var online = party.isOnline ? user.online : true;
    var farAway = true;
    if (!party.isOnline && user?.latitude != null && user.km >= 1.0) {
      var distance = Distance().as(
          LengthUnit.Kilometer,
          LatLng(user?.latitude, user.longitude),
          LatLng(party.getLatLong().latitude, party.getLatLong().longitude));
      farAway = distance <= user.km;
    }
    return owner && rpg && table && safe && online && farAway;
  }
}
