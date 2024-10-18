import 'dart:convert';

import 'package:codigoqr/providers/admob_providers.dart';
import 'package:codigoqr/widget/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class LinksScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<LinksScreen> createState() => _LinksScreenState();
}

class _LinksScreenState extends ConsumerState<LinksScreen> {
  final nombrebuscar = TextEditingController();
  List<Map<String, dynamic>> data = [];
  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('json_data');
    if (jsonString != null) {
      setState(() {
        data = json.decode(jsonString).cast<Map<String, dynamic>>();
      });
    }
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(data);
    await prefs.setString('json_data', jsonString);
  }

  Future<void> addEntry(Map<String, dynamic> entry) async {
    setState(() {
      data.add(entry);
    });
    await saveData();
  }

  Future<void> deleteEntry(int index) async {
    setState(() {
      data.removeAt(index);
    });
    await saveData();
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    // final interstitialAdmods = ref.watch(interstitialAdProvider);
    // ref.listen(interstitialAdProvider, (previous, next) {
    //   if (!next.hasValue) return;
    //   if (next.value == null) return;
    //   next.value!.show();
    // });
    // if (interstitialAdmods.isLoading) {
    //   return const Scaffold(
    //     body: Center(
    //       child: CircularProgressIndicator.adaptive(),
    //     ),
    //   );
    // }
    final size = MediaQuery.of(context).size;
    final searchTerm = nombrebuscar.text.toLowerCase();
    List<dynamic> datosdellistado = data
        .where((pre) =>
            pre['nombre'].toLowerCase().contains(searchTerm.toLowerCase()))
        .toList();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Mis Links',
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green.shade400,
        leading: IconButton(
            onPressed: () {
              verdialogo(context);
            },
            icon: const Icon(
              Icons.add_link_rounded,
              size: 35,
              color: Colors.white,
            )),
        actions: [
          IconButton(
            icon: Icon(Icons.help, color: Colors.white, size: 35),
            onPressed: () {
              Navigator.pushNamed(context, 'acercade');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Input(
                  onChanged: (text) {
                    setState(() {});
                  },
                  controllertext: nombrebuscar,
                  label: "Buscar Url",
                  icono: Icon(Icons.search)),
            ),
            SizedBox(
              height: size.height * 0.75,
              width: size.width * 0.95,
              child: ListView.builder(
                itemCount: datosdellistado.length,
                itemBuilder: (context, index) {
                  final item = datosdellistado[index];
                  return Slidable(
                    key: ValueKey(index),
                    startActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      // dismissible: DismissiblePane(onDismissed: () {}),
                      children: [
                        SlidableAction(
                          onPressed: (BuildContext context) async {
                            final result = await Share.share(item['url'],
                                subject: 'Comparto Link');
                          },
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          icon: Icons.share,
                          label: 'Compartir',
                        ),
                        SlidableAction(
                          onPressed: (BuildContext context) {
                            _launchURL(item['url']);
                          },
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          icon: Icons.view_quilt_outlined,
                          label: 'Abir link',
                        ),
                      ],
                    ),
                    endActionPane: ActionPane(
                      motion: ScrollMotion(),
                      children: [
                        SlidableAction(
                          flex: 2,
                          onPressed: (BuildContext context) {
                            deleteEntry(index);
                          },
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Eliminar',
                        ),
                      ],
                    ),
                    child: ListTile(
                        title: Text(item['nombre'],
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        subtitle: Text(item['url']),
                        leading: Icon(Icons.language_rounded,
                            size: 34, color: Colors.green)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void verdialogo(BuildContext context) {
    final controllernombre = TextEditingController();
    final controllerlink = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final size = MediaQuery.of(context).size;
        return Dialog(
          insetPadding: EdgeInsets.symmetric(vertical: 5),
          child: Container(
            width: size.width * 0.90,
            decoration: BoxDecoration(
              border: Border.fromBorderSide(
                  BorderSide(color: Colors.blue.shade100, width: 1.0)),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 1.0), //(x,y)
                  blurRadius: 6.0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Center(
                      child: Text(
                        'Ingresar Nuevo Links',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Input(
                        controllertext: controllernombre,
                        label: "Ingrese Nombre",
                        icono: Icon(Icons.abc)),
                    SizedBox(height: 10),
                    Input(
                        controllertext: controllerlink,
                        label: "Ingrese link",
                        icono: Icon(Icons.link)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MaterialButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          disabledColor: Colors.grey,
                          elevation: 1,
                          color: Colors.green,
                          onPressed: () async {
                            addEntry({
                              'id_url': data.length + 1,
                              'nombre': controllernombre.text,
                              'url': controllerlink.text
                            });
                            Navigator.pop(context);
                            const snackBar = SnackBar(
                                content: Text('Link Guardado Corectamente'));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          },
                          child: const Text(
                            'Guardar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 15),
                        MaterialButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          disabledColor: Colors.grey,
                          elevation: 1,
                          color: Colors.green,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
