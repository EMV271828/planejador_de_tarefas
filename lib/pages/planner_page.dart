import 'package:flutter/material.dart';
import 'package:planner_de_tarefas/pages/pesquisar_tarefas_page.dart';
import 'package:planner_de_tarefas/pages/tarefas_recentes_page.dart';
import 'package:planner_de_tarefas/widgets/quadros_widget.dart';
import 'package:planner_de_tarefas/pages/tarefas_concluidas_page.dart';
import '../database.dart';

List<Widget> quadrosChildren = [];

class PlannerPage extends StatefulWidget {
  final String email;

  const PlannerPage(this.email, {super.key});

  @override
  State<StatefulWidget> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> {
  var data = PlannerDatabase();
  bool insercaoFeita = false;
  final _formKey = GlobalKey<FormState>();

  _atualizar() => setState(() {});

  _carregarQuadros() {
    return FutureBuilder(
        future: data.obterQuadrosDeTarefas(widget.email),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var lista = (snapshot.data!) as List;
            quadrosChildren = [
              for (int i = 0; i < lista.length; i++)
                QuadrosWidget(i, lista[i], _atualizar)
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

  _criarQuadro() {
    String? tarefaSelecionada;
    int? corSelecionada;
    Widget aviso = const Text('');
    bool action = true;

    return showDialog(
        context: context,
        barrierDismissible: action,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) =>
                AlertDialog(
                    title: const Text(
                      'Criação de Quadro',
                      textAlign: TextAlign.center,
                    ),
                    content: Form(
                      key: _formKey,
                      child: SizedBox(
                          width: 200,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              aviso,
                              Container(
                                margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                child: DropdownMenu(
                                  initialSelection: Tarefas.selecione,
                                  requestFocusOnTap: true,
                                  label: const Text('Nome da Tarefa'),
                                  onSelected: (Tarefas? tarefa) {
                                    tarefaSelecionada = tarefa?.nome;
                                    setState(() {});
                                  },
                                  inputDecorationTheme: const InputDecorationTheme(
                                      filled: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 5.0,
                                      )),
                                  dropdownMenuEntries: Tarefas.values
                                      .map<DropdownMenuEntry<Tarefas>>(
                                          (Tarefas tarefa) {
                                        return DropdownMenuEntry<Tarefas>(
                                            value: tarefa,
                                            label: tarefa.nome,
                                            leadingIcon: Icon(tarefa.icone));
                                      }).toList(),
                                ),
                              ),
                              Container(
                                  margin: const EdgeInsets.fromLTRB(
                                      0, 0, 0, 10),
                                  child: DropdownMenu(
                                    initialSelection: Cores.selecione,
                                    width: 220,
                                    requestFocusOnTap: true,
                                    label: const Text('Cor'),
                                    onSelected: (Cores? cor) {
                                      corSelecionada = cor?.index;
                                      setState(() {});
                                    },
                                    inputDecorationTheme:
                                    const InputDecorationTheme(
                                        filled: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 5.0,
                                        )),
                                    dropdownMenuEntries: Cores.values
                                        .map<DropdownMenuEntry<Cores>>((
                                        Cores cor) {
                                      return DropdownMenuEntry<Cores>(
                                          value: cor,
                                          label: cor.nome,
                                          style: MenuItemButton.styleFrom(
                                              foregroundColor: cor.cor));
                                    }).toList(),
                                  )),
                              Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: ElevatedButton(
                                      onPressed: !action ? null : () async {
                                        if ((corSelecionada != null &&
                                            corSelecionada != 0) &&
                                            (tarefaSelecionada != null &&
                                                tarefaSelecionada !=
                                                    'Selecione')) {

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

                                          var rslt = await data
                                              .criarQuadroDeTarefa(
                                              tarefaSelecionada!,
                                              corSelecionada!,
                                              widget.email);

                                          await Future.delayed(const Duration(seconds: 2), () {
                                            Navigator.pop(context);
                                            setState(() {});
                                          });

                                          if (context.mounted && rslt != 0) {
                                            action = false;
                                            aviso = Container(
                                              color: Colors.green,
                                              padding: const EdgeInsets.all(10),
                                              margin: const EdgeInsets.all(10),
                                              child: const Text(
                                                'Quadro criado!',
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight
                                                        .bold),
                                              ),
                                            );
                                            setState(() {});

                                            await Future.delayed(
                                              const Duration(seconds: 2), () {
                                              aviso = Container(
                                                color: Colors.green,
                                                padding: const EdgeInsets.all(10),
                                                margin: const EdgeInsets.all(10),
                                                child: const Text(
                                                  'Saindo...',
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight
                                                          .bold),
                                                ),
                                              );
                                              setState(() {});
                                            });

                                            await Future.delayed(
                                                const Duration(seconds: 2), () {
                                                  action = true;
                                              Navigator.pop(
                                                  context, 'Criar e Sair');
                                              _atualizar();
                                            });

                                          } else if (rslt == 0) {
                                            aviso = Container(
                                              color: Colors.red,
                                              padding: const EdgeInsets.all(10),
                                              margin: const EdgeInsets.all(10),
                                              child: const Text(
                                                'Falha na criação do quadro!',
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight
                                                        .bold),
                                              ),
                                            );
                                            setState(() {});
                                          }
                                          return;
                                        }
                                        aviso = Container(
                                          color: Colors.red,
                                          padding: const EdgeInsets.all(10),
                                          margin: const EdgeInsets.all(10),
                                          child: const Text(
                                            'Opções inválidas!',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        );
                                        setState(() {});
                                      },
                                      child: const Text('Criar')))
                            ],
                          )),
                    )),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quadro de Tarefas'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              _criarQuadro();
            },
            icon: const Icon(Icons.add),
            tooltip: 'Criar Quadro',
          ),

        ],
      ),
      body: _carregarQuadros(),
      bottomNavigationBar: BottomAppBar(
        height: 60,
        color: Theme
            .of(context)
            .primaryColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                onPressed: () {
                  Navigator.pop(context, 'Sair');
                },
                color: Colors.white,
                tooltip: 'Sair do App',
                icon: const Icon(Icons.close)),
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PesquisaTarefas(widget.email),
                    ),
                  );
                },
                tooltip: 'Pesquisar Tarefas',
                color: Colors.white,
                icon: const Icon(Icons.search_sharp)),
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TarefasRecentes(widget.email),
                    ),
                  );
                },
                color: Colors.white,
                tooltip: 'Tarefas Recentes',
                icon: const Icon(Icons.timer)),
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TarefasConcluidas(widget.email),
                    ),
                  );
                },
                tooltip: 'Tarefas Concluídas',
                color: Colors.white,
                icon: const Icon(Icons.done)),
          ],
        ),
      ),
    );
  }
}
