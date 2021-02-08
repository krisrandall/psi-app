const functions = require("firebase-functions");
const admin = require("firebase-admin");
const request = require('request');
admin.initializeApp();
const DEFAULT_NUM_QUESTIONS = 5;
const DEFAULT_IMAGE_SIZE = "400";

async function createOption() {
  return new Promise((resolve, reject) => {
    request(`${path}/${DEFAULT_IMAGE_SIZE}`, (error, response) => {
      if (error) reject(error + 'failed to get picture ID from picusm website');
      if (response.statusCode != 200) {
        reject('Invalid status code <' + response.statusCode + '>');
      }
      resolve(response.headers['picsum-id']);
    });
  }).then(
    (imageId) => {
      var option = `${path}/id/${imageId}/${DEFAULT_IMAGE_SIZE}`;
      return option;
    })
}

async function createTest() {
  try {
    var newQuestion;
    var questions = new Array();
    for (i = 0; i < DEFAULT_NUM_QUESTIONS; i++) {
      var correctAnswer = Math.floor(Math.random() * 4);
      var options = new Array();

      for (j = 0; j < 4; j++) {
        var imageId = await createOption();
        var newOption = `${path}/id/${imageId}/${DEFAULT_IMAGE_SIZE}`;
        options.push(newOption);
      }
      var newQuestion = { "options": options, "correctAnswer": correctAnswer }
      questions.push(newQuestion);
    };
    var test = {
      "parties": "",
      "questions": questions,
      "receiver": "",
      "sender": "",
      "status": "created",
    };
    return test;
  } catch (error) {
    console.log(`error occured when creating test ${error}`);
    const activities = admin.firestore().collection("activities");
    activities.add({ text: "an error occurred while trying to create a new test: ${err}" });
  }
}

exports.logTestCompleted = functions.firestore.document("/test/{id}")
  .onUpdate((change, context) => {
    const oldSnapshot = change.before.data();
    const newSnapshot = change.after.data();
    const oldStatus = oldSnapshot.status;
    const newStatus = newSnapshot.status;
    if (oldStatus == "underway" && newStatus == "completed") {
      const activities = admin.firestore().collection("activities");
      activities.add({ text: `a test was completed: ${id}`});
      const testCollection = admin.firestore().collection("test");
      newTest = createTest();
      createTest().then(
        (newTest) => {
          testCollection.add({ newTest });
        });
    }
    return null;
  });
