import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

//////////////////////////////MODELOS//////////////////////////////////////

class UsuarioTable {
  final String name;
  final String email;
  final String password;

  const UsuarioTable(this.name, this.email, this.password);

  Map<String, String> toMap() {
    return {'name': name, 'email': email, 'password': password};
  }
}

class QuadroTable {
  final int user_id;
  final String name;
  final int color;

  const QuadroTable(this.name, this.color, this.user_id);

  Map<String, dynamic> toMap() {
    return {'name': name, 'color': color, 'user_id': user_id};
  }
}

class TarefaTable {
  final int board_id;
  final String title;
  final String date;
  final String startTime;
  final String endTime;
  final String note;
  final int isCompleted;

  const TarefaTable(this.board_id, this.title, this.date, this.startTime,
      this.endTime, this.note, this.isCompleted);

  toMap() {
    return {
      'board_id': board_id,
      'title': title,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'note': note,
      'isCompleted': isCompleted
    };
  }
}

class TarefaConcluidaTable {
  final int user_id;
  final String title;
  final String date;
  final String startTime;
  final String endTime;
  final String note;
  final int isCompleted;

  const TarefaConcluidaTable(this.user_id, this.title, this.date,
      this.startTime, this.endTime, this.note, this.isCompleted);

  toMap() {
    return {
      'user_id': user_id,
      'title': title,
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
      'note': note,
      'isCompleted': isCompleted
    };
  }
}

//////////////////////////////////BANCO DE DADOS//////////////////////////////////

class PlannerDatabase {
  Database? data;

  initDatabase() async {
    data = await openDatabase(
        join(await getDatabasesPath(), 'planner_de_tarefas.db'),
        onCreate: (db, version) async {
      await db.execute('CREATE TABLE user('
          'id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'name VARCHAR NOT NULL,'
          'email VARCHAR NOT NULL,'
          'password VARCHAR NOT NULL)');

      await db.execute('CREATE TABLE task_board('
          'id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'user_id INTEGER NOT NULL,'
          'name VARCHAR NOT NULL,'
          'color INTEGER NOT NULL,'
          'FOREIGN KEY(user_id) REFERENCES user(id))');

      await db.execute('CREATE TABLE task('
          'id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'board_id INTEGER NOT NULL,'
          'title VARCHAR NOT NULL,'
          'note TEXT NOT NULL,'
          'date VARCHAR NOT NULL,'
          'startTime VARCHAR NOT NULL,'
          'endTime VARCHAR NOT NULL,'
          'isCompleted INTEGER,'
          'FOREIGN KEY(board_id) REFERENCES task_board(id))');

      await db.execute('CREATE TABLE completed_task('
          'id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'user_id INTEGER NOT NULL,'
          'title VARCHAR NOT NULL,'
          'note TEXT NOT NULL,'
          'date VARCHAR NOT NULL,'
          'startTime VARCHAR NOT NULL,'
          'endTime VARCHAR NOT NULL,'
          'isCompleted INTEGER,'
          'FOREIGN KEY(user_id) REFERENCES user(id))');
    }, version: 1);
  }

  ///////////////////////LOGIN E CADASTRO///////////////////////////////////////

  verificarUsuarioNoLogin(String email, String senha) async {
    await initDatabase();
    return await data?.query('user',
        columns: ['id', 'name', 'email', 'password'],
        where: 'email = ? and password = ?',
        whereArgs: [email, senha]);
  }

  _verificarUsuarioCadastrado(String email) async {
    var busca = await data?.query('user',
        columns: ['email'], where: 'email = ?', whereArgs: [email]);

    return busca?.isEmpty;
  }

  Future<int> cadastarUsuario(String nome, String email, String senha) async {
    await initDatabase();
    if (!await _verificarUsuarioCadastrado(email)) return 0;
    var valores = UsuarioTable(nome, email, senha).toMap();
    return await data!.insert('user', valores);
  }

  ////////////////////QUADRO DE TAREFAS//////////////////////////////////

  criarQuadroDeTarefa(String nome, int index, String email) async {
    await initDatabase();

    var buscaUsuario = await data?.query('user',
        columns: ['id', 'email', 'name'],
        where: 'email = ?',
        whereArgs: [email]) as List;

    var valores = QuadroTable(nome, index, buscaUsuario[0]['id']).toMap();

    return await data?.insert('task_board', valores);
  }

  deletarQuadroDeTarefa(int id) async {
    await initDatabase();
    return await data?.delete('task_board', where: 'id = ?', whereArgs: [id]);
  }

  obterQuadrosDeTarefas(String email) async {
    await initDatabase();

    var buscaUsuario = await data?.query('user',
        columns: ['id', 'email', 'name'],
        where: 'email = ?',
        whereArgs: [email]);

    var rslt = await data!.query('task_board',
        columns: ['id', 'user_id', 'name', 'color'],
        where: 'user_id = ?',
        whereArgs: [buscaUsuario?[0]['id']]);

    return rslt;
  }

  ///////////////////////////TAREFAS//////////////////////////////////

  obterTarefasDoQuadro(int board_id) async {
    await initDatabase();

    var rslt = await data!.query('task',
        columns: [
          'id',
          'board_id',
          'title',
          'note',
          'date',
          'startTime',
          'endTime',
          'isCompleted'
        ],
        where: 'board_id = ? and isCompleted = ?',
        whereArgs: [board_id, 0],
        orderBy: 'startTime');

    return rslt;
  }

