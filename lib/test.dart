import 'package:flutter/material.dart';

class Second extends StatefulWidget {
  const Second({Key? key}) : super(key: key);

  @override
  State<Second> createState() => _SecondState();
}

class _SecondState extends State<Second> {

  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    _controller.text = "j\na\nh\ne\nd\n";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TextField'),
      ),
      body: Center(
        child: Column(
          children: [
            TextField(
              autofocus: true,
              controller: _controller,
              maxLines: 11,
            ),
          ],
        ),
      )
    );
  }
}
