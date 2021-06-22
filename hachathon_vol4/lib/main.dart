import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as dateformat;
import 'package:hachathon_vol4/add_food.dart';
import 'package:hachathon_vol4/detail_food.dart';
import 'package:hachathon_vol4/add_theory.dart';
import 'package:hachathon_vol4/body_weight.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:math' show pi;
import 'dart:math' show cos;
import 'dart:math' show sin;
import 'dart:math' show Random;
import 'dart:async';
import 'dart:io';

FirebaseFirestore firestore = FirebaseFirestore.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // ここ大事！
  runApp(Calorieapp());
}

//日付取得
List<String> getDate() {
  var now = DateTime.now();
  now = now.toUtc();
  var formatter = new dateformat.DateFormat("dd");
  // String today = formatter.format(now);
  List<String> date = [];
  for (int i = -3; i <= 3; i++) {
    var d = DateTime(now.year, now.month, now.day + i);
    String addDay = formatter.format(d);
    // addDay = int.parse(today + i.toString());
    // if (addDay <= 31 && addDay >= 1) {
    date.add((addDay).toString());
    // }
  }
  return date;
}

// 曜日を取得
List<String> getWeek() {
  final now = DateTime.now();
  int week = now.weekday;
  List<String> weeks = [];
  String output = "";

  for (int i = -3; i <= 3; i++) {
    int youbi = week + i;
    if (youbi <= 0) {
      youbi += 7;
    } else if (youbi > 7) {
      youbi -= 7;
    }

    if (youbi == 1) {
      output = "月曜日";
    } else if (youbi == 2) {
      output = "火曜日";
    } else if (youbi == 3) {
      output = "水曜日";
    } else if (youbi == 4) {
      output = "木曜日";
    } else if (youbi == 5) {
      output = "金曜日";
    } else if (youbi == 6) {
      output = "土曜日";
    } else if (youbi == 7) {
      output = "日曜日";
    }

    weeks.add(output);
  }
  return weeks;
}

// 追加
List<List<int>> MakeData() {
  List<List<int>> data = [
    [0, 0, 0, 0, 0, 0]
  ];
  for (int i = 0; i < 5; i++) {
    var rand = Random();
    // data[0].add(rand.nextInt(30));
    int datanum = rand.nextInt(30);
    if (datanum <= 10) {
      datanum += 10;
    }
    data[0][i + 1] = datanum;
  }
  return data;
}

class Calorieapp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: MyPage(),
    );
  }
}

class MyPage extends StatefulWidget {
  @override
  _MyPage createState() => _MyPage();
}

class _MyPage extends State<MyPage> {
  // 仮の日付を入れるリスト
  // List<String> weekday = ["1日","2日","3日","4日","5日"];

  List<String> week = getDate();
  List<String> weekday = getWeek();
  var _selectday = "Today";
  var data = MakeData();
  String date_database = dateformat.DateFormat('yyyy年M月d日')
            .format(DateTime.now().toUtc()); //データベースとの比較用に変数に日時を格納する

