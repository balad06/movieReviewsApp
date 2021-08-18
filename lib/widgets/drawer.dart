import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moviereviewsapp/models/movie.dart';
import 'package:moviereviewsapp/screens/addEditMovie.dart';
import 'package:moviereviewsapp/screens/home.dart';
import 'package:moviereviewsapp/screens/loginScreen.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * .68,
      child: Drawer(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: DrawerHeader(
                child: Container(
                  height: 60,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                      child: Text(
                    'MoviesApp',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  )),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            ListTile(
              leading: Icon(
                Icons.movie,
                color: Colors.deepPurple,
              ),
              title: Text(
                'Movie List',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              onTap: () {
                Navigator.of(context).pushNamed(MyHomePage.id);
              },
            ),
            SizedBox(
              height: 20,
            ),
            ListTile(
              leading: Icon(
                Icons.movie_filter,
                color: Colors.deepPurple,
              ),
              title: Text(
                'Add Watched Movie',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              onTap: () {
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
                              uID: uid));
                    },
                  ),
                );
              },
            ),
            SizedBox(
              height: 20,
            ),
            ListTile(
              leading: Icon(
                Icons.exit_to_app,
                color: Colors.deepPurple,
              ),
              title: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (route) => false);
              },
            ),
            SizedBox(
              height: 13,
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 25,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.black,
                  child: Center(
                    child: Text(
                      'v1.0.1',
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
