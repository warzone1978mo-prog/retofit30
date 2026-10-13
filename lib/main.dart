import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/retofit_app.dart';
import 'core/storage/local_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await LocalStorageService.create();
  runApp(RetoFitApp(storage: storage));
}