  Future<void> _selectDate(BuildContext context) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now().toUtc(),
      firstDate: DateTime(DateTime.now().year - 3),
      lastDate: DateTime(DateTime.now().year + 3),
    );
    if (selected != null) {
      setState(() {
        _selectday = (dateformat.DateFormat.yMMMd()).format(selected);
        date_database = dateformat.DateFormat('yyyy年M月d日')
            .format(selected); // データベースとの比較用に日時を格納
        var formatter = new dateformat.DateFormat("dd");
        for (int i = -3; i <= 3; i++) {
          var pickDay =
              DateTime(selected.year, selected.month, selected.day + i);
          String addDay = formatter.format(pickDay);
          // week[j + 3] = today + (i - 3).toString();
          week[i + 3] = addDay;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: Icon(Icons.menu),
        title: Text("伊達式ダイエット"),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              _selectDate(context);
              data = MakeData();
            },
            icon: Icon(Icons.calendar_today),
          )
        ],
      ),
      drawer: Container(
        width: 200,
        child: Drawer(
          child: ListView(
            children: <Widget>[
              DrawerHeader(
                child: Text("メニュー"),
                // ヘッダーの色を決める
                decoration: BoxDecoration(color: Colors.green),
              ),
              ListTile(
                  title: TextButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.white), // テキストボタンの色変更(デフォルトは青)
                ),
                onPressed: () {
                  Navigator.push(
                  context,
                  //MaterialPageRoute(builder: (context) => BodyWeightPage()),
                  MaterialPageRoute(builder: (context) => ShowWeightPage()),
            );
                },
                child: Text("体重推移"),
              )),
              ListTile(
                  title: TextButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.white), // テキストボタンの色変更(デフォルトは青)
                ),
                onPressed: () {},
                child: Text("おすすめメニュー"),
              )),
              ListTile(
                  title: TextButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.white), // テキストボタンの色変更(デフォルトは青)
                ),
                onPressed: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddTheoryPage()),
            );
                },
                child: Text("カロリーゼロ理論追加"),
              )),
              ListTile(
                  title: TextButton(
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.white), // テキストボタンの色変更(デフォルトは青)
                ),
                onPressed: () {},
                child: Text("カロリー理論クイズ"),
              )),
            ],
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 7,
            // children: week
            //     .map((String item) =>
            //         TextButton(onPressed: () {}, child: Text(item)))
            //     .toList(),
            children: <Widget>[
              for (int i = 0; i < week.length; i++)
                if (i == 3) ...[
                  ElevatedButton(
                    onPressed: () {},
                    child: Text(week[i]),
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(1),
                    ),
                    // shape: const CircleBorder(
                    //   side: BorderSide(
                    //     color: Colors.black,
                    //     width: 1,
                    //     style: BorderStyle.solid,
                    //   )
                    // )
                  ),
                ] else
                  TextButton(
                    onPressed: () {
                      setState(() {
                        var now = DateTime.now();
                        now = now.toUtc();
                        var formatter = new dateformat.DateFormat("dd");
                        String today = formatter.format(now);
                        int diff = int.parse(week[3]) - int.parse(today);

                        var display = DateTime(
                            now.year, now.month, now.day + i - 3 + diff);
                        _selectday =
                            (dateformat.DateFormat.yMMMd()).format(display);
                        date_database = dateformat.DateFormat('yyyy年M月d日')
                            .format(display); // データベースとの比較用に日時を格納

                        for (int j = -3; j <= 3; j++) {
                          var CalcDay = DateTime(now.year, now.month,
                              now.day + (i - 3 + j + diff));
                          String addDay = formatter.format(CalcDay);
                          // week[j + 3] = today + (i - 3).toString();
                          week[j + 3] = addDay;
                        }
                        data = MakeData();
                      });
                    },
                    child: Text(week[i]),
                  )
            ],
          ),
          Text(
            _selectday,
            style: TextStyle(
              fontSize: 40,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 2
                ..color = Colors.blue[700]!,
            ),
          ),
          CustomPaint(
            //サイズ固定→動的に決めたい
            size: Size(300, 300),
            painter: RadarChartPainter(data: data),
          ),
          Row(children: [
            Text("朝食"),
            TextButton(
              child: const Text('食べ物名'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailFood(date_database, "朝食")),
                );
              }, //詳細表示
              style: TextButton.styleFrom(
                primary: Colors.black, //ボタンの背景色
              ),
            ),
            Text("0kcal"),
          ]),
          Row(children: [
            Text("昼食"),
            TextButton(
              child: const Text('食べ物名'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailFood(date_database, "昼食")),
                );
              }, //詳細表示
              style: TextButton.styleFrom(
                primary: Colors.black, //ボタンの背景色
              ),
            ),
            Text("0kcal"),
          ]),
          Row(children: [
            Text("夕食"),
            TextButton(
              child: const Text('食べ物名'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailFood(date_database, "夕食")),
                );
              }, //詳細表示
              style: TextButton.styleFrom(
                primary: Colors.black, //ボタンの背景色
              ),
            ),
            Text("0kcal"),
          ]),
          Row(children: [
            Text("おやつ"),
            TextButton(
              child: const Text('食べ物名'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => DetailFood(date_database, "おやつ")),
                );
              }, //詳細表示?
              style: TextButton.styleFrom(
                primary: Colors.black, //ボタンの背景色
              ),
            ),
            Text("0kcal"),
          ]),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            print("押した");
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NextPage()),
            );
          },
          child: Icon(Icons.dining)),
    );
  }
}

