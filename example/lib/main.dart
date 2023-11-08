import 'package:flutter/material.dart';

import 'package:zettle/zettle.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _message;

  @override
  void initState() {
    super.initState();
  }

  _init() async {
    var test = await Zettle.init("ios", "android", "test://login.callback");

    setState(() {
      _message = 'init $test';
    });
  }

  _payment() async {
    var uuid = const Uuid();
    var reference = uuid.v4();

    var test = await Zettle.requestPayment(ZettlePaymentRequest(
        amount: 100,
        reference: reference,
        enableLogin: true,
        enableTipping: false,
        enableInstalments: false));

    setState(() {
      _message = '_payment $test';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(children: [
          TextButton(child: Text('init'), onPressed: () => _init()),
          TextButton(child: Text('payment'), onPressed: () => _payment()),
          Text(_message ?? 'no message'),
        ]),
      ),
    );
  }
}
