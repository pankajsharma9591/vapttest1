import 'dart:io';

import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';

void main() {
  runApp(const MyApp());
}

String? deviceModel = "";

Future<bool> isRootedDevice() async {
  bool isRooted = false;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  String? deviceName = androidInfo.device;
  deviceModel = androidInfo.id;
  String? androidVersion = androidInfo.version.release;

  try {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    // Check for common root paths
    List<String> knownRootPaths = [
      "/system/app/Superuser.apk",
      "/sbin/su",
      "/system/bin/su",
      "/system/xbin/su",
      "/data/local/xbin/su",
      "/data/local/bin/su",
      "/system/sd/xbin/su",
      "/system/bin/failsafe/su",
      "/data/local/su"
    ];

    bool isRootedFileFound = knownRootPaths.any((String path) => File(path).existsSync());

    // Check if the device is running in an emulator (optional)
    bool isEmulator = androidInfo.isPhysicalDevice == false;

    // Combine checks to detect rooted devices
    isRooted = isRootedFileFound || isEmulator;
  } catch (e) {
    print("Error while checking root status: $e");
  }

  return isRooted;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder<bool>(
        future: isRootedDevice(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.hasError || snapshot.data == true) {
              // Device is rooted or running in an emulator, show an error message or navigate to an error screen.
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("This app cannot run on rooted devices."),
                      Text(deviceModel!, style: TextStyle(fontSize: 30),),
                    ],
                  ),
                ),
              );
            } else {
              // Device is not rooted, proceed with your app.
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Welcome to your app!"),
                      Text(deviceModel!, style: TextStyle(fontSize: 30),),
                    ],
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }
}
