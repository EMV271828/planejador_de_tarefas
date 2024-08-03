import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planner_de_tarefas/pages/tarefas_form_page.dart';
import 'package:planner_de_tarefas/widgets/quadros_widget.dart';
import 'package:planner_de_tarefas/pages/tarefas_page.dart';
import '../database.dart';

class TarefasWidget extends StatefulWidget {
  final int index;
  final elemento;
  final int cor;
  final Function() _atualizarPai;

  const TarefasWidget(this.index, this.elemento, this.cor, this._atualizarPai,
      {super.key});

  @override
  State<StatefulWidget> createState() => TarefasWidgetState();
}

class TarefasWidgetState extends State<TarefasWidget> {
  var data = PlannerDatabase();

  String _formatarDatas(String data) {
    return DateFormat('dd/MM/yyyy').format(DateTime.parse(data));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: const EdgeInsets.all(5),
        color: Cores.values[widget.cor].cor,
        child: SizedBox(
          height: 250,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 250,
                    padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                    child: Text(
                      widget.elemento['title'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                  ),
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

                                              int rslt =
                                                  await data.deletarTarefa(
                                                      widget
                                                          .elemento['board_id'],
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

                                                tarefasChildren
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
                      tooltip: 'Deletar tarefa',
                      icon: const Icon(Icons.close))
                ],
              ),
              Container(
                width: 250,
                margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Text(
                  'Descrição: ${widget.elemento['note']}',
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Container(
                width: 250,
                margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Text(
                  'Data: ${_formatarDatas(widget.elemento['date'])}',
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Container(
                width: 250,
                margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Text(
                  'Data inicial: ${_formatarDatas(widget.elemento['startTime'])}',
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Container(
                width: 250,
                margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Text(
                  'Data final: ${_formatarDatas(widget.elemento['endTime'])}',
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      width: 110,
                      margin: const EdgeInsets.fromLTRB(0, 20, 10, 0),
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => TarefasFormPage(
                                  widget.elemento['board_id'],
                                  widget._atualizarPai,
                                  true,
                                  dadosDaTarefa: widget.elemento,
                                ),
                              ),
                            );
                          },
                          child: const Text('Editar'))),
                  Container(
                      width: 110,
                      margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: ElevatedButton(
                          onPressed: () async {
                            Widget aviso = const Text(
                                "Esta ação não poderá ser desfeita. Deseja prosseguir?");
                            String titulo = "Atenção";
                            Icon icon = const Icon(Icons.warning_amber,
                                color: Colors.yellow, size: 40);
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return StatefulBuilder(
                                      builder: (context, setState) =>
                                          AlertDialog(
                                            icon: icon,
                                            title: Text(
                                              titulo,
                                              textAlign: TextAlign.justify,
                                            ),
                                            content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  aviso,
                                                ]),
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
                                                      .concluirTarefa(widget
                                                          .elemento['id']);

                                                  await Future.delayed(
                                                      const Duration(
                                                          seconds: 2), () {
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
                                                                color: Colors
                                                                    .green,
                                                                size: 40),
                                                            title: const Text(
                                                              "Operação",
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                            content: const Text(
                                                                "Operação concluída com sucesso!"),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        context,
                                                                        'Sair'),
                                                                child:
                                                                    const Text(
                                                                        'Sair'),
                                                              ),
                                                            ],
                                                          );
                                                        });

                                                    tarefasChildren
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
                                                                color:
                                                                    Colors.red,
                                                                size: 40),
                                                            title: const Text(
                                                              "Operação",
                                                              textAlign:
                                                                  TextAlign
                                                                      .justify,
                                                            ),
                                                            content: const Text(
                                                                "Falha na operação!"),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        context,
                                                                        'Sair'),
                                                                child:
                                                                    const Text(
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
                                                onPressed: () => Navigator.pop(
                                                    context, 'Sair'),
                                                child: const Text('Não'),
                                              )
                                            ],
                                          ));
                                });
                          },
                          child: const Text('Concluir'))),
                ],
              )
            ],
          ),
        ));
  }
}
