import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../database.dart';

class TarefasFormPage extends StatefulWidget {
  final int board_id;
  final Function() atualizarPai;
  final bool editar;
  var dadosDaTarefa;

  TarefasFormPage(this.board_id, this.atualizarPai, this.editar,
      {super.key, this.dadosDaTarefa});

  @override
  State<StatefulWidget> createState() => TarefasFormPageState();
}

class TarefasFormPageState extends State<TarefasFormPage> {
  var data = PlannerDatabase();
  final _formKey = GlobalKey<FormState>();
  TextEditingController titulo = TextEditingController();
  TextEditingController descricao = TextEditingController();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<dynamic>> tarefasPorDia = {};
  Set<DateTime> _selectedDays = {};
  final ValueNotifier<List<dynamic>> _tarefasSelecionadas = ValueNotifier([]);

  @override
  initState() {
    super.initState();
    _getTarefas();
    if (widget.editar) {
      titulo.text = widget.dadosDaTarefa['title'];
      descricao.text = widget.dadosDaTarefa['note'];
      _focusedDay =
          DateTime.parse("${widget.dadosDaTarefa['endTime']}T00:00:00Z");
      _selectedDays = {
        DateTime.parse("${widget.dadosDaTarefa['startTime']}T00:00:00Z"),
        DateTime.parse("${widget.dadosDaTarefa['endTime']}T00:00:00Z"),
      };
      _tarefasSelecionadas.value = _getTarefasPorDia(_selectedDays.first);
    }else {
      _tarefasSelecionadas.value = _getTarefasPorDia(_focusedDay);
    }
  }

  _getTarefasPorDia(DateTime day) {
    return tarefasPorDia[day] ?? [];
  }

  _getTarefas() async {
    var x = await data.obterTarefas() as List<Map<String, dynamic>>;
    for (int i = 0; i < x.length; i++) {
      if(!tarefasPorDia.containsKey(DateTime.parse("${x[i]['startTime']}T00:00:00Z"))){
        tarefasPorDia[DateTime.parse("${x[i]['startTime']}T00:00:00Z")] = [x[i]];
      }else{
        tarefasPorDia[DateTime.parse("${x[i]['startTime']}T00:00:00Z")]?.add(x[i]);
      }
    }
    setState(() {});
  }

  _limparCampos() {
    titulo.text = '';
    descricao.text = '';
    _focusedDay = DateTime.now();
    _selectedDays = {};
  }

