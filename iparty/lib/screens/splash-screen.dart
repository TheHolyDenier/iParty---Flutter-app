import 'package:flutter/material.dart';

import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';

class SplashPage extends StatelessWidget {
  static final routeName = '/intro';

  @override
  Widget build(BuildContext context) {
    var themeOfContext = Theme.of(context);
    return Scaffold(
      body: IntroSlider(
        slides: _genSlides(themeOfContext),
        renderNextBtn: Icon(Icons.arrow_forward),
        renderPrevBtn: Icon(Icons.arrow_back),
        renderDoneBtn: Text(
          'TERMINAR',
          maxLines: 1,
        ),
        onDonePress: () => Navigator.of(context).pop(),
        renderSkipBtn: Text('SALTAR'),
        onSkipPress: () => Navigator.of(context).pop(),
      ),
    );
  }

  List<Slide> _genSlides(ThemeData themeOfContext) {
    return [
      Slide(
        widgetTitle: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('el tinder (platónico) para goblins'),
                Text(
                  'iParty',
                  style: themeOfContext.textTheme.title,
                ),
              ],
            ),
          ),
        ),
        description: '¡Crea partidas, busca amigos, haz un plan!',
        styleDescription: themeOfContext.textTheme.body1,
        centerWidget: Image(
          image: AssetImage(
            'assets/images/goblin_dice.png',
          ),
          width: double.infinity,
        ),
        backgroundColor: themeOfContext.accentColor,
      ),
      Slide(
        widgetTitle: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '¡Crea tu mesa! ',
                  style: themeOfContext.textTheme.title,
                ),
              ],
            ),
          ),
        ),
        description: '¡Elige juego, fecha y sitio!',
        styleDescription: themeOfContext.textTheme.body1,
        centerWidget: Image(
          image: AssetImage(
            'assets/images/goblin_archer.png',
          ),
          width: double.infinity,
        ),
        backgroundColor: Color.fromRGBO(255, 212, 161, 1),
      ),
      Slide(
        widgetTitle: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '¡O busca mesas cerca de ti!',
                  style: themeOfContext.textTheme.title,
                ),
              ],
            ),
          ),
        ),
        description:
            '¡También puedes apuntarte a planes de otros usuarios! Utiliza nuestros filtros para encontrar la mejor opción para ti :) ',
        styleDescription: themeOfContext.textTheme.body1,
        centerWidget: Image(
          image: AssetImage(
            'assets/images/goblin_sword.png',
          ),
          width: double.infinity,
        ),
        backgroundColor: themeOfContext.primaryColor,
      ),
    ];
  }
}