  inserirTarefas(int board_id, String title, String date, startTime,
      String endTime, String note) async {
    await initDatabase();

    var valores =
        TarefaTable(board_id, title, date, startTime, endTime, note, 0).toMap();

    return await data!.insert('task', valores);
  }

  concluirTarefa(int id) async {
    await initDatabase();
    var buscaTarefa = await data?.query('task',
        columns: [
          'id',
          'board_id',
          'title',
          'note',
          'date',
          'startTime',
          'endTime',
          'isCompleted'
        ],
        where: 'id = ?',
        whereArgs: [id]) as List;

    var buscarTabela = await data!.query('task_board',
        columns: ['id', 'user_id', 'name', 'color'],
        where: 'id = ?',
        whereArgs: [buscaTarefa[0]['board_id']]) as List;

    await deletarTarefa(buscaTarefa[0]['board_id'], id);

    return await data?.insert(
        'completed_task ',
        TarefaConcluidaTable(
                buscarTabela[0]['user_id'],
                buscaTarefa[0]['title'],
                buscaTarefa[0]['date'],
                buscaTarefa[0]['startTime'],
                buscaTarefa[0]['endTime'],
                buscaTarefa[0]['note'],
                1)
            .toMap());
  }

  deletarTarefa(int board_id, int id) async {
    await initDatabase();
    var buscaQuadro = await data?.query('task_board',
        columns: ['id'], where: 'id = ?', whereArgs: [board_id]);

    return await data?.delete('task',
        where: 'id = ? and board_id = ?',
        whereArgs: [id, buscaQuadro?[0]['id']]);
  }

  atualizarTarefa(int id, int board_id, String title, String date,
      String startTime, String endTime, String note) async {
    await initDatabase();

    return await data?.update('task',
        TarefaTable(board_id, title, date, startTime, endTime, note, 0).toMap(),
        where: 'id = ?', whereArgs: [id]);
  }

/////////////////////////////////BUSCAS///////////////////////////////////////////

  obterTarefasConcluidas(String email) async {
    await initDatabase();
    var buscaUsuario = await data?.query('user',
        columns: ['id'], where: 'email = ?', whereArgs: [email]);

    var buscaTabela = await data?.query('task_board',
        columns: ['id'],
        where: 'user_id = ?',
        whereArgs: [buscaUsuario?[0]['id']]);

    return await data?.query('completed_task',
        columns: [
          'id',
          'user_id',
          'title',
          'note',
          'date',
          'startTime',
          'endTime',
          'isCompleted'
        ],
        where: 'user_id = ? ',
        whereArgs: [buscaUsuario?[0]['id']],
        orderBy: 'startTime');
  }

  obterTarefas() async {
    await initDatabase();
    return data?.rawQuery(
        'select task.* from task union select completed_task.* from completed_task');
  }

  obterTarefasRecentes(String email) async {
    await initDatabase();

    var buscaUsuario = await data?.query('user',
        columns: ['id', 'email'],
        where: 'email = ?',
        whereArgs: [email]) as List;

    return await data?.rawQuery("select task.* from user, task_board, task "
        "where user.id = task_board.user_id and task_board.id = board_id and "
        "user.id = ${buscaUsuario[0]['id']} and "
        "task.startTime between date('now') and date('now', '+7 day')"
        "UNION "
        "select completed_task.* from user, completed_task "
        "where user.id = completed_task.user_id and "
        "user.id = ${buscaUsuario[0]['id']} and "
        "completed_task.startTime between date('now') and date('now', '+7 day') "
        "order by startTime");
  }

  realizarPesquisa(String email, List<dynamic> lista) async {
    await initDatabase();

    var buscaUsuario = await data?.query('user',
        columns: ['id', 'email'],
        where: 'email = ?',
        whereArgs: [email]) as List;

    List<String> task_queries = [
      "select task.* from user, task_board, task "
          "where user.id = user_id and task_board.id = board_id and "
          "user.id = ${buscaUsuario[0]['id']}",
      "cast(strftime('%d', task.startTime) as integer) = ${lista[0]}",
      "cast(strftime('%w', task.startTime) as integer) = ${lista[1]}",
      "cast(strftime('%m', task.startTime) as integer) = ${lista[2]}"
    ];

    List<String> completed_task_queries = [
      "select completed_task.* from user, completed_task "
          "where user.id = user_id and "
          "user.id = ${buscaUsuario[0]['id']}",
      "cast(strftime('%d', completed_task.startTime) as integer) = ${lista[0]}",
      "cast(strftime('%w', completed_task.startTime) as integer) = ${lista[1]}",
      "cast(strftime('%m', completed_task.startTime) as integer) = ${lista[2]}"
    ];

    String busca_task = task_queries[0];

    for (int i = 0; i < lista.length; i++) {
      if (lista[i] != null) {
        busca_task = '$busca_task and ${task_queries[i + 1]}';
      }
    }

    String busca_completed = completed_task_queries[0];

    for (int i = 0; i < lista.length; i++) {
      if (lista[i] != null) {
        busca_completed =
            '$busca_completed and ${completed_task_queries[i + 1]}';
      }
    }

    return await data
            ?.rawQuery('$busca_task UNION $busca_completed order by startTime')
        as List<Map<String, dynamic>>;
  }
}
