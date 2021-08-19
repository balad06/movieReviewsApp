import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:moviereviewsapp/models/movie.dart';
import 'package:moviereviewsapp/screens/home.dart';
import 'package:moviereviewsapp/widgets/drawer.dart';

class AddEditMovies extends StatefulWidget {
  static const id = '/AddMovie';
  final bool isEdit;
  final int position;
  final Movie? movieModel;
  final int length;
  AddEditMovies(this.isEdit, this.position, this.movieModel, this.length);

  @override
  _AddEditMoviesState createState() => _AddEditMoviesState();
}

class _AddEditMoviesState extends State<AddEditMovies> {
  final _titleFocusNode = FocusNode();
  final _directorFocusNode = FocusNode();
  final _imageUrlContoller = TextEditingController();
  final _imageFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  TextEditingController controllerMName = new TextEditingController();
  TextEditingController controllerMDirect = new TextEditingController();
  var invalidImage = false;

  @override
  void initState() {
    if (widget.isEdit) {
      _imageUrlContoller.text = widget.movieModel!.posterUrl;
      controllerMDirect.text = widget.movieModel!.movieDirect;
      controllerMName.text = widget.movieModel!.movieName;
    }
    super.initState();
  }

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _directorFocusNode.dispose();
    controllerMDirect.dispose();
    controllerMName.dispose();
    _imageUrlContoller.dispose();
    _imageFocusNode.dispose();
    super.dispose();
  }

  submit() async {
    if (_form.currentState!.validate()) {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? user = auth.currentUser;
      final uid = user!.uid;
      print(uid);
      print(_imageUrlContoller.text);
      print(controllerMName.text);
      print(controllerMDirect.text);
      if (controllerMDirect.text.trim().isEmpty ||
          controllerMName.text.trim().isEmpty ||
          invalidImage == true) {
        final snackBar = SnackBar(
          content: const Text('Please Enter Valid Details!'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      if (_imageUrlContoller.text.trim().isEmpty) {
        final snackBar = SnackBar(
          content: const Text('Please Enter Valid Image!'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      if (controllerMDirect.text.trim().isNotEmpty &&
          controllerMName.text.trim().isNotEmpty &&
          _imageUrlContoller.text.trim().isNotEmpty &&
          invalidImage == false) {
        final Movie movieData = Movie(
            id: DateTime.now().toString(),
            movieName: controllerMName.text,
            movieDirect: controllerMDirect.text,
            posterUrl: _imageUrlContoller.text,
            uID: uid.toString());
        if (widget.isEdit) {
          List<Movie> listMovies = [];
          List<Movie> fullMovieList = [];
          print('index edited${widget.position}');
          print(movieData.movieName);
          print(widget.length);
          var box = await Hive.openBox<Movie>('movie');
          box.putAt(widget.position, movieData);
          setState(() {
            fullMovieList = box.values.toList();
          });
          fullMovieList.forEach((element) {
            if (element.uID == uid) {
              listMovies.add(element);
            }
          });
          print('AfterEdit:${listMovies.length}');
          if (listMovies.length == widget.length) {
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (_) => MyHomePage()), (r) => false);
          } else if (listMovies.length > widget.length) {
            print('hello');
            final box = Hive.box<Movie>('movie');
            box.deleteAt(widget.position + 1);
            print('After Remove:${listMovies.length}');
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (_) => MyHomePage()), (r) => false);
          }
        } else {
          var box = await Hive.openBox<Movie>('movie');
          box.add(movieData);
          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (_) => MyHomePage()), (r) => false);
        }
      }
    }
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
          'Add Movie',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              submit();
            },
            icon: Icon(
              Icons.save,
            ),
            color: Colors.yellow[800],
          )
        ],
      ),
      drawer: MainDrawer(),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text('Movie Name:'),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextFormField(
                    focusNode: _titleFocusNode,
                    controller: controllerMName,
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return 'Please enter a Movie name.';
                      } else
                        return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.deepPurple,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        hintText: "Enter Movie Name ....",
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.deepPurple,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusColor: Colors.deepPurple),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text('Movie Poster:'),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextFormField(
                    focusNode: _imageFocusNode,
                    textInputAction: TextInputAction.next,
                    controller: _imageUrlContoller,
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        setState(() {
                          invalidImage = true;
                        });
                        return 'No Url Entered';
                      }
                      if (value.startsWith('http') == true &&
                          value.startsWith('https') == false) {
                        setState(() {
                          invalidImage = true;
                        });
                        print(invalidImage);
                        return 'Invalid Url Entered';
                      }
                      if (value.endsWith('.png') == false &&
                          value.endsWith('.jpg') == false) {
                        setState(() {
                          invalidImage = true;
                        });
                        print(invalidImage);
                        return 'Invalid Url Entered';
                      }
                      return null;
                    },
                    onFieldSubmitted: (value) {
                      print(_imageUrlContoller.text);
                      setState(() {
                        bool _validURL =
                            Uri.parse(_imageUrlContoller.text).isAbsolute;
                        if (_validURL) {
                          setState(() {
                            invalidImage = false;
                          });
                        } else {
                          invalidImage = true;
                        }
                      });
                    },
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.deepPurple,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.deepPurple,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        hintText: "Enter Poster Url ....",
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.deepPurple,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusColor: Colors.deepPurple),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text('Director Name:'),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextFormField(
                    focusNode: _directorFocusNode,
                    controller: controllerMDirect,
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return 'Please enter a name.';
                      } else
                        return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.deepPurple,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        hintText: "Enter Director Name ....",
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.deepPurple,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusColor: Colors.deepPurple),
                    onEditingComplete: () {},
                  ),
                ),
                SizedBox(height: 20),
                invalidImage
                    ? Column(children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Container(
                              child: Text('Invalid URL',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset('assets/place_holder.png'),
                        ),
                      ])
                    : (invalidImage == false &&
                            _imageUrlContoller.text.trim().isNotEmpty)
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _imageUrlContoller.clear();
                                  });
                                },
                                icon: Icon(Icons.close),
                              ),
                            ),
                          )
                        : Container(),
                (invalidImage == false &&
                        _imageUrlContoller.text.trim().isNotEmpty)
                    ? Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Center(
                            child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: const [
                              BoxShadow(blurRadius: 20),
                            ],
                          ),
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 8),
                          height: 160,
                          child: Image.network(
                            _imageUrlContoller.text,
                            fit: BoxFit.cover,
                          ),
                        )),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: Icon(
          Icons.save,
        ),
        onPressed: () async {
          print(invalidImage);
          if (invalidImage) {
            _imageUrlContoller.clear();
            final snackBar = SnackBar(
              content: const Text('Please Enter Valid Details!'),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
          if (invalidImage == false) submit();
        },
      ),
    );
  }
}
