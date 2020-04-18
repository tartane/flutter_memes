import 'dart:async';

import 'package:flutter/material.dart';
import 'package:draw/draw.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LOL',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.lime
      ),
      home: MemesHomePage(title: 'Memes'),
    );
  }
}


class MemesHomePage extends StatefulWidget {
  MemesHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MemesHomePageState createState() => _MemesHomePageState();
}

class _MemesHomePageState extends State<MemesHomePage> {
  Future<List<Uri>> memesUri;
  int limit = 2;
  StreamController memesController;

  @override
  void initState() {
    memesController = new StreamController();
    loadMemes();
    super.initState();
  }

  Future<List<Uri>> fetchMemesUri() async {
    // Create the `Reddit` instance and authenticated
    Reddit reddit = await Reddit.createReadOnlyInstance(
      clientId: '5TVBDkQGk0fZsw',
      clientSecret: 'H2F4xnnx4P6qG2icj3uHhFKrTTc',
      userAgent: 'memes'
    );

    List<Uri> images = new List();
    await reddit.subreddit('memes').hot(limit:limit).where((userContent) => userContent is Submission).cast<Submission>().toList().then((list) {
      list.forEach((sub) {
        sub.preview.forEach((preview) {
          images.add(preview.source.url);
          print(preview.source.url);
        });
      });
    });

    return images;
  }

  loadMemes() async {
    fetchMemesUri().then((res) async {
      memesController.add(res);
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(child: Container(
              child: StreamBuilder(
                stream: memesController.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return RefreshIndicator(
                      child: GridView.count(
                              // Create a grid with 2 columns. If you change the scrollDirection to
                              // horizontal, this produces 2 rows.
                              crossAxisCount: 2,
                              // Generate 100 widgets that display their index in the List.
                              children: List.generate(snapshot.data.length, (index) {
                                return Center(
                                  child: CachedNetworkImage(
                                      imageUrl:snapshot.data[index].toString(),
                                      placeholder: (context, url) => CircularProgressIndicator()
                                    ),
                                );
                              }),
                            ),
                      onRefresh: () {
                            limit += 2;
                        return loadMemes();
                        
                      },
                            ); 
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }

                  // By default, show a loading spinner.
                  return CircularProgressIndicator();
                },
              ),
        ),
 
      ) // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
