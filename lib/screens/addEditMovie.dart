import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:moviereviewsapp/models/movie.dart';
import 'package:moviereviewsapp/screens/home.dart';
import 'package:moviereviewsapp/widgets/drawer.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddEditMovies extends StatefulWidget {
  static const id = '/AddMovie';
  final bool isEdit;
  final int position;
  final Movie? movieModel;
  AddEditMovies(this.isEdit, this.position, this.movieModel);

  @override
  _AddEditMoviesState createState() => _AddEditMoviesState();
}

class _AddEditMoviesState extends State<AddEditMovies> {
  bool isLoading = false;
  final _titleFocusNode = FocusNode();
  final _directorFocusNode = FocusNode();
  final _imageUrlContoller = TextEditingController();
  final _imageFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  late XFile? _image;
  TextEditingController controllerMName = new TextEditingController();
  TextEditingController controllerMDirect = new TextEditingController();
  bool galImage = false;
  bool urlImage = false;
  bool invalidImage = false;
  pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 40,
    );
    setState(() {
      _image = image;
      galImage = true;
    });
  }

  @override
  void initState() {
    if (widget.isEdit) {
      _imageUrlContoller.text = widget.movieModel!.posterUrl;
      controllerMDirect.text = widget.movieModel!.movieDirect;
      controllerMName.text = widget.movieModel!.movieName;
      urlImage = true;
    }
    super.initState();
  }

  submit() async {
    var imageUrl;
    print(_imageUrlContoller.text);
    print(controllerMName.text);
    print(controllerMDirect.text);
    if (controllerMDirect.text.isEmpty ||
        controllerMName.text.isEmpty ||
        invalidImage == true) {
      final snackBar = SnackBar(
        content: const Text('Please Enter Valid Details!'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    if (controllerMDirect.text.isNotEmpty &&
        controllerMName.text.isNotEmpty &&
        invalidImage == false) {
      if (galImage) {
        setState(() {
          isLoading = true;
        });
        final ref = FirebaseStorage.instance
            .ref()
            .child('movieImages')
            .child(controllerMName.text + DateTime.now().toString() + '.jpg');
        await ref.putFile(File(_image!.path)).whenComplete(() => null);
        imageUrl = await ref.getDownloadURL();
      }
      final Movie movieData = Movie(
          id: DateTime.now().toString(),
          movieName: controllerMName.text,
          movieDirect: controllerMDirect.text,
          posterUrl: galImage ? imageUrl : _imageUrlContoller.text);
      if (widget.isEdit) {
        var box = await Hive.openBox<Movie>('movie');
        box.putAt(widget.position, movieData);
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (_) => MyHomePage()), (r) => false);
      } else {
        var box = await Hive.openBox<Movie>('movie');
        box.add(movieData);
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (_) => MyHomePage()), (r) => false);
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
      body: isLoading
          ? Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
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
                            if (value!.isEmpty) {
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
                            if (value!.isEmpty) {
                              return 'No Url Entered';
                            }
                            if (!value.startsWith('http') &&
                                !value.startsWith('https')) {
                              return 'Invalid Url Entered';
                            }
                            if (!value.endsWith('.png') &&
                                !value.endsWith('.jpg')) {
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
                                urlImage = true;
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
                            if (value!.isEmpty) {
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: new Container(
                                margin: const EdgeInsets.only(
                                    left: 15.0, right: 15.0),
                                child: Divider(
                                  color: Colors.black,
                                  height: 50,
                                )),
                          ),
                          Text("OR"),
                          Expanded(
                            child: new Container(
                              margin: const EdgeInsets.only(
                                  left: 15.0, right: 15.0),
                              child: Divider(
                                color: Colors.black,
                                height: 50,
                              ),
                            ),
                          )
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          pickImage();
                        },
                        child: Center(
                          child: Card(
                            child: Container(
                              width: 250,
                              height: 40,
                              color: Colors.yellow[800],
                              child: Center(
                                child: Text(
                                  'Upload from Gallery',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      invalidImage
                          ? Container(
                              child: Text('Invalid URL'),
                            )
                          : Container(),
                      urlImage
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      urlImage = false;
                                      _imageUrlContoller.clear();
                                    });
                                  },
                                  icon: Icon(Icons.close),
                                ),
                              ),
                            )
                          : Container(),
                      urlImage
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
                      galImage
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      galImage = false;
                                      _image = null;
                                    });
                                  },
                                  icon: Icon(Icons.close),
                                ),
                              ),
                            )
                          : Container(),
                      galImage
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
                                child: Image.file(
                                  File(_image!.path),
                                  fit: BoxFit.cover,
                                ),
                              )),
                            )
                          : SizedBox(
                              height: MediaQuery.of(context).size.height * .40)
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
          submit();
        },
      ),
    );
  }
}
