import 'package:flutter/material.dart';
import 'package:app/components/textcomponents.dart';
import 'package:app/models/psitest.dart';

class ReceiverInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CopyText(
        '''As the Receiver you will be presented with a set of four different pictures.  

The Sender will be looking at one of those pictures and telepathically projecting a mental image of it to you.

Your job as the Receiver is to receive that mental image, and choose the picture that the Sender is sending by clicking on it.

There will be $DEFAULT_NUM_QUESTIONS sets of images in the test.
''');
  }
}
