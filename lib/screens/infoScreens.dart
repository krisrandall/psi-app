import 'package:flutter/material.dart';
import 'package:app/components/textcomponents.dart';
import 'package:app/models/psitest.dart';
import 'package:app/components/screenBackground.dart';

class ReceiverInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RightBgWrapper(Scaffold(
        appBar: AppBar(title: Text("Receiver")),
        body: Stack(children: [
          Image.asset(
            'assets/Receiver.jpg',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
          Center(
              child: CopyText(
                  '''As the Receiver you will be presented with a set of four different pictures.  

The Sender will be looking at one of those pictures and telepathically projecting a mental image of it to you.

Your job as the Receiver is to receive that mental image, and choose the picture that the Sender is sending by clicking on it.

There will be $DEFAULT_NUM_QUESTIONS sets of images in the test.
'''))
        ])));
  }
}

class SenderInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RightBgWrapper(Scaffold(
        appBar: AppBar(title: Text("Sender")),
        body: Stack(children: [
          Image.asset(
            'assets/Sender.jpg',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
          Center(
              child: CopyText(
                  '''As the Sender, your job is to send a mental image of what you see to the Receiver.  You will be presented with a series of images, one at a time.  Focus on each one and imagine describing that image to the Receiver.

    The Receiver should not be able to physically see or hear you, they need to receive the mental image you project to them telepathically and pick which image you are Sending.

    There will be $DEFAULT_NUM_QUESTIONS images in the test.
    '''))
        ])));
  }
}
