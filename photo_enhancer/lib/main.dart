import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_enhancer/auth_manager.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: const HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Future<void> verifyIntegrity({required String integrityToken}) async {
    final urlString = 'http://192.168.1.23:5001/photo-enhancer-app-7022025/us-central1/verifyIntegrity';
    final dio = Dio();

    try {
      final response = await dio.post(
        urlString,
        data: {
          "integrityToken": integrityToken,
          "packageName": "com.photo_enhancer",
          "buildMode": kDebugMode ? "debug" : "release",
        },
      );

      if (response.statusCode == 200) {
        print("Integrity verified: ${response.data}");
      } else {
        print("Failed to verify integrity: ${response.data}");
      }
    } on DioException catch (e) {
      print("Error: $e");
    }
  }

  Future<void> createUser({required String accountId, required String androidId}) async {
    final urlString = 'http://192.168.1.23:5001/photo-enhancer-app-7022025/us-central1/createUser';
    final dio = Dio();

    try {
      final response = await dio.post(
        urlString,
        data: {
          "googleId": accountId,
          "androidId": androidId,
        },
      );

      if (response.statusCode == 200) {
        print("Data: ${response.data}");
      } else {
        print("Error: ${response.data}");
      }
    } on DioException catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();

    PhotoEnhancerChannel.getIntegrityToken().then((token) async {
      if (token != null) {
        await verifyIntegrity(integrityToken: token);
        final googleId = await AuthManager().signInWithGoogle();
        final androidId = await PhotoEnhancerChannel.getAndroidId();
        if (googleId != null && androidId != null) {
          createUser(accountId: googleId, androidId: androidId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Material App Bar'),
      ),
      body: const Center(
        child: Text('Hello World'),
      ),
    );
  }
}

class PhotoEnhancerChannel {
  static const MethodChannel _channel = MethodChannel('photoEnhancerChannel');

  static Future<String?> getIntegrityToken() async {
    try {
      final String? integrityToken = await _channel.invokeMethod('getIntegrityToken');
      return integrityToken;
    } on PlatformException catch (e) {
      print("Error getting integrity token: ${e.message}");
      return null;
    }
  }

  static Future<String?> getAndroidId() async {
    try {
      final String androidId = await _channel.invokeMethod('getAndroidId');
      return androidId;
    } on PlatformException catch (e) {
      print("Failed to get Android ID: '${e.message}'.");
      return null;
    }
  }
}
