import 'package:flutter/material.dart';
import '../database.dart';
import '../widgets/tarefas_apenas_visualizacao_widget.dart';

class TarefasRecentes extends StatefulWidget {
  const TarefasRecentes(this.email, {super.key});
  final String email;

  @override
  State<TarefasRecentes> createState() => _TarefasRecentesState();
}

class _TarefasRecentesState extends State<TarefasRecentes> {

  tarefasRecentes() {
    var data = PlannerDatabase();
    List<Widget> quadrosChildren = [];

    return FutureBuilder(
        future: data.obterTarefasRecentes(widget.email),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var lista = (snapshot.data!) as List;
            quadrosChildren = [
              for (int i = 0; i < lista.length; i++)
                TarefasApenasVisualizacaoWidget(lista[i])
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
        appBar: AppBar(title: const Text('Tarefas Recentes'), centerTitle: true,),
        body: tarefasRecentes()
    );
  }
}