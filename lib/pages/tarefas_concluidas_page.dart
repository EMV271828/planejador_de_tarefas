import 'package:flutter/material.dart';
import 'package:planner_de_tarefas/widgets/tarefas_concluidas.dart';
import '../database.dart';

class TarefasConcluidas extends StatefulWidget {
  const TarefasConcluidas(this.email, {super.key});
  final String email;

  @override
  State<TarefasConcluidas> createState() => _TarefasConcluidasState();
}

class _TarefasConcluidasState extends State<TarefasConcluidas> {
  tarefasConcluidas() {
    var data = PlannerDatabase();
    List<Widget> quadrosChildren = [];

    return FutureBuilder(
        future: data.obterTarefasConcluidas(widget.email),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var lista = (snapshot.data!) as List;
            quadrosChildren = [
              for (int i = 0; i < lista.length; i++)
                TarefasConcluidasWidget(lista[i])
            ];
          }
          return Center(
              child: Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: ListView(
                  shrinkWrap: true,
                  children: quadrosChildren,
                ),
              )
          );
        });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tarefas Concluídas'), centerTitle: true,),
      body: tarefasConcluidas()
    );
  }
}