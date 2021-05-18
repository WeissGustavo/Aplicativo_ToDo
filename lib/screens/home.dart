import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _toDoList = [];
  final _toDoController = TextEditingController();
  int _indexUltimoRemovido;
  Map<String, dynamic> _ultimoRemovido;

  @override
  void initState() {
    super.initState();
    _lerDados().then((value) {
      setState(() {
        _toDoList = json.decode(value);
      });
    });
  }

  Future<String> _lerDados() async {
    try {
      final arquivo = await _abreArquivo();
      return arquivo.readAsString();
    } catch (e) {
      return null;
    }
  }

  void _adicionarTarefa() {
    setState(() {
      Map<String, dynamic> novaTarefa = Map();
      novaTarefa['titulo'] = _toDoController.text;
      novaTarefa["realizado"] = false;
      _toDoController.text = "";
      _toDoList.add(novaTarefa);
      _salvarDados();
    });
  }

  Future<File> _salvarDados() async {
    String dados = json.encode(_toDoList);
    final file = await _abreArquivo();
    return file.writeAsString(dados);
  }

  Future<File> _abreArquivo() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/todoList.json");
  }

  Future<Null> _refreshLista() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _toDoList.sort((a, b) {
        if (a["realizado"] && !b["realizado"]) return 1;
        if (!a["realizado"] && b["realizado"]) return -1;
        return 0;
      });
      _salvarDados();
    });
  }

  Widget widgetTarefa(BuildContext context, int index) {
    return Dismissible(
      key: Key(DateTime.now().microsecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(0.85, 0.0),
          child: Icon(
            Icons.delete_sweep_outlined,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.endToStart,
      child: CheckboxListTile(
        title: Text(_toDoList[index]["titulo"]),
        value: _toDoList[index]["realizado"],
        secondary: CircleAvatar(
          child: Icon(
            _toDoList[index]['realizado'] ? Icons.check : Icons.error,
            color: Theme.of(context).iconTheme.color,
          ),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        onChanged: (value) {
          setState(() {
            _toDoList[index]["realizado"] = value;
            _salvarDados();
          });
        },
        checkColor: Theme.of(context).primaryColor,
        activeColor: Theme.of(context).secondaryHeaderColor,
      ),
      onDismissed: (direction) {
        setState(() {
          _ultimoRemovido = Map.from(_toDoList[index]);
          _indexUltimoRemovido = index;
          _toDoList.removeAt(index);
          _salvarDados();
        });
        final snack = SnackBar(
            content: Text("Tarefa \"${_ultimoRemovido["titulo"]}\" apagada"),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: () {
                setState(() {
                  _toDoList.insert(_indexUltimoRemovido, _ultimoRemovido);
                  _salvarDados();
                });
              },
            ),
            duration: Duration(seconds: 4));
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(snack);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ToDo List"),
        centerTitle: true,
      ),
      body: Builder(
        builder: (context) => Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                          controller: _toDoController,
                          maxLength: 50,
                          decoration:
                              InputDecoration(labelText: "Nova tarefa"))),
                  Container(
                    height: 45.0,
                    width: 45.0,
                    child: FloatingActionButton(
                      child: Icon(Icons.save),
                      onPressed: () {
                        if (_toDoController.text.isEmpty) {
                          final alerta = SnackBar(
                            content: Text("A Tarefa nao pode ser vazia!"),
                            duration: Duration(seconds: 4),
                            action: SnackBarAction(
                                label: 'Ok',
                                onPressed: () {
                                  Scaffold.of(context).removeCurrentSnackBar();
                                }),
                          );
                          Scaffold.of(context).removeCurrentSnackBar();
                          Scaffold.of(context).showSnackBar(alerta);
                        } else {
                          _adicionarTarefa();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(padding: (EdgeInsets.only(top: 10.0))),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshLista,
                child: ListView.builder(
                  itemBuilder: widgetTarefa,
                  itemCount: _toDoList.length,
                  padding: EdgeInsets.only(top: 10.0),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
