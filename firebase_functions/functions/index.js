const functions = require("firebase-functions");
const admin = require("firebase-admin");
const request = require("request");
admin.initializeApp();
const DEFAULT_NUM_QUESTIONS = 5;
const DEFAULT_IMAGE_SIZE = "400";
const path = "https://picsum.photos";

/** fetch an address for a random photo from picsum photos */
async function createOption() {
  return new Promise((resolve, reject) => {
    request(`${path}/${DEFAULT_IMAGE_SIZE}`, (error, response) => {
      if (error) {
        reject(Error( "failed to get picture ID from picusm website"));
      }
      resolve(response.headers["picsum-id"]);
    });
  },
  ).then(
      (imageId) => {
        const option = `${path}/id/${imageId}/${DEFAULT_IMAGE_SIZE}`;
        return option;
      });
}

/** create a PsiTest object */
async function createTest() {
  try {
    const questions = [];
    for (let i = 0; i < DEFAULT_NUM_QUESTIONS; i++) {
      const correctAnswer = Math.floor(Math.random() * 4);
      const options = [];

      for (let j = 0; j < 4; j++) {
        const imageId = await createOption();
        const newOption = `${path}/id/${imageId}/${DEFAULT_IMAGE_SIZE}`;
        options.push(newOption);
      }
      const newQuestion = {"options": options, "correctAnswer": correctAnswer};
      questions.push(newQuestion);
    }
    const test = {
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
    activities.add({
      text: "an error occurred while trying to create a new test: ${err}"});
  }
}

exports.createTestOnTestCompleted = functions.firestore.document("/test/{id}")
    .onUpdate((change, context) => {
      const oldSnapshot = change.before.data();
      const newSnapshot = change.after.data();
      const oldStatus = oldSnapshot.status;
      const newStatus = newSnapshot.status;
      if (oldStatus == "underway" && newStatus == "completed") {
        const activities = admin.firestore().collection("activities");
        activities.add({text: "a test was completed"});
        const testCollection = admin.firestore().collection("test");

        createTest().then(
            (newTest) => {
              testCollection.add(newTest);
              return newTest;
            });
      }
      return true;
    });

exports.createTestOnTestDeleted = functions.firestore.document("/test/{id}")
    .onDelete((snapshot, context) => {
      const testCollection = admin.firestore().collection("test");

      createTest().then(
          (newTest) => {
            testCollection.add(newTest);
            return newTest;
          });

      return true;
    });
