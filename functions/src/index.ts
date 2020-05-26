import * as functions from 'firebase-functions';

// The Firebase Admin SDK to access Cloud Firestore.
const admin = require('firebase-admin');
admin.initializeApp();

const firebase = require('firebase-app');


// Must specify as = sender OR receiver
// Creates a new "test" record 
exports.createTest = functions.https.onRequest(async (req, res) => {

    const as = req.query.as;

    if (as!=='sender'&&as!=='receiver') {
        res.status(406).json({error: true, message: '"as" parameter must be sent as "sender" or "receiver"'});
        return;
    }

    console.log('I am also here !! -- I dont think this will happen .. ');

    firebase.auth().onAuthStateChanged(async function(user: any) {
        if (user) {
          // User is signed in.
          // const isAnonymous = user.isAnonymous;
          const uid = user.uid;

          let testData;
          if (as==='sender') {
              testData = {
                  sender : uid
              }
          } else {
              testData = {
                  receiver : uid
              }
          }
      
          // Push the new message into Cloud Firestore using the Firebase Admin SDK.
          const writeResult = await admin.firestore().collection('test').add(testData);
          
          // Send back a message that we've succesfully written the message
          res.json({result: `Message with ID: ${writeResult.id} added.`});

        } else {
            res.status(401).json({
                error: true,
                code: 99999,
                message: 'Unexpectedly logged out'
            });
        }
      });
      
      console.log('I made it to here !!');

      firebase.auth().signInAnonymously().catch(function(error: any) {
          res.status(401).json({
              error: true,
              code: error.code,
              message: error.message
          });
      });

      console.log('here I am at the bottom of the function !!!');
      
  });
