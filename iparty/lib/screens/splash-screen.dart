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
        renderDoneBtn: Text('HECHO'),
        onDonePress: () => Navigator.of(context).pop(),
        renderSkipBtn: Text('SALTAR'),
        onSkipPress: () => Navigator.of(context).pop(),
      ),
    );
  }

   List<Slide> _genSlides(ThemeData themeOfContext) {
    return [
      Slide(
        widgetTitle: Center(
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
        description: '¡Crea partidas, busca amigos, haz un plan!',
        styleDescription: themeOfContext.textTheme.body1,
        pathImage: 'assets/images/goblin_dice.png',
        backgroundColor: themeOfContext.accentColor,
      ),
      Slide(
        widgetTitle: Center(
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
        description: '¡Elige juego, fecha y sitio!',
        styleDescription: themeOfContext.textTheme.body1,
        pathImage: 'assets/images/goblin_archer.png',
        backgroundColor: Color.fromRGBO(255, 212, 161, 1),
      ),
      Slide(
        widgetTitle: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '¡O busca mesas cerca!',
                  style: themeOfContext.textTheme.title,
                  textAlign: TextAlign.center,
                ),
              ],
          ),
        ),
        description:
            'No te olvides de utilizar nuestros filtros para encontrar la mejor opción para ti :) ',
        styleDescription: themeOfContext.textTheme.body1,
        pathImage: 'assets/images/goblin_sword.png',
        backgroundColor: themeOfContext.primaryColor,
      ),
    ];
  }
}
