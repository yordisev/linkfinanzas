import 'dart:convert';
import 'dart:io';

import 'package:codigoqr/providers/admob_providers.dart';
import 'package:codigoqr/providers/local_auth_providers.dart';
import 'package:codigoqr/screen/aes.dart';
import 'package:codigoqr/widget/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';

class ClavesScreen extends ConsumerStatefulWidget {
  const ClavesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState createState() => _ClavesScreenState();
}

class _ClavesScreenState extends ConsumerState<ClavesScreen> {
  final nombrebuscar = TextEditingController();
  List<Map<String, dynamic>> dataclaves = [];
  @override
  void initState() {
    super.initState();
    loadDataclaves();
  }

  Future<void> loadDataclaves() async {
    final preferes = await SharedPreferences.getInstance();
    final jsonStringclaves = preferes.getString('json_data_claves');
    if (jsonStringclaves != null) {
      setState(() {
        dataclaves = json.decode(jsonStringclaves).cast<Map<String, dynamic>>();
      });
    }
  }

  Future<void> saveData() async {
    final preferes = await SharedPreferences.getInstance();
    final jsonStringclaves = json.encode(dataclaves);
    await preferes.setString('json_data_claves', jsonStringclaves);
  }

  Future<void> addEntry(Map<String, dynamic> entry) async {
    setState(() {
      dataclaves.add(entry);
    });
    await saveData();
  }

