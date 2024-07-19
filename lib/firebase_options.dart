import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    } else {
      throw UnsupportedError(
        'DefaultFirebaseOptions are not supported for this platform.',
      );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyBBW3CY9-rWwz4fg4sIaciq4MAmOhC5wAw",
    authDomain: "chat-app-1c8d1.firebaseapp.com",
    projectId: "chat-app-1c8d1",
    storageBucket: "chat-app-1c8d1.appspot.com",
    messagingSenderId: "1039179997686",
    appId: "1:1039179997686:web:baa2132716b0a1703927d7",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyBBW3CY9-rWwz4fg4sIaciq4MAmOhC5wAw",
    appId: "1:1039179997686:web:baa2132716b0a1703927d7",
    messagingSenderId: "1039179997686",
    projectId: "chat-app-1c8d1",
    storageBucket: "chat-app-1c8d1.appspot.com",
  );

  
}
