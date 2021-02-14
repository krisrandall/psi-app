const functions = require("firebase-functions");
const admin = require("firebase-admin");
const request = require("request");
admin.initializeApp();

const DEFAULT_NUM_QUESTIONS = 5;
const DEFAULT_IMAGE_SIZE = "400";
const path = "https://picsum.photos";

/** fetch an address for a random photo from picsum photos */
async function getImageID() {
  return new Promise((resolve, reject) => {
    request(`${path}/${DEFAULT_IMAGE_SIZE}`, (error, response) => {
      if (error) {
        reject(Error( "failed to get picture ID from picusm website" + error));
      } else {
        resolve(response.headers["picsum-id"]);
      }
    });
  },
  );
}

/** create a PsiTest object */
async function createTest() {
  try {
    const questions = [];
    for (let i = 0; i < DEFAULT_NUM_QUESTIONS; i++) {
      const correctAnswer = Math.floor(Math.random() * 4);
      const options = [];

      for (let j = 0; j < 4; j+=0) {
        await getImageID().then((imageID) => {
          if (imageID == "0" || imageID == "1" || imageID == null) {
            console.error("error while getting imageID, trying again");
          } else {
            const newOption = `${path}/id/${imageID}/${DEFAULT_IMAGE_SIZE}`;
            options.push(newOption);
            j++;
            console.log(`imageID succesfuly retrieved from Picsum: ${imageID}`);
          }
        });
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
              const docref = testCollection.add(newTest);
              console.log(`created new test with ID: ${docref}`);
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
