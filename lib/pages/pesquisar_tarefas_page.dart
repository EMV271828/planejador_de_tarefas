import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:planner_de_tarefas/widgets/tarefas_apenas_visualizacao_widget.dart';
import '../database.dart';

enum diasDaSemana {
  selecione("selecione", -1),
  domingo("Domingo", 0),
  segunda("Segunda-feira", 1),
  terca("Terça-feira", 2),
  quarta("Quarta-feira", 3),
  quinta("Quinta-feira", 4),
  sexta("Sexta-feira", 5),
  sabado("Sábado", 6);

  final int val;
  final String nome;

  const diasDaSemana(this.nome, this.val);
}

enum meses {
  selecione("selecione", -1),
  janeiro("Janeiro", 1),
  fevereiro("Fevereiro", 2),
  marco("Março", 3),
  abril("Abril", 4),
  maio("Maio", 5),
  junho("Junho", 6),
  julho("Julho", 7),
  agosto("Agosto", 8),
  setembro("Setembro", 9),
  outubro("Outubro", 10),
  novembro("Novembro", 11),
  dezembro("Dezembro", 12);

  final int val;
  final String nome;

  const meses(this.nome, this.val);
}

class PesquisaTarefas extends StatefulWidget {
  final String email;

  const PesquisaTarefas(this.email, {super.key});

  @override
  State<StatefulWidget> createState() => PesquisarTarefasState();
}

class PesquisarTarefasState extends State<PesquisaTarefas> {
  var data = PlannerDatabase();
  bool pesquisaEmProgresso = false;
  var busca;

  _realizarPesquisa(String dia, int? semana, int? mes) async {
    String? verificar = dia.isEmpty ? null : dia;
    semana = semana == -1 ? null : semana;
    mes = mes == -1 ? null : mes;

    busca = data.realizarPesquisa(widget.email, [verificar, semana, mes]);
  }

  _carregarResultado() {
    List<Widget> buscaChildren = [];
    return FutureBuilder(
        future: busca,
        builder: (context, snapshot) {
          if (pesquisaEmProgresso) {
            buscaChildren = [
              const Center(
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(),
                ),
              )
            ];
          } else if (snapshot.hasData) {
            var lista = (snapshot.data!) as List;
            if (lista.isNotEmpty) {
              buscaChildren = [
                for (int i = 0; i < lista.length; i++)
                  TarefasApenasVisualizacaoWidget(lista[i])
              ];
            } else {
              buscaChildren = [];
            }
          }
          return Center(
              child: Container(
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: ListView(
              shrinkWrap: true,
              children: buscaChildren,
            ),
          ));
        });
  }

  final _formKey = GlobalKey<FormState>();
  TextEditingController diaSelecionado = TextEditingController();
  int? semanaSelecionada;
  int? mesSelecionado;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Pesquisar Tarefas'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
            child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 270,
                  padding: const EdgeInsets.all(10),
                  child: TextFormField(
                    controller: diaSelecionado,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Dia',
                    ),
                    validator: (value) {
                      if (value!.isNotEmpty &&
                          (int.parse(value) < 1 || int.parse(value) > 31)) {
                        return 'Insira um valor entre 1 e 31';
                      }
                      return null;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2)
                    ],
                  )),
              Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.center,
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                  child: DropdownMenu(
                      initialSelection: diasDaSemana.selecione,
                      width: 250,
                      requestFocusOnTap: true,
                      label: const Text('Dias da Semana'),
                      onSelected: (diasDaSemana? d) {
                        semanaSelecionada = d?.val;
                        setState(() {});
                      },
                      inputDecorationTheme: const InputDecorationTheme(
                          filled: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 5.0,
                          )),
                      dropdownMenuEntries: diasDaSemana.values
                          .map<DropdownMenuEntry<diasDaSemana>>(
                              (diasDaSemana semana) {
                        return DropdownMenuEntry<diasDaSemana>(
                            value: semana, label: semana.nome);
                      }).toList())),
              Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.center,
                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                  child: DropdownMenu(
                      initialSelection: meses.selecione,
                      width: 250,
                      requestFocusOnTap: true,
                      label: const Text('Meses'),
                      onSelected: (meses? m) {
                        setState(() {
                          mesSelecionado = m?.val;
                        });
                      },
                      inputDecorationTheme: const InputDecorationTheme(
                          filled: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 5.0,
                          )),
                      dropdownMenuEntries: meses.values
                          .map<DropdownMenuEntry<meses>>((meses mes) {
                        return DropdownMenuEntry<meses>(
                            value: mes, label: mes.nome);
                      }).toList())),
              ElevatedButton(
                  onPressed: pesquisaEmProgresso
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            if (diaSelecionado.text.isEmpty &&
                                (semanaSelecionada == -1 ||
                                    semanaSelecionada == null) &&
                                (mesSelecionado == -1 ||
                                    mesSelecionado == null)) {
                              showDialog(
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
                                          "Preencha pelo menos uma das opções"),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, 'Sair'),
                                          child: const Text('Sair'),
                                        ),
                                      ],
                                    );
                                  });

                              return;
                            }


                            pesquisaEmProgresso = true;
                            setState(() {});

                            _realizarPesquisa(diaSelecionado.text,
                                semanaSelecionada, mesSelecionado);

                            await Future.delayed(
                                const Duration(seconds: 2), () {
                              pesquisaEmProgresso = false;
                              setState(() {});
                            });

                            if ((await busca as List).isEmpty &&
                                context.mounted) {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      icon: const Icon(
                                          Icons.warning_amber_outlined,
                                          color: Colors.yellow,
                                          size: 40),
                                      title: const Text(
                                        "Aviso!",
                                        textAlign: TextAlign.justify,
                                      ),
                                      content:
                                      const Text("Pesquisa sem resultado"),
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
                          }
                        },
                  child: const Text('Pesquisar')),
              _carregarResultado()
            ],
          ),
        )));
  }
}
