import 'dart:convert';
import 'dart:ui';
import 'package:about/about.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animations/loading_animations.dart';
import 'package:url_launcher/url_launcher.dart';

Future<List<Changelog>> fetchChangelog(http.Client client) async {
  final response = await client.get('https://lt.ra1g.eu/zoznamzmien.json');
  if (response.statusCode == 200) {
    return compute(parseChangelog, utf8.decode(response.bodyBytes));
  } else {
    print('Request failed with status: ${response.statusCode}.');
  }
}

// A function that converts a response body into a List<Photo>.
List<Changelog> parseChangelog(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Changelog>((json) => Changelog.fromJson(json)).toList();
}

class Changelog {
  final String verzia;
  final String published;
  final String text;

  Changelog({this.verzia, this.published, this.text});

  factory Changelog.fromJson(Map<String, dynamic> json) {
    return Changelog(
      verzia: json['ver'] as String,
      published: json['published'] as String,
      text: json['text'] as String,
    );
  }
}

Future<bool> isInternetAvailable() async {
  bool result = await DataConnectionChecker().hasConnection;
  if (result == true) {
    return true;
  } else {
    print('No internet :( Reason:');
    print(DataConnectionChecker().lastTryResults);
    return false;
  }
}

class MyAppDevPage extends StatefulWidget {
  MyAppDevPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  State<StatefulWidget> createState() => _MyAppDevPageState();
}

class _MyAppDevPageState extends State<MyAppDevPage> {
  bool isAvailable;

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () async {
      isAvailable = await isInternetAvailable();
      if (isAvailable) {
        isAvailable = true;
        return true;
      } else {
        isAvailable = false;
        return false;
      }
    });
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.05, 0.15, 0.30, 0.45, 0.60, 0.75, 0.90, 0.99],
          colors: [
            Colors.blue[600],
            Colors.blue[600],
            Colors.blue,
            Colors.blue,
            Colors.blue[400],
            Colors.blue[400],
            Colors.blue[400],
            Colors.blue[400],
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          title: Text(widget.title),
          actions: <Widget>[
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.github),
              tooltip: 'GitHub Repozitár',
              onPressed: () async {
                const url = 'https://github.com/ra1g-eu/letecke_testy_final';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Odkaz nenájdený: $url';
                }
              },
            ),
            VerticalDivider(),
            IconButton(
              icon: const Icon(Icons.info_outline),
              tooltip: 'Informácie o aplikácií',
              onPressed: () {
                showAboutPage(
                  context: context,
                  title: const Text('Informácie o aplikácií'),
                  applicationVersion:
                      'Verzia {{ version }}, zostava #{{ buildNumber }}',
                  applicationLegalese: 'Copyright © RA1G.eu, {{ year }}',
                  applicationDescription: const AutoSizeText(
                    'Aplikácia pre nadšencov, študentov a ašpirujúcich pilotov osobných lietadiel.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  children: <Widget>[
                    MarkdownPageListTile(
                      filename: 'assets/mds/CONTRIBUTING.md',
                      title: Text(
                        'Testeri aplikácie',
                        style: TextStyle(fontSize: 18),
                      ),
                      icon: Icon(Icons.people),
                    ),
                    MarkdownPageListTile(
                      filename: 'assets/mds/README.md',
                      title: Text(
                        'O aplikácií',
                        style: TextStyle(fontSize: 18),
                      ),
                      icon: Icon(Icons.info),
                    ),
                    MarkdownPageListTile(
                      icon: Icon(Icons.text_snippet),
                      title: const Text(
                        'Licencia aplikácie',
                        style: TextStyle(fontSize: 18),
                      ),
                      filename: 'assets/mds/LICENSE_APP.md',
                    ),
                    LicensesPageListTile(
                      icon: Icon(Icons.favorite),
                      title: const Text(
                        'Všetky licencie',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                  applicationIcon: const SizedBox(
                    width: 125,
                    height: 125,
                    child: Image(
                      image: AssetImage("assets/images/logo3.png"),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: FutureBuilder<List<Changelog>>(
          future: fetchChangelog(http.Client()),
          builder: (context, snapshot) {
            print(isAvailable);
            if (isAvailable == null) {
              return Center(
                child: LoadingBouncingGrid.square(
                  backgroundColor: Colors.blue[400],
                  borderColor: Colors.black,
                  inverted: true,
                  size: 70,
                  borderSize: 5,
                ),
              );
            } else if (!isAvailable) {
              return Center(
                  child: Text("Táto akcia vyžaduje pripojenie k internetu..."));
            } else if (snapshot.hasError) {
              return Center(child: Text("Chyba: " + snapshot.error));
            } else if (isAvailable && snapshot.hasData) {
              return ChangelogsList(changelog: snapshot.data);
            } else {
              return Center(child: Text('Niekde nastala neočakávaná chyba...'));
            }
          },
        ),
      ),
    );
  }
}

class ChangelogsList extends StatelessWidget {
  final List<Changelog> changelog;

  ChangelogsList({Key key, this.changelog}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: changelog.length,
      separatorBuilder: (context, index) {
        return const Divider(height: 1.0,color: Colors.transparent,);
      },
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
          child: ExpansionTileCard(
            baseColor: Colors.blue[900].withOpacity(0.7),
            expandedColor: Colors.blue[900],
            leading: CircleAvatar(
              backgroundColor: Colors.indigo[900],
              child: Text(
                (changelog.length - index).toString(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              foregroundColor: Colors.white,
            ),
            title: Text(
              "v" + changelog[index].verzia,
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.normal),
            ),
            subtitle: Text(
              changelog[index].published,
              style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 20,
                  fontWeight: FontWeight.w300),
            ),
            children: <Widget>[
              Divider(
                thickness: 1.0,
                height: 1.0,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Text(changelog[index].text,
                      style: TextStyle(fontSize: 18.0)),
                ),
              ),
              ButtonBar(
                alignment: MainAxisAlignment.spaceAround,
                buttonHeight: 52.0,
                buttonMinWidth: 90.0,
                children: <Widget>[
                  FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0)),
                    onPressed: () async {
                      var url;
                      if(changelog[index].verzia.contains("najnovšia", 4)){
                        url = 'https://github.com/ra1g-eu/letecke_testy_final';
                      } else {
                        url = 'https://lt.ra1g.eu/downloads.php';
                      }
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw 'Odkaz nenájdený: $url';
                      }
                    },
                    child: Column(
                      children: <Widget>[
                        const FaIcon(FontAwesomeIcons.github),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                        ),
                        Text('Zdrojový kód'),
                      ],
                    ),
                  ),
                  FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0)),
                    onPressed: () async {
                      var url;
                      if(changelog[index].verzia.contains("najnovšia", 4)){
                        url = 'https://github.com/ra1g-eu/letecke_testy_final';
                      } else {
                        url = 'https://lt.ra1g.eu/downloads.php';
                      }
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw 'Odkaz nenájdený: $url';
                      }
                    },
                    child: Column(
                      children: <Widget>[
                        const FaIcon(FontAwesomeIcons.android),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                        ),
                        Text('Stiahnuť'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
