import 'package:flutter/material.dart';

class Second extends StatefulWidget {
  const Second({Key? key}) : super(key: key);

  @override
  State<Second> createState() => _SecondState();
}

class _SecondState extends State<Second> {

  final _controller = TextEditingController();

  final matrix = Matrix4.identity();

  @override
  void initState() {
    super.initState();

    _controller.text = "1111111111222222222233333333334444444444555555555566666666667777777777888888888899999999990000000000";
    matrix.translate(-150.0, 50.0);
    //matrix.rotateZ(.3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TextField'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [

              EditableText(
                controller: _controller,
                focusNode: FocusNode(),
                style: const TextStyle(
                  letterSpacing: 2,
                  fontSize: 40,
                  color: Colors.black,///.withOpacity(0),
                ),
                cursorColor: Colors.blue,
                backgroundCursorColor: Colors.red,
            )

              // Transform(
              //   transform: matrix,
              //   child: Row(
              //
              //     children: [
              //       SizedBox(
              //         width: 500,
              //         child: TextField(
              //           enabled: true,
              //           autocorrect: false,
              //           showCursor: true,
              //           cursorWidth: 1,
              //           controller: _controller,
              //
              //           onTap: () {
              //             print(matrix);
              //           },
              //
              //
              //
              //           style: TextStyle(
              //             letterSpacing: 2,
              //             fontSize: 40,
              //             color: Colors.black,///.withOpacity(0),
              //           ),
              //           maxLines: 3,
              //           textAlign: TextAlign.justify,
              //           decoration: const InputDecoration(
              //             border: InputBorder.none,
              //             // fillColor: Colors.transparent,
              //             // filled: true,
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
                // child: Text(
                //   _controller.text,
                //   maxLines: 2,
                //   style: TextStyle(
                //     letterSpacing: 2,
                //     fontSize: 40,
                //     color: Colors.black,///.withOpacity(0),
                //   ),
                // ),

                // child: Row(
                //   children: [
                //     Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: ElevatedButton(onPressed: () {}, child: const Text('1')),
                //     ),
                //     Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: ElevatedButton(onPressed: () {}, child: const Text('2')),
                //     ),
                //     Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: ElevatedButton(onPressed: () {}, child: const Text('3')),
                //     ),
                //     Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: ElevatedButton(onPressed: () {}, child: const Text('4')),
                //     ),
                //     Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: ElevatedButton(onPressed: () {}, child: const Text('5')),
                //     ),
                //     Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: ElevatedButton(onPressed: () {}, child: const Text('6')),
                //     ),
                //     Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: ElevatedButton(onPressed: () {}, child: const Text('7')),
                //     ),
                //     Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: ElevatedButton(onPressed: () {}, child: const Text('8')),
                //     ),
                //     Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: ElevatedButton(onPressed: () {}, child: const Text('9')),
                //     ),
                //     Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: ElevatedButton(onPressed: () {}, child: const Text('10')),
                //     ),
                //     Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: ElevatedButton(onPressed: () {}, child: const Text('11')),
                //     ),
                //     Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: ElevatedButton(onPressed: () {}, child: const Text('12')),
                //     ),
                //     Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: ElevatedButton(onPressed: () {}, child: const Text('13')),
                //     ),
                //     Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: ElevatedButton(onPressed: () {}, child: const Text('14')),
                //     ),
                //     Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: ElevatedButton(onPressed: () {}, child: const Text('15')),
                //     ),
                //     Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: ElevatedButton(onPressed: () {}, child: const Text('16')),
                //     ),
                //     Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: ElevatedButton(onPressed: () {}, child: const Text('17')),
                //     ),
                //     Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: ElevatedButton(onPressed: () {}, child: const Text('18')),
                //     ),
                //   ],
                // )

                // child: SizedBox(
                //   width: 500,
                //   height: 300,
                //   child: Container(
                //     color: Colors.red,
                //   )
                // ),
              // ),


            ],
          ),
        ),
      )
    );
  }
}