  Future<void> deleteEntry(int index) async {
    setState(() {
      dataclaves.removeAt(index);
    });
    await saveData();
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> exportData() async {
    if (await Permission.storage.request().isGranted) {
      // final directory = await getApplicationDocumentsDirectory();
      // final path = '${directory.path}/dataclaves_export.json';
      dynamic externalDir = '/storage/emulated/0/Download';
      final path = '${externalDir}/dataclaves_export.json';
      final file = File(path);

      final jsonStringclaves = json.encode(dataclaves);
      await file.writeAsString(jsonStringclaves);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Datos exportados correctamente en descargas')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permisos de almacenamiento denegados')),
      );
    }
  }

  Future<void> importData() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result != null) {
      File file = File(result.files.single.path!);
      String jsonStringclaves = await file.readAsString();
      setState(() {
        dataclaves = json.decode(jsonStringclaves).cast<Map<String, dynamic>>();
      });
      await saveData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos importados correctamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Importación cancelada')),
      );
    }
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
    List<dynamic> datosdellistado = dataclaves
        .where((pre) =>
            pre['nombre'].toLowerCase().contains(searchTerm.toLowerCase()))
        .toList();
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Mis Claves',
            style: TextStyle(
                fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Colors.green.shade400,
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
                    label: "Buscar Clave",
                    icono: const Icon(Icons.search)),
              ),
              SizedBox(
                height: size.height * 0.75,
                width: size.width * 0.95,
                child: ListView.builder(
                  itemCount: datosdellistado.length,
                  itemBuilder: (context, index) {
                    final item = datosdellistado[index];
                    return ListTile(
                      title: Text(item['nombre'].toLowerCase(),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: Text(item['clave']),
                      leading: IconButton(
                          icon: const Icon(Icons.remove_red_eye,
                              color: Colors.green, size: 25),
                          onPressed: () async {
                            final (verificar, msg) = await ref
                                .read(localAutorizacionProvider.notifier)
                                .autenticaciondeusuario();
                            if (verificar) {
                              _verClave(context, item);
                            } else {
                              const snackBar = SnackBar(
                                  content: Text(
                                      'No Cuenta con Biometrico para ver la clave'));
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            }
                          }),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.green, size: 25),
                        onPressed: () => deleteEntry(index),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: SpeedDial(
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          activeIcon: Icons.close,
          iconTheme: IconThemeData(color: Colors.white),
          buttonSize: Size(58, 58),
          curve: Curves.bounceIn,
          children: [
            SpeedDialChild(
                elevation: 0,
                child: Icon(Icons.add_box_outlined, color: Colors.white),
                labelWidget: Text('Agregar Nueva'),
                backgroundColor: Colors.green,
                onTap: () {
                  verdialogoclave(context);
                }),
            SpeedDialChild(
                elevation: 0,
                child: Icon(Icons.import_export, color: Colors.white),
                labelWidget: Text('Exportar'),
                backgroundColor: Colors.blue,
                onTap: () {
                  exportData();
                }),
            SpeedDialChild(
                elevation: 0,
                child: Icon(Icons.import_export, color: Colors.white),
                labelWidget: Text('Importar'),
                backgroundColor: Colors.green,
                onTap: () {
                  importData();
                }),
          ],
        ));
  }

  void verdialogoclave(BuildContext context) {
    final controllernombre = TextEditingController();
    final controllerusuario = TextEditingController();
    final controllerlink = TextEditingController();
    AESEncryption encryption = AESEncryption();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final size = MediaQuery.of(context).size;
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(vertical: 5),
          child: Container(
            width: size.width * 0.90,
            decoration: BoxDecoration(
              border: Border.fromBorderSide(
                  BorderSide(color: Colors.blue.shade100, width: 1.0)),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                const BoxShadow(
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
                        'Ingresar Nuevo Clave',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Input(
                        controllertext: controllernombre,
                        label: "Ingrese Nombre",
                        icono: const Icon(Icons.abc)),
                    const SizedBox(height: 10),
                    Input(
                        controllertext: controllerusuario,
                        label: "Ingrese Nombre Usuario",
                        icono: const Icon(Icons.person_pin)),
                    const SizedBox(height: 10),
                    Input(
                        controllertext: controllerlink,
                        label: "Ingrese Clave",
                        icono: const Icon(Icons.key)),
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
                            final clavecifrada = await encryption
                                .cifrarclave(controllerlink.text);
                            addEntry({
                              'id_clave': dataclaves.length + 1,
                              'nombre': controllernombre.text,
                              'usuario': controllerusuario.text,
                              'clave': clavecifrada
                            });
                            Navigator.pop(context);
                            const snackBar = SnackBar(
                                content: Text('Clave Guardado Corectamente'));
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

  void _verClave(BuildContext context, datosclave) async {
    AESEncryption encryption = AESEncryption();
    final verclave = await encryption.decifrarclave(datosclave['clave']);
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final size = MediaQuery.of(context).size;
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(vertical: 5),
          child: Container(
            width: size.width * 0.90,
            decoration: BoxDecoration(
              border: Border.fromBorderSide(
                  BorderSide(color: Colors.blue.shade100, width: 1.0)),
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: const [
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
                    Center(
                      child: Text(
                        datosclave['nombre'].toUpperCase(),
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade400),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: size.width,
                      height: size.height * 0.08,
                      decoration: BoxDecoration(
                        border: Border.fromBorderSide(BorderSide(
                            color: Colors.blue.shade100, width: 0.5)),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.0, 5.0), //(x,y)
                            blurRadius: 5.5,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text('Usuario:',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey.shade400)),
                          const SizedBox(height: 5),
                          Text('${datosclave['usuario']}'.toLowerCase(),
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: size.width,
                      height: size.height * 0.08,
                      decoration: BoxDecoration(
                        border: Border.fromBorderSide(BorderSide(
                            color: Colors.blue.shade100, width: 0.5)),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.0, 5.0), //(x,y)
                            blurRadius: 5.5,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text('Clave:',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey.shade400)),
                          const SizedBox(height: 5),
                          Text(verclave,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Center(
                      child: IconButton(
                        icon: Icon(Icons.copy),
                        color: Colors.green,
                        splashColor: Colors.white,
                        iconSize: 28.0,
                        padding: EdgeInsets.all(8.0),
                        onPressed: () {
                          Clipboard.setData(new ClipboardData(text: verclave));
                          const snackBar = SnackBar(
                              content: Text('Texto Copiado al portapapeles'));
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        disabledColor: Colors.grey,
                        elevation: 1,
                        color: Colors.green,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Atras',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
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