class RadarChartPainter extends CustomPainter {
  var data;
  RadarChartPainter({@required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    //ここにレーダチャートの定期を書いていく
    var centerX = size.width / 2.0;
    var centerY = size.height / 2.0;
    var centerOffset = Offset(centerX, centerY);
    var radius = centerX * 0.63;

    var outlinePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..isAntiAlias = true;

    canvas.drawCircle(centerOffset, radius, outlinePaint);

    var ticks = [0, 20, 30];
    var tickDistance = radius / (ticks.length);
    const double tickLabelFontSize = 0;

    var ticksPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;

    ticks.sublist(0, ticks.length - 1).asMap().forEach((index, tick) {
      var tickRadius = tickDistance * (index + 1);

      canvas.drawCircle(centerOffset, tickRadius, ticksPaint);

      TextPainter(
        text: TextSpan(
          text: tick.toString(),
          style: TextStyle(color: Colors.grey, fontSize: tickLabelFontSize),
        ),
        textDirection: TextDirection.ltr,
      )
        ..layout(minWidth: 0, maxWidth: size.width)
        ..paint(
            canvas, Offset(centerX, centerY - tickRadius - tickLabelFontSize));
    });

    // チャートにのせる要素
    var features = ["カロリー", "たんぱく質", "炭水化物", "脂質", "ビタミン", "ミネラル"];
    var angle = (2 * pi) / features.length;
    const double featureLabelFontSize = 16;
    const double featureLabelFontWidth = 12;

    features.asMap().forEach((index, feature) {
      var xAngle = cos(angle * index - pi / 2);
      var yAngle = sin(angle * index - pi / 2);

      var featureOffset =
          Offset(centerX + radius * xAngle, centerY + radius * yAngle);

      canvas.drawLine(centerOffset, featureOffset, ticksPaint);

      var labelYOffset = yAngle < 0 ? -featureLabelFontSize : 0;
      var labelXOffset = xAngle < 0 ? -featureLabelFontWidth : 0;

      TextPainter(
        text: TextSpan(
          text: feature,
          style: TextStyle(color: Colors.black, fontSize: featureLabelFontSize),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )
        ..layout(minWidth: 0, maxWidth: size.width)
        ..paint(
            canvas,
            // Offset(featureOffset.dx + labelXOffset,
            //     featureOffset.dy + labelYOffset));
            Offset(centerX + (centerX*0.88)* xAngle + labelXOffset-10,
            centerY + (centerX*0.9) * yAngle +  labelYOffset));
      const graphClors = [Colors.green];
      var scale = radius / ticks.last;

      data.asMap().forEach((index, graph) {
        var graphPaint = Paint()
          ..color = graphClors[index % graphClors.length].withOpacity(0.3)
          ..style = PaintingStyle.fill;

        var graphOutlinePaint = Paint()
          ..color = graphClors[index % graphClors.length]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..isAntiAlias = true;

        // Start the graph on the initial point
        var scaledPoint = scale * graph[0];
        var path = Path();

        path.moveTo(centerX, centerY - scaledPoint);

        graph.sublist(1).asMap().forEach((index, point) {
          var xAngle = cos(angle * (index + 1) - pi / 2);
          var yAngle = sin(angle * (index + 1) - pi / 2);
          var scaledPoint = scale * point;

          path.lineTo(
              centerX + scaledPoint * xAngle, centerY + scaledPoint * yAngle);
        });
        path.close();
        canvas.drawPath(path, graphPaint);
        canvas.drawPath(path, graphOutlinePaint);
      });
    });
  }

  @override
  bool shouldRepaint(RadarChartPainter oldDelegate) {
    return false;
  }
}
