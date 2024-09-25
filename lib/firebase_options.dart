import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
      apiKey: "AIzaSyA49wbh5RcFniQU-iJr_NKua6ix3OPf7MQ",
      authDomain: "teamapp-21008.firebaseapp.com",
      projectId: "teamapp-21008",
      storageBucket: "teamapp-21008.appspot.com",
      messagingSenderId: "76172394715",
      appId: "1:76172394715:web:0e1052e8936874f491ccfe",
      measurementId: "G-8CMMTG3R8E");
}
