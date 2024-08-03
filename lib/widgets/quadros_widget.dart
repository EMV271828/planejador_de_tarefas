import 'package:flutter/material.dart';
import 'package:planner_de_tarefas/pages/tarefas_page.dart';
import '../database.dart';
import '../pages/planner_page.dart';

enum Cores {
  selecione('Selecione', Colors.black),
  azul('Azul', Colors.blue),
  amarelo('Amarelo', Colors.yellow),
  vermelho('Vermelho', Colors.red),
  verde('Verde', Colors.green),
  roxo('Roxo', Colors.deepPurple),
  laranja('Laranja', Colors.deepOrange);

  final String nome;
  final Color cor;

  const Cores(this.nome, this.cor);
}

enum Tarefas {
  selecione('Selecione', Icons.question_mark),
  trabalho('Trabalho', Icons.cases_rounded),
  saude('Saúde', Icons.health_and_safety),
  aprendizado('Aprendizado', Icons.book),
  rotinas('Rotinas', Icons.repeat_rounded),
  variados('Variados', Icons.add_box);

  final String nome;
  final IconData icone;

  const Tarefas(this.nome, this.icone);
}

var listaDeTarefas = (Tarefas.values.map((t) => t.nome)).toList();

class QuadrosWidget extends StatefulWidget {
  final int index;
  final elemento;
  final Function() _atualizarPai;

  const QuadrosWidget(this.index, this.elemento, this._atualizarPai,
      {super.key});

  @override
  State<StatefulWidget> createState() => QuadrosWidgetState();
}

class QuadrosWidgetState extends State<QuadrosWidget> {
  var data = PlannerDatabase();

  _obterTasks() async {
    return await data.obterTarefasDoQuadro(widget.elemento['id']) as List;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: const EdgeInsets.all(5),
        color: Cores.values[widget.elemento['color']].cor,
        child: SizedBox(
          height: 200,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      width: 250,
                      padding: const EdgeInsets.fromLTRB(35, 0, 0, 0),
                      child: Text(
                        Tarefas
                            .values[
                                listaDeTarefas.indexOf(widget.elemento['name'])]
                            .nome,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      )),
                  IconButton(
                      onPressed: () async {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return StatefulBuilder(
                                  builder: (context, setState) => AlertDialog(
                                        icon: const Icon(
                                            Icons.warning_amber_outlined,
                                            color: Colors.yellow,
                                            size: 40),
                                        title: const Text(
                                          'Aviso!',
                                          textAlign: TextAlign.justify,
                                        ),
                                        content: const Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                                "Esta ação não poderá ser desfeita. Deseja prosseguir?")
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () async {
                                              showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return const Center(
                                                    child: SizedBox(
                                                      width: 50,
                                                      height: 50,
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                                  );
                                                },
                                              );

                                              int rslt = await data
                                                  .deletarQuadroDeTarefa(
                                                      widget.elemento['id']);

                                              await Future.delayed(
                                                  const Duration(seconds: 2),
                                                  () {
                                                Navigator.pop(context);
                                                setState(() {});
                                              });

                                              if (rslt != 0 &&
                                                  context.mounted) {
                                                Navigator.pop(context);
                                                setState(() {});

                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        icon: const Icon(
                                                            Icons
                                                                .check_circle_outline,
                                                            color: Colors.green,
                                                            size: 40),
                                                        title: const Text(
                                                          "Operação",
                                                          textAlign:
                                                              TextAlign.justify,
                                                        ),
                                                        content: const Text(
                                                            "Operação concluída com sucesso!"),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context,
                                                                    'Sair'),
                                                            child: const Text(
                                                                'Sair'),
                                                          ),
                                                        ],
                                                      );
                                                    });

                                                quadrosChildren
                                                    .removeAt(widget.index);
                                                widget._atualizarPai();
                                                setState(() {});
                                              } else if (context.mounted) {
                                                Navigator.pop(context);
                                                setState(() {});

                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        icon: const Icon(
                                                            Icons
                                                                .error_outline_outlined,
                                                            color: Colors.red,
                                                            size: 40),
                                                        title: const Text(
                                                          "Operação",
                                                          textAlign:
                                                              TextAlign.justify,
                                                        ),
                                                        content: const Text(
                                                            "Falha na operação!"),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context,
                                                                    'Sair'),
                                                            child: const Text(
                                                                'Sair'),
                                                          ),
                                                        ],
                                                      );
                                                    });
                                                setState(() {});
                                              }
                                            },
                                            child: const Text('Sim'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, 'Sair'),
                                            child: const Text('Não'),
                                          )
                                        ],
                                      ));
                            });
                      },
                      tooltip: 'Deletar quadro',
                      icon: const Icon(Icons.close))
                ],
              ),
              Icon(
                Tarefas.values[listaDeTarefas.indexOf(widget.elemento['name'])]
                    .icone,
                size: 100,
              ),
              FutureBuilder(
                  future: _obterTasks(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List snap = snapshot.data as List;
                      if (snap.isNotEmpty) {
                        return Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                            ),
                            margin: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                            child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => TarefasPage(
                                          widget.elemento['name'],
                                          widget.elemento['color'],
                                          widget.elemento['id'],
                                          widget._atualizarPai),
                                    ),
                                  );
                                },
                                child: Text('${snap.length} tarefa(s)')));
                      }
                    }
                    return Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                        ),
                        margin: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                        child: TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => TarefasPage(
                                      widget.elemento['name'],
                                      widget.elemento['color'],
                                      widget.elemento['id'],
                                      widget._atualizarPai),
                                ),
                              );
                            },
                            child: const Text('Nenhuma tarefa')));
                  })
            ],
          ),
        ));
  }
}
