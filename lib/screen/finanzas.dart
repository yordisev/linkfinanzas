import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:codigoqr/widget/inputfecha.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartData {
  final String tipo;
  final double valor;
  final Color color;

  ChartData(this.tipo, this.valor, this.color);
}

class FinanzasScreen extends StatefulWidget {
  @override
  State<FinanzasScreen> createState() => _FinanzasScreenState();
}

class _FinanzasScreenState extends State<FinanzasScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _detalleController = TextEditingController();
  String _tipo = 'Ingreso'; // Valor por defecto
  final TextEditingController _selectedDate = TextEditingController();
  List<Map<String, dynamic>> _registros = [];
  final fechainicio = TextEditingController();
  final fechafin = TextEditingController();
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('registros');
    if (data != null) {
      setState(() {
        _registros = List<Map<String, dynamic>>.from(json.decode(data));
      });
    }
  }

  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('registros', json.encode(_registros));
  }

  void _addRegistro() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _registros.add({
          'valor': int.parse(_valorController.text),
          'detalle': _detalleController.text.toUpperCase(),
          'tipo': _tipo,
          'fecha': _selectedDate.text,
        });
      });
      _saveData();
      _valorController.clear();
    }
  }

  void _deleteRegistro(int index) {
    setState(() {
      _registros.removeAt(index);
    });
    _saveData();
  }

  num _totalPorTipo(String tipo) {
    return _obtenerRegistrosFiltrados()
        .where((r) => r['tipo'] == tipo)
        .fold(0, (sum, r) => sum + r['valor']);
  }

  String formatearMoneda(String valorreci) {
    final valor = double.parse(valorreci);
    final formatoPesos = NumberFormat.currency(
      locale: 'es_CO',
      symbol: '',
      decimalDigits: 0, // Sin decimales
    );
    return formatoPesos.format(valor);
  }

  void _filtrarRegistrosPorFecha() {
    setState(() {
      _fechaInicio = DateTime.tryParse(fechainicio.text);
      _fechaFin = DateTime.tryParse(fechafin.text);
    });
  }

  void _sinfiltroPorFecha() {
    setState(() {
      _fechaInicio = null;
      _fechaFin = null;
      fechainicio.text = "";
      fechafin.text = "";
    });
  }

  List _obtenerRegistrosFiltrados() {
    if (_fechaInicio == null || _fechaFin == null) {
      return _registros; // Si no hay fechas seleccionadas, muestra todos los registros
    }

    return _registros.where((registro) {
      DateTime fechaRegistro = DateTime.parse(
          registro['fecha']); // Asegúrate de que el formato sea correcto
      return fechaRegistro.isAfter(_fechaInicio!.subtract(Duration(days: 1))) &&
          fechaRegistro.isBefore(_fechaFin!.add(Duration(days: 1)));
    }).toList();
  }

  Map<String, double> sumarValoresPorTipo(List datos) {
    double sumaIngresos = 0;
    double sumaEgresos = 0;
    for (var dato in datos) {
      if (dato['tipo'] == 'Ingreso') {
        sumaIngresos += dato['valor'];
      } else if (dato['tipo'] == 'Egreso') {
        sumaEgresos += dato['valor'];
      }
    }

    return {'ingreso': sumaIngresos, 'egreso': sumaEgresos};
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final datodiferencia = _totalPorTipo('Ingreso') - _totalPorTipo('Egreso');
    final datoschard = _obtenerRegistrosFiltrados();
    final valoresSumados = sumarValoresPorTipo(datoschard);

    // Datos formateados para el gráfico
    final List<ChartData> chartData = [
      ChartData('Ingreso', valoresSumados['ingreso'] ?? 0, Colors.green),
      ChartData('Gasto', valoresSumados['egreso'] ?? 0, Colors.red),
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Mis Finanzas',
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green.shade400,
        leading: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: GestureDetector(
                onTap: () {
                  verdialogoagregar(context);
                },
                child: Container(
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(100)),
                  child: Icon(Icons.add_box_outlined,
                      color: Colors.white, size: 35),
                ))),
        actions: [
          Row(
            children: [
              // IconButton(
              //   icon: Icon(Icons.add_business_outlined,
              //       color: Colors.black, size: 35),
              //   onPressed: () {

              //   },
              // ),
              IconButton(
                icon: Icon(Icons.restart_alt_outlined,
                    color: Colors.white, size: 35),
                onPressed: () {
                  _sinfiltroPorFecha();
                },
              )
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              title: ChartTitle(
                  text: 'Ingresos y Gastos',
                  textStyle:
                      TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              series: <CartesianSeries>[
                ColumnSeries<ChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (ChartData data, _) => data.tipo,
                  yValueMapper: (ChartData data, _) => data.valor,
                  pointColorMapper: (ChartData data, _) => data.color,
                  dataLabelSettings: DataLabelSettings(
                    textStyle:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    isVisible: true,
                    // Aquí devolvemos un widget Text en lugar de un String
                    builder: (dynamic data, dynamic point, dynamic series,
                        int pointIndex, int seriesIndex) {
                      return Text(
                        '${data.tipo == 'Ingreso' ? '' : '-'}\$${formatearMoneda(data.valor.toString())}',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
              ],
            ),
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Row(
            //     children: [
            //       // First Card - Student
            //       Expanded(
            //         child: Card(
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(16),
            //           ),
            //           color: Colors.blue[50],
            //           child: Padding(
            //             padding: const EdgeInsets.all(16.0),
            //             child: Column(
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               children: [
            //                 Icon(
            //                   Icons.monetization_on_outlined,
            //                   size: 50,
            //                   color: Colors.blue,
            //                 ),
            //                 SizedBox(height: 10),
            //                 Text(
            //                   '\$${formatearMoneda(_totalPorTipo('Ingreso').toString())}',
            //                   style: TextStyle(
            //                     fontSize: 24,
            //                     fontWeight: FontWeight.bold,
            //                     color: Colors.black,
            //                   ),
            //                 ),
            //                 SizedBox(height: 10),
            //                 Text(
            //                   'Ingresos',
            //                   style: TextStyle(
            //                     fontSize: 18,
            //                     color: Colors.black54,
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ),
            //       ),
            //       SizedBox(width: 16),
            //       // Second Card - News
            //       Expanded(
            //         child: Card(
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(16),
            //           ),
            //           color: Colors.blue[50],
            //           child: Padding(
            //             padding: const EdgeInsets.all(16.0),
            //             child: Column(
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               children: [
            //                 Icon(
            //                   Icons.monetization_on_outlined,
            //                   size: 50,
            //                   color: Colors.green,
            //                 ),
            //                 SizedBox(height: 10),
            //                 Text(
            //                   '\$${formatearMoneda(_totalPorTipo('Egreso').toString())}',
            //                   style: TextStyle(
            //                     fontSize: 24,
            //                     fontWeight: FontWeight.bold,
            //                     color: Colors.black,
            //                   ),
            //                 ),
            //                 SizedBox(height: 10),
            //                 Text(
            //                   'Egresos',
            //                   style: TextStyle(
            //                     fontSize: 18,
            //                     color: Colors.black54,
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // Container(
            //   height: 100,
            //   decoration: BoxDecoration(
            //     border: Border.fromBorderSide(
            //         BorderSide(color: Colors.blue.shade100, width: 1.0)),
            //     borderRadius: BorderRadius.circular(10),
            //     color: Colors.blue[50],
            //     boxShadow: [
            //       const BoxShadow(
            //         color: Colors.grey,
            //         offset: Offset(0.0, 1.0), //(x,y)
            //         blurRadius: 6.0,
            //       ),
            //     ],
            //   ),
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: [
            //           Icon(Icons.monetization_on_outlined,
            //               size: 45,
            //               color: _totalPorTipo('Ingreso') -
            //                           _totalPorTipo('Egreso') >
            //                       0
            //                   ? Colors.blue
            //                   : Colors.green),
            //           SizedBox(width: 5),
            //           Text(
            //             'Diferencia',
            //             style: TextStyle(
            //                 fontSize: 23,
            //                 fontWeight: FontWeight.bold,
            //                 color: Colors.black),
            //           ),
            //         ],
            //       ),
            //       SizedBox(height: 10),
            //       Text(
            //         '\$${formatearMoneda(datodiferencia.toString())}',
            //         style: TextStyle(
            //             fontSize: 23,
            //             fontWeight: FontWeight.bold,
            //             color: Colors.black),
            //       ),
            //     ],
            //   ),
            // ),
            SizedBox(height: 5),
            Container(
              child: Row(
                children: [
                  Expanded(
                    child: InputText(
                      label: 'Inicio',
                      controller: fechainicio,
                      isCalendar: true,
                      readOnly: true,
                    ),
                  ),
                  SizedBox(width: 3),
                  Expanded(
                    child: InputText(
                      label: 'Fin',
                      controller: fechafin,
                      isCalendar: true,
                      readOnly: true,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4),
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  color: Colors.green.shade300,
                ),
                child: TextButton.icon(
                  onPressed: _filtrarRegistrosPorFecha,
                  label: Text(
                    'FILTRAR',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17),
                  ),
                  icon: Icon(Icons.search, size: 25, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 4),
            SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: size.height * 0.25,
                    width: size.width * 0.95,
                    // color: Colors.green,
                    child: ListView.builder(
                      itemCount: _obtenerRegistrosFiltrados().length,
                      // itemCount: _registros.length,
                      itemBuilder: (context, index) {
                        final registro = _obtenerRegistrosFiltrados()[index];
                        // final registro = _registros[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.fromBorderSide(BorderSide(
                                  color: Colors.blue.shade500, width: 1.0)),
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
                            child: ListTile(
                              title: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                      '${registro['tipo']}: ${registro['tipo'] == 'Ingreso' ? '' : '-'} \$${formatearMoneda(registro['valor'].toString())}',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: registro['tipo'] == 'Ingreso'
                                              ? Colors.green
                                              : Colors.red)),
                                  Text(registro['detalle']),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Fecha: ${registro['fecha']}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ),
                              trailing: IconButton(
                                color: Colors.green,
                                icon: Icon(Icons.delete),
                                onPressed: () => _deleteRegistro(index),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void verdialogoagregar(BuildContext context) {
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
                        'Ingresar Registro',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          InputText(
                              label: 'Valor en Pesos',
                              controller: _valorController,
                              keyboardType: TextInputType.number,
                              isCalendar: false,
                              readOnly: false,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese un valor';
                                }
                                return null;
                              }),
                          const SizedBox(height: 10),
                          InputText(
                              label: 'Detalle de Registro',
                              controller: _detalleController,
                              keyboardType: TextInputType.text,
                              isCalendar: false,
                              readOnly: false,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor ingrese un nombre';
                                }
                                return null;
                              }),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                              value: _tipo,
                              items: ['Ingreso', 'Egreso']
                                  .map((tipo) => DropdownMenuItem(
                                        value: tipo,
                                        child: Text(tipo),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _tipo = value!;
                                });
                              },
                              hint: Text(
                                "Seleccionar",
                                style: TextStyle(
                                    color: Colors.green, fontSize: 18),
                              ),
                              style: const TextStyle(
                                  color: Colors.green,
                                  overflow: TextOverflow.ellipsis),
                              decoration: InputDecoration(
                                errorStyle: TextStyle(
                                    color: Colors.green ?? Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13),
                                fillColor: Colors.transparent,
                                hintStyle: const TextStyle(color: Colors.grey),
                                labelStyle: const TextStyle(color: Colors.grey),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 2),
                                ),
                                errorBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4)),
                                    borderSide: BorderSide(
                                      width: 1,
                                      color: Colors.green,
                                    )),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                              )),
                          const SizedBox(height: 10),
                          InputText(
                            label: 'seleccionar fecha',
                            controller: _selectedDate,
                            isCalendar: true,
                            readOnly: true,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                disabledColor: Colors.grey,
                                elevation: 1,
                                color: Colors.blue,
                                onPressed: () async {
                                  if (_valorController.text == '' ||
                                      _detalleController.text == '' ||
                                      _selectedDate.text == '') {
                                    const snackBar = SnackBar(
                                        content: Text(
                                            'Por Favor llene todos los campos'));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  } else {
                                    _addRegistro();
                                    Navigator.pop(context);
                                    const snackBar = SnackBar(
                                        content: Text(
                                            'Registro Guardado Corectamente'));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                    _valorController.text = "";
                                    _detalleController.text = "";
                                    _selectedDate.text = "";
                                  }
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
                    const SizedBox(height: 10),
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
