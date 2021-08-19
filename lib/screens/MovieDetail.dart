import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:moviereviewsapp/models/movie.dart';
import 'package:moviereviewsapp/screens/addEditMovie.dart';
import 'package:moviereviewsapp/widgets/drawer.dart';

class MovieDetails extends StatefulWidget {
  static const id = 'MovieDetails';
  final int position;
  final Movie? movieModel;
  MovieDetails(this.position, this.movieModel);

  @override
  _MovieDetailsState createState() => _MovieDetailsState();
}

class _MovieDetailsState extends State<MovieDetails> {
  @override
  Widget build(BuildContext context) {
    final _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: _scaffoldKey,
      drawer: MainDrawer(),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.menu_open,
            color: Colors.purple,
            size: 32,
          ),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Movie Details',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 1, 12, 1),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Container(
                  height: 300,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      child: Image.network(
                        widget.movieModel!.posterUrl,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 10, 8, 10),
              child: Text(
                'Movie Name:',
                softWrap: true,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 10, 8, 10),
              child: Text(
                widget.movieModel!.movieName,
                softWrap: true,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 10, 8, 10),
              child: Text(
                'Director Name:',
                softWrap: true,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 10, 8, 10),
              child: Text(
                widget.movieModel!.movieDirect,
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FloatingActionButton(
          backgroundColor: Colors.deepOrange,
          onPressed: () async {
            final FirebaseAuth auth = FirebaseAuth.instance;
            final User? user = auth.currentUser;
            final uid = user!.uid;
            List<Movie> fullMovieList = [];
            List<Movie> listMovies = [];
            final box = await Hive.openBox<Movie>('movie');
            setState(() {
              fullMovieList = box.values.toList();
            });
            fullMovieList.forEach((element) {
              if (element.uID == uid) {
                listMovies.add(element);
              }
            });
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) {
                return AddEditMovies(true, widget.position, widget.movieModel,listMovies.length);
              },
            ));
          },
          child: Icon(
            Icons.edit,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
