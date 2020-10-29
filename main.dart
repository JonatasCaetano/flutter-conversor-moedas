import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';



void main() {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  void _realAlterado(String texto) {
    if (texto.isEmpty) {
      _limparCampos();
      return;
    }
    double real = double.parse(texto);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarAlterado(String texto) {
    if (texto.isEmpty) {
      _limparCampos();
      return;
    }
    double dolar = double.parse(texto);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void _euroAlterado(String texto) {
    if (texto.isEmpty) {
      _limparCampos();
      return;
    }
    double euro = double.parse(texto);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  Future<Map> _recuperarDado() async {
    const request = 'https://api.hgbrasil.com/finance';
    http.Response response = await http.get(request);
    return json.decode(response.body);
  }

  void _limparCampos() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('\$ Conversor \$'),
        backgroundColor: Colors.amber,
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _limparCampos)
        ],
      ),
      body: FutureBuilder<Map>(
          future: _recuperarDado(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text(
                    'Carregando dados...',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar dados...',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 25.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  dolar = snapshot.data['results']['currencies']['USD']['buy'];
                  euro = snapshot.data['results']['currencies']['EUR']['buy'];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.monetization_on,
                          size: 150.0,
                          color: Colors.amber,
                        ),
                        campoDeTexto(
                            'Reais', 'R\$ ', realController, _realAlterado),
                        Divider(),
                        campoDeTexto('Dolares', 'US\$ ', dolarController,
                            _dolarAlterado),
                        Divider(),
                        campoDeTexto(
                            'Euros', '€ ', euroController, _euroAlterado)
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget campoDeTexto(String label, String prefix,
    TextEditingController controller, Function alterado) {
  return TextField(
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.amber),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
    controller: controller,
    onChanged: alterado,
  );
}