import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nawasena_mobile/app.dart';
import 'package:nawasena_mobile/core/network/api_client.dart';
import 'package:nawasena_mobile/core/utils/secure_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  ApiClient.instance.init();

  runApp(const NawasenaApp());
}