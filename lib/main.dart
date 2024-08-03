import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'pages/login_page.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  initializeDateFormatting().then((_) => runApp(const PlannerDeTarefas()));
}

class PlannerDeTarefas extends StatelessWidget {
  const PlannerDeTarefas({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Planner de Tarefas',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            useMaterial3: true,
            colorScheme:
                ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent)),
        home: const Login());
  }
}
