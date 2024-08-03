import 'package:flutter/material.dart';
import 'package:planner_de_tarefas/database.dart';
import 'package:planner_de_tarefas/pages/tarefas_form_page.dart';
import 'package:planner_de_tarefas/widgets/tarefas_widget.dart';
import 'package:sqflite/sqflite.dart';

List<Widget> tarefasChildren = [];

class TarefasPage extends StatefulWidget {
  final String titulo;
  final cor;
  final int board_id;
  final Function() atualizarPlanner;

  const TarefasPage(this.titulo, this.cor, this.board_id, this.atualizarPlanner,
      {super.key});

  @override
  State<StatefulWidget> createState() => TarefasPageState();
}

class TarefasPageState extends State<TarefasPage> {
  var data = PlannerDatabase();

  _atualizar() => setState(() {});

  @override
  Widget build(BuildContext context) {
    _carregarTarefas() {
      return FutureBuilder(
          future: data.obterTarefasDoQuadro(widget.board_id),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var lista = (snapshot.data!) as List;
              tarefasChildren = [
                for (int i = 0; i < lista.length; i++)
                  TarefasWidget(i, lista[i], widget.cor, _atualizar)
              ];
            }
            return Center(
                child: Container(
                    margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child:
                        ListView(shrinkWrap: true, children: tarefasChildren)));
          });
    }

    _criarTarefas() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              TarefasFormPage(widget.board_id, _atualizar, false),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tarefas de ${widget.titulo}',
          style: const TextStyle(fontSize: 20),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            widget.atualizarPlanner();
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              _criarTarefas();
            },
            icon: const Icon(Icons.add),
            tooltip: 'Criar Tarefa',
          ),
        ],
      ),
      body: _carregarTarefas(),
    );
  }
}
