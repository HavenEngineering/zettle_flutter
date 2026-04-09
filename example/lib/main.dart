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
  bool _initialised = false;

  @override
  void initState() {
    super.initState();
  }

  _init() async {
    var test = await Zettle.init("ios", "android", "test://login.callback");

    setState(() {
      _initialised = true;
      _message = 'init $test';
    });
  }

  _login() async {
    var test = await Zettle.login();

    setState(() {
      _message = 'login $test';
    });
  }

  String? _lastPaymentReference;

  _payment() async {
    var uuid = const Uuid();
    var reference = uuid.v4();

    var test = await Zettle.requestPayment(ZettlePaymentRequest(
        amount: 1,
        reference: reference,
        enableLogin: true,
        enableTipping: false,
        enableInstalments: false));

    if (test.status == ZettlePluginPaymentStatus.completed) {
      _lastPaymentReference = test.reference;
    }

    setState(() {
      _message = '_payment $test';
    });
  }

  _refund() async {
    if (_lastPaymentReference == null) {
      setState(() {
        _message = 'No payment to refund. Make a payment first.';
      });
      return;
    }

    var test = await Zettle.requestRefund(ZettleRefundRequest(
      refundAmount: 1,
      reference: _lastPaymentReference!,
    ));

    setState(() {
      _message = '_refund $test';
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
          TextButton(
              child: const Text('init'),
              onPressed: _initialised ? null : () => _init()),
          TextButton(child: const Text('login'), onPressed: () => _login()),
          TextButton(child: const Text('payment'), onPressed: () => _payment()),
          TextButton(child: const Text('refund'), onPressed: () => _refund()),
          Text(_message ?? 'no message'),
        ]),
      ),
    );
  }
}
