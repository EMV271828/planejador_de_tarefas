import 'package:flutter/material.dart';
import '../database.dart';
import 'planner_page.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var db = PlannerDatabase();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailLogin = TextEditingController();
  final TextEditingController _senhaLogin = TextEditingController();

  _logar() async {
    if (_emailLogin.text.trim().isEmpty || _senhaLogin.text.trim().isEmpty) {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              icon:
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
              title: const Text(
                "Erro!",
                textAlign: TextAlign.justify,
              ),
              content: const Text("Campo(s) em branco"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Sair'),
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

    var busca =
        await db.verificarUsuarioNoLogin(_emailLogin.text, _senhaLogin.text);

    await Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      setState(() {});
    });

    if (context.mounted) {
      if (busca.isEmpty) {
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
                content: const Text("Email ou senha inválidos"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Sair'),
                    child: const Text('Sair'),
                  ),
                ],
              );
            });
      }

      String email = _emailLogin.text;
      _emailLogin.text = '';
      _senhaLogin.text = '';

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PlannerPage(email),
        ),
      );

    }
  }

  _cadastrar() async {
    final TextEditingController _nomeCadastro = TextEditingController();
    final TextEditingController _emailCadastro = TextEditingController();
    final TextEditingController _senhaCadastro = TextEditingController();
    Widget aviso = const Text('');

    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                    title: const Text(
                      'Cadastro de Usuário',
                      textAlign: TextAlign.center,
                    ),
                    content: Form(
                      key: _formKey,
                      child: SizedBox(
                          width: 300,
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                            aviso,
                            Padding(
                                padding: const EdgeInsets.all(2),
                                child: TextFormField(
                                  controller: _nomeCadastro,
                                  validator: (value) {
                                    if (value!.trim().isEmpty) {
                                      return 'Digite algum valor';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Nome',
                                    icon: Icon(Icons.account_box),
                                  ),
                                )),
                            Padding(
                                padding: const EdgeInsets.all(2),
                                child: TextFormField(
                                  controller: _emailCadastro,
                                  validator: (value) {
                                    if (value!.trim().isEmpty) {
                                      return 'Digite algum valor';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Email',
                                    icon: Icon(Icons.email),
                                  ),
                                )),
                            Padding(
                                padding: const EdgeInsets.all(2),
                                child: TextFormField(
                                  controller: _senhaCadastro,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Digite algum valor';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Senha',
                                    icon: Icon(Icons.password),
                                  ),
                                )),
                            Padding(
                                padding: const EdgeInsets.all(10),
                                child: ElevatedButton(
                                    onPressed: () async {
                                      if (_formKey.currentState!.validate()) {

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

                                        int rslt = await db.cadastarUsuario(
                                            _nomeCadastro.text,
                                            _emailCadastro.text,
                                            _senhaCadastro.text);

                                        await Future.delayed(const Duration(seconds: 2), () {
                                          Navigator.pop(context);
                                          setState(() {});
                                        });

                                        rslt != 0
                                            ? aviso = Container(
                                                color: Colors.green,
                                                padding:
                                                    const EdgeInsets.all(10),
                                                margin:
                                                    const EdgeInsets.all(10),
                                                child: const Text(
                                                    'Cadastro realizado com sucesso!',
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold)))
                                            : aviso = Container(
                                                color: Colors.red,
                                                padding:
                                                    const EdgeInsets.all(10),
                                                margin:
                                                    const EdgeInsets.all(10),
                                                child: const Text(
                                                  'Usuário já cadastrado!',
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              );
                                        setState(() {});
                                      }
                                    },
                                    child: const Text('Cadastrar'))),
                          ])),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context, 'Sair');
                          },
                          child: const Text('Sair'))
                    ],
                  ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Planner de Tarefas',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
              width: 450,
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: _emailLogin,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Digite seu email',
                    ),
                  ))),
          SizedBox(
              width: 450,
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: _senhaLogin,
                    obscureText: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Digite sua senha',
                    ),
                  ))),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  width: 110,
                  margin: const EdgeInsets.fromLTRB(0, 20, 10, 0),
                  child: ElevatedButton(
                      onPressed: () {
                        _logar();
                        setState(() {});
                      },
                      child: const Text('Login'))),
              Container(
                  width: 110,
                  margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: ElevatedButton(
                      onPressed: () {
                        _cadastrar();
                        setState(() {});
                      },
                      child: const Text('Cadastrar'))),
            ],
          )
        ],
      ),
    );
  }
}
