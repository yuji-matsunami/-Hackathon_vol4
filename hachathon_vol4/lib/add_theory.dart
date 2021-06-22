import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:hachathon_vol4/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

firebase_storage.FirebaseStorage storage =
    firebase_storage.FirebaseStorage.instance;

class AddTheoryPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddTheoryPage();
  }
}

class _AddTheoryPage extends State<AddTheoryPage> {
  String? name;
  String? theory;
  void setTheory(name, theory) {
    FirebaseFirestore.instance.collection("theory").add({
      "name": name,
      "theory": theory,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("カロリーゼロ理論追加"),
      ),
      body: Center(
        child: Container(
          width: 250,
          child:Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("追加したい食べ物"),
              Form(
                child: TextFormField(
                  onChanged: (textName) {
                    name = textName;
                  },
                ),
              ),
              Text("カロリーゼロ理論"),
              Form(
                child: TextFormField(
                  onChanged: (textTheory) {
                    theory = textTheory;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setTheory(name, theory);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyPage()),
          );
        },
        child: Icon(Icons.drive_file_rename_outline),
      ),
    );
  }
}
