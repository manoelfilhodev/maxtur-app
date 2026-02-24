import 'package:flutter/material.dart';
import 'package:systex_frotas/app.dart';
import 'package:systex_frotas/modules/auth/services/auth_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthStorage.init();
  runApp(const SystexFrotasApp());
}
