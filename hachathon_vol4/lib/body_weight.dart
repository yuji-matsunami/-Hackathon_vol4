//import 'dart:html';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:hachathon_vol4/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
//import 'package:charts_flutter/flutter.dart' as charts;

firebase_storage.FirebaseStorage storage =
    firebase_storage.FirebaseStorage.instance;

class ShowWeightPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ShowWeightPage();
  }
}

class _ShowWeightPage extends State<ShowWeightPage> {
  final snapshot = FirebaseFirestore.instance.collection('weight').snapshots();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("過去の体重"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('weight').snapshots(),

        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          return new ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return Column(
                children: <Widget>[
                  Card(
                    child: ListTile(
                      title: Text(document["weight"]),
                      subtitle: Text(document["date"])
                    )
                  ),
                  
                ],
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BodyWeightPage()),
          );
        },
        child: Icon(Icons.drive_file_rename_outline),
      ),
    );
  }
}

class BodyWeightPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BodyWeightPage();
  }
}

class _BodyWeightPage extends State<BodyWeightPage> {
  String? weight;

  void regiWeight(weight) {
    DateTime now = DateTime.now();
    String date = DateFormat('yyyy年M月d日').format(now);

    FirebaseFirestore.instance.collection("weight").add({
      "date": date,
      "weight": weight + "kg",
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("体重入力"),
      ),
      body: Center(
          child: Container(
              width: 250,
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Text("体重"),
                Form(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    onChanged: (textName) {
                      weight = textName;
                    },
                  ),
                ),
              ]))),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          regiWeight(weight);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ShowWeightPage()),
          );
        },
        child: Icon(Icons.drive_file_rename_outline),
      ),
    );
  }
}
