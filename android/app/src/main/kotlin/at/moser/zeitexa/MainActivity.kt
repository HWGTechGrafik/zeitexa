package at.moser.zeitexa

import io.flutter.embedding.android.FlutterFragmentActivity

// FlutterFragmentActivity statt FlutterActivity: wird von local_auth
// (BiometricPrompt) vorausgesetzt.
class MainActivity : FlutterFragmentActivity()
