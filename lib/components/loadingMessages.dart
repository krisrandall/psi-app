import 'dart:math';

List<String> loadingMessages = [
  "Polishing crystal ball..",
  "Cleansing auras..",
  "Super charging neurons..",
  "Randomising...",
  "Thinking...",
  "Finding images..",
  "...",
  "Loading information..",
  "Resonating Polymorphisms..",
  "Collapsing quantum states..",
  "Determing differenials..",
  "Just fetching images..",
  "Doing HTTP POST request..",
  "Awaiting pic server..",
  "Burning sage..",
  "Reading the room..",
  "Initiating AI meditation..",
  "Shuffling answers.."
      "Thinking up snappy loading messages..",
  "Performing energy healing..",
];
getMessage() {
  var rng = new Random();
  int msgNum = rng.nextInt(loadingMessages.length);
  return loadingMessages[msgNum];
}
