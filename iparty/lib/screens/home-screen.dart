import 'package:flutter/material.dart';
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
            body: PartiesWidget(_users.activeUser),
            drawer: MyDrawer(),
            floatingActionButton: FloatingActionButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(NewTableScreen.routeName),
              child: Icon(Icons.add),
            ),
          );
  }
}
