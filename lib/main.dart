import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart'; // Importar Firebase
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'src/app.dart';

// Convertimos el main en 'async' para poder esperar a que cargue Firebase
void main() async {
  // Aseguramos que el motor gráfico de Flutter esté listo antes de cargar nada más
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  await dotenv.load(fileName: ".env");

  // Encendemos Firebase (usa la config del google-services.json que pusiste antes)
  await Firebase.initializeApp();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
