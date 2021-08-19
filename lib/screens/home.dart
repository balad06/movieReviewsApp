import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:moviereviewsapp/models/movie.dart';
import 'package:moviereviewsapp/screens/MovieDetail.dart';
import 'package:moviereviewsapp/screens/addEditMovie.dart';
import 'package:moviereviewsapp/widgets/drawer.dart';
// import 'package:flutter_svg/flutter_svg.dart';

class MyHomePage extends StatefulWidget {
  static const id = '/homePage';
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Movie> listMovies = [];
  List<Movie> fullMovieList = [];

  void getMovies() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user!.uid;
    print('user$uid');
    final box = await Hive.openBox<Movie>('movie');
    setState(() {
      fullMovieList = box.values.toList();
    });
    print('MovieList');
    fullMovieList.forEach((element) {
      print(element.uID);
      if (element.uID == uid) {
        listMovies.add(element);
      }
    });
  }

  @override
  void initState() {
    getMovies();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.menu_open,
            color: Colors.purple,
            size: 32,
          ),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
        title: Text(
          'Movie List',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              final FirebaseAuth auth = FirebaseAuth.instance;
              final User? user = auth.currentUser;
              final uid = user!.uid;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return AddEditMovies(
                        false,
                        -1,
                        Movie(
                            id: '-1',
                            movieDirect: '',
                            movieName: '',
                            posterUrl: '',
                            uID: uid.toString()),
                        listMovies.length);
                  },
                ),
              );
            },
            icon: Icon(
              Icons.add,
              color: Colors.black,
            ),
          ),
        ],
      ),
      drawer: MainDrawer(),
      body: listMovies.length == 0
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Image.asset('assets/waiting.png',
                        height: MediaQuery.of(context).size.height * .7),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'No Movies Added',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            )
          : Center(
              child: ListView.builder(
              itemBuilder: (context, i) {
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return MovieDetails(i, listMovies[i]);
                        },
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        bottom: 3.0, left: 20.0, right: 20.0),
                    child: Card(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Container(
                                  child: listMovies[i].posterUrl.isNotEmpty
                                      ? Image.network(
                                          listMovies[i].posterUrl,
                                          height: 150,
                                          width: 80,
                                        )
                                      : Image.asset(
                                          'assets/place_holder.png',
                                          height: 150,
                                          width: 80,
                                        ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Column(
                                  children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(left: 8),
                                            child: Text(
                                              listMovies[i].movieName.length <=
                                                      20
                                                  ? listMovies[i].movieName
                                                  : ('${listMovies[i].movieName.substring(0, 20)}...'),
                                              style: TextStyle(
                                                  fontSize: listMovies[i]
                                                              .movieName
                                                              .length <=
                                                          20
                                                      ? 20
                                                      : 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ]),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            listMovies[i].movieDirect.length <=
                                                    30
                                                ? listMovies[i].movieDirect
                                                : '${listMovies[i].movieDirect.substring(0, 27)}...',
                                            softWrap: true,
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.normal),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          print('index:$i');
                                          print(listMovies[i].movieName);
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) {
                                                return AddEditMovies(
                                                    true,
                                                    i,
                                                    listMovies[i],
                                                    listMovies.length);
                                              },
                                            ),
                                          );
                                        },
                                        icon: Icon(Icons.edit)),
                                    IconButton(
                                        onPressed: () {
                                          final box = Hive.box<Movie>('movie');
                                          print('deleting at $i');
                                          box.deleteAt(i);
                                          print('deleting');
                                          setState(() => {
                                                listMovies.removeAt(i),
                                              });
                                        },
                                        icon: Icon(Icons.delete))
                                  ],
                                ),
                              )
                            ]),
                      ),
                    ),
                  ),
                );
              },
              itemCount: listMovies.length,
            )),
    );
  }
}
