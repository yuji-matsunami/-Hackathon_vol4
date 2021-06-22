import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import "dart:math";

class DetailFood extends StatefulWidget {
  //home画面からのデータを受け取る
  DetailFood(this.date_datebase, this.when);
  String date_datebase;
  String when;

  @override
  State<StatefulWidget> createState() {
    return _DetailFood(date_datebase, when);
  }
}

class _DetailFood extends State<DetailFood> {
  _DetailFood(this.date_datebase, this.when);
  String date_datebase;
  String when;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(when),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('myfood')
                                          .where("date", isEqualTo: date_datebase)
                                          .where("when", isEqualTo: when)
                                          .snapshots(),
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
              if (document["date"] == date_datebase) [];
              return Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.all(8),
                    child: Image.network(document["imagePath"]),
                  ),
                  Text(document["date"]),
                  Text(document["when"]),
                  Text(document["name"], style: TextStyle(fontSize: 20)),
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 40, 20, 0),
                    decoration: BoxDecoration(
                      border: const Border(
                        bottom: const BorderSide(
                          color: Colors.black,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(document["theory"],
                        style: TextStyle(fontSize: 30)),
                  ),
                  Container(
                    width: 200,
                    height: 250,
                    margin: EdgeInsets.fromLTRB(250, 0, 0, 0),
                    padding: EdgeInsets.all(5),
                    child: Image.network(
                        "https://3.bp.blogspot.com/-CYddkizhY0M/W8hDuaCjenI/AAAAAAABPe8/NSMFAwy9Mdw25VvoRcBuS7q7Xf0ri9SWwCLcBGAs/s450/diet_after_man.png"),
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
