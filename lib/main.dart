import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:remita_flutter_inline/remita_flutter_inline.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Example App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Example Home'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _controller;
  final _globalKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example App')),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1, vertical: 10),
              child: TextFormField(
                decoration: const InputDecoration(labelText: 'Enter RRR'),
                controller: _controller,
                validator: (_) => _controller.text.isEmpty ? 'RRR is required' : null,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final FormState? form = _formKey.currentState;
                if (form!.validate()) {
                  _initializePayment(context, _controller.text);
                }
              },
              child: const Text('Pay Now'),
            ),
          ],
        ),
      ),
    );
  }

  _initializePayment(BuildContext context, String rrr) async {
    PaymentRequest request = PaymentRequest(
      environment: RemitaEnvironment.demo,
      rrr: rrr,
      key: 'QzAwMDAyNzEyNTl8MTEwNjE4NjF8OWZjOWYwNmMyZDk3MDRhYWM3YThiOThlNTNjZTE3ZjYxOTY5NDdmZWE1YzU3NDc0ZjE2',
    );

    try {
      // Create new RemitaPayment instance for each payment attempt
      RemitaPayment remita = RemitaInlinePayment(
        buildContext: context,
        paymentRequest: request,
        customizer: Customizer(),
      );

      PaymentResponse response = await remita.initiatePayment();
      if (response.code != null && response.code == '00') {
        // transaction successful
        // verify transaction status before providing value
        debugPrint('Payment successful: ${response.toString()}');
      } else {
        // transaction not successful.
        debugPrint('Payment failed: ${response.toString()}');
      }
      log(response.toString());
    } catch (e) {
      debugPrint('Payment error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment error: $e')),
      );
    }
  }
}