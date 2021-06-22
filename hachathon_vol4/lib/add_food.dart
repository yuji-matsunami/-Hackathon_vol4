import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:hachathon_vol4/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

firebase_storage.FirebaseStorage storage =
    firebase_storage.FirebaseStorage.instance;

class NextPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NextPage();
  }
}

class _NextPage extends State<NextPage> {
  File? _image;
  final imagePicker = ImagePicker();
  List<String> _tineLabels = ["朝食", "昼食", "夕食", "おやつ"];
  String? _selectedKey;
  String _foodName = "";
  var url = "";

  Future getImageFromCamera() async {
    final pickedFile = await imagePicker.getImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        print("パス：" + pickedFile.path);
      }
    });
  }

  Future getImageFromLibrary() async {
    final pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<String?> _uploadImage() async {
    if (_image != null) {
      //File file = File(_image.path);
      await firebase_storage.FirebaseStorage.instance
          .ref()
          .child("foods/$_foodName")
          .putFile(_image!);
      var ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child("foods/$_foodName");
      url = await ref.getDownloadURL();
      print(url);
      SetFood(_selectedKey, _foodName, url);
    }
  }

  void SetFood(when, name, url) {
    DateTime now = DateTime.now();
    String date = DateFormat('yyyy年M月d日').format(now);
    print(date);

    FirebaseFirestore.instance.collection("myfood").add({
      "date": date,
      "when": when,
      "name": name,
      "theory": "",
      "imageURL": url
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("料理を追加"),
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center, //children以下のレイアウト間隔など
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _image == null
                  ? Container(
                      width: 250,
                      height: 150,
                      margin: EdgeInsets.fromLTRB(30, 0, 30, 50),
                      child: Image.network(
                          "https://4.bp.blogspot.com/-7Yn9HIjxaVk/W5H_yHMZ9rI/AAAAAAABOvo/swKb6GUVdg89VKZuePfiUAQa9crZyta0QCLcBGAs/s400/food_moritsuke_good.png"),
                    )
                  : Container(
                      width: 250,
                      height: 150,
                      //margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
                      padding: EdgeInsets.all(8),
                      child: Image.file(_image!),
                    ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FloatingActionButton(
                        onPressed: getImageFromCamera, //カメラで写真をとる
                        child: Icon(Icons.add_a_photo)),
                    FloatingActionButton(
                        onPressed: getImageFromLibrary, //アルバムから写真をとる
                        child: Icon(Icons.photo)),
                  ]),
              Form(
                child: TextFormField(
                  decoration: InputDecoration(labelText: '料理名'),
                  onFieldSubmitted: (value) {
                    print(value);
                    setState(() {
                      _foodName = value;
                    });
                  },
                ),
              ),
              Text("↓食べた時間は?"),
              DropdownButton<String>(
                value: _selectedKey,
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 30,
                elevation: 16,
                style: TextStyle(fontSize: 20, color: Colors.white),
                underline: Container(
                  height: 2,
                  color: Colors.grey,
                ),
                onChanged: (newValue) {
                  setState(() {
                    _selectedKey = newValue;
                  });
                },
                items:
                    _tineLabels.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              )
            ]),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            _uploadImage;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyPage()),
            );
          }, //カメラで写真をとる
          child: Icon(Icons.file_upload)),
    );
  }
}
