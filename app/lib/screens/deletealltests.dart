/*import 'package:app/bloc/psitestsave_bloc.dart';
import 'package:app/components/button.dart';
import 'package:app/components/textComponents.dart';
import 'package:app/models/psiTest.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app/components/livePsiTestStream.dart';
import 'package:app/components/screenBackground.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Query allCompletedTests = Firestore.instance
    .collection('test')
    .where("parties", arrayContains: 'dmjbXZ7BHEUizVeQre2lmry5q982');

class DeleteAllTests extends StatelessWidget {
  DeleteAllTests();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('𝚿 Psi Telepathy Test'),
        ),
        body: TableBgWrapper(StreamBuilder<QuerySnapshot>(
            stream: allCompletedTests.snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return new Text('Error: ${snapshot.error}');
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                Future.delayed(Duration(milliseconds: 300)).then(
                    (value) => CopyText("Fetching existing test data .."));
                return Container();
              } else {
                List<DocumentSnapshot> documents = snapshot.data.documents;
                if (!snapshot.hasData) return CopyText("no data");
                if (documents.length == 0)
                  return Column(children: [
                    CopyText('no completed tests left'),
                    Button('return to home', () {
                      Navigator.pop(context);
                    })
                  ]);
                else {
                  var testToDelete =
                      createTestFromFirestore([snapshot.data.documents[0]]);
                  return _DeleteAllTests(testToDelete);
                }
              }
            })));
  }
}

class _DeleteAllTests extends StatelessWidget {
  final PsiTest testToDelete;
  _DeleteAllTests(this.testToDelete);
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Button('delete a completed test', () {
      var event = CancelPsiTest(test: testToDelete);
      BlocProvider.of<PsiTestSaveBloc>(context).add(event);
    }));
  }
}
*/
