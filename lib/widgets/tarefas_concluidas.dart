import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TarefasConcluidasWidget extends StatefulWidget {
  final elemento;

  const TarefasConcluidasWidget(this.elemento, {super.key});

  @override
  State<StatefulWidget> createState() => TarefasConcluidasStateWidget();
}

class TarefasConcluidasStateWidget extends State<TarefasConcluidasWidget> {
  String _formatarDatas(String data){
    return DateFormat('dd/MM/yyyy').format(DateTime.parse(data));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: const EdgeInsets.all(5),
        color: Colors.yellow,
        child: SizedBox(
            height: 200,
            child: Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 250,
                          child: Text(
                            widget.elemento['title'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),
                        ),
                      ]),
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
                ])));
  }
}