  _daySelection(DateTime d, DateTime f) {
    setState(() {
      _focusedDay = f;
      if (_selectedDays.contains(d)) {
        _selectedDays.remove(d);
      } else if (_selectedDays.length < 2) {
        _selectedDays.add(d);
      }
    });
    if (_selectedDays.isNotEmpty) {
      _tarefasSelecionadas.value = _getTarefasPorDia(_selectedDays.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: widget.editar
              ? const Text('Edição de Tarefa')
              : const Text('Criação de Tarefa'),
          centerTitle: true,
        ),
        body: Center(
            child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextFormField(
                      controller: titulo,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Digite algum valor';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Título',
                        icon: Icon(Icons.title),
                      ),
                    )),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    controller: descricao,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Digite algum valor';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Descrição',
                      icon: Icon(Icons.text_fields),
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.black,
                ),
                const Text(
                  'Escolha duas datas',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.fromLTRB(0, 5, 0, 20),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2010, 10, 16),
                    lastDay: DateTime.utc(2030, 3, 14),
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    eventLoader: (day) {
                      return _getTarefasPorDia(day);
                    },
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Month'
                    },
                    selectedDayPredicate: (day) {
                      return _selectedDays.contains(day);
                    },
                    focusedDay: _focusedDay,
                    locale: 'pt_BR',
                    onDaySelected: _daySelection,
                  ),
                ),
                const Divider(
                  color: Colors.black,
                ),
                const Text(
                  'Lista de Eventos',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                _tarefasSelecionadas.value.isEmpty
                    ? const Text('Nenhum evento selecionado')
                    : SingleChildScrollView(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                        ValueListenableBuilder(
                            valueListenable: _tarefasSelecionadas,
                            builder: (context, value, _) {
                              return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: value.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 12.0,
                                        vertical: 4.0,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      child: ListTile(
                                        title: Text(
                                            'Título: ${value[index]['title']}'),
                                        subtitle: Text(
                                            'Descrição: ${value[index]['note']}\n'
                                            'Data de início: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(value[index]['startTime']))}\n'
                                            'Data de término: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(value[index]['endTime']))}\n'
                                            'Concluída? ${value[index]['isCompleted'] == 1 ? "Sim" : "Não"}'),
                                        tileColor: Colors.orange,
                                      ),
                                    );
                                  });
                            })
                      ])),
                const Divider(
                  color: Colors.black,
                ),
                SizedBox(
                    width: 500,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              if (_selectedDays.length < 2) {
                                return showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        icon: const Icon(Icons.error_outline,
                                            color: Colors.red, size: 40),
                                        title: const Text(
                                          "Erro!",
                                          textAlign: TextAlign.justify,
                                        ),
                                        content: const Text(
                                            "Selecione dois valores do calendário"),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, 'Sair'),
                                            child: const Text('Sair'),
                                          ),
                                        ],
                                      );
                                    });
                              }

                              if (_selectedDays.first.day <=
                                      DateTime.now().day ||
                                  _selectedDays.last.day <= DateTime.now().day) {
                                return showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        icon: const Icon(Icons.error_outline,
                                            color: Colors.red, size: 40),
                                        title: const Text(
                                          "Erro!",
                                          textAlign: TextAlign.justify,
                                        ),
                                        content: const Text(
                                            "Selecione dois dias após a data atual"),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, 'Sair'),
                                            child: const Text('Sair'),
                                          ),
                                        ],
                                      );
                                    });
                              }

                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) {
                                  return const Center(
                                    child: SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                },
                              );

                              var dateList = _selectedDays.toList();
                              dateList.sort();

                              var rslt;

                              if (!widget.editar) {
                                rslt = await data.inserirTarefas(
                                    widget.board_id,
                                    titulo.text,
                                    DateFormat('yyyy-MM-dd')
                                        .format(DateTime.now()),
                                    DateFormat('yyyy-MM-dd')
                                        .format(dateList[0]),
                                    DateFormat('yyyy-MM-dd')
                                        .format(dateList[1]),
                                    descricao.text);
                              } else {
                                rslt = await data.atualizarTarefa(
                                    widget.dadosDaTarefa['id'],
                                    widget.board_id,
                                    titulo.text,
                                    DateFormat('yyyy-MM-dd')
                                        .format(DateTime.now()),
                                    DateFormat('yyyy-MM-dd')
                                        .format(dateList[0]),
                                    DateFormat('yyyy-MM-dd')
                                        .format(dateList[1]),
                                    descricao.text);
                              }

                              await Future.delayed(const Duration(seconds: 2),
                                  () {
                                Navigator.pop(context);
                                setState(() {});
                              });

                              if (context.mounted && rslt != 0) {
                                widget.atualizarPai();
                                return showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          icon: const Icon(
                                              Icons.check_circle_outline,
                                              color: Colors.green,
                                              size: 40),
                                          title: const Text(
                                            "Sucesso!",
                                            textAlign: TextAlign.justify,
                                          ),
                                          content: (widget.editar)
                                              ? const Text("Tarefa Editada!")
                                              : const Text("Tarefa Criada!"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, 'Sair');
                                                if (!widget.editar) {
                                                  _limparCampos();
                                                }
                                                widget.atualizarPai();
                                                setState(() {});
                                              },
                                              child: const Text('Sair'),
                                            ),
                                          ],
                                        ));
                              }
                            }
                          },
                          child: (widget.editar)
                              ? const Text('Editar')
                              : const Text('Criar')),
                    ))
              ],
            ),
          ),
        )));
  }
}
