import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:geojson/geojson.dart';



void main() {
  runApp(const MyApp());
}

var _zoomPanBehavior = MapZoomPanBehavior(enableDoubleTapZooming: true, zoomLevel: 10);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  final _mapSource = const MapShapeSource.asset(
    'export.geojson',
    shapeDataField: 'name',
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:Scaffold(
        appBar: AppBar(
          title: const Text("Карта"),
          centerTitle: true,
        ),
        body: SfMaps(
          layers: [
            MapTileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              initialFocalLatLng: const MapLatLng(55.7751, 37.5421),
              zoomPanBehavior: _zoomPanBehavior,
              sublayers: [
                MapShapeSublayer(
                  source: _mapSource,
                  showDataLabels: true,

                  color: const Color(0x400e4e83),
                  strokeWidth: 2,
                  strokeColor: const Color(0x400e2283),

                  dataLabelSettings: const MapDataLabelSettings(
                    overflowMode: MapLabelOverflow.ellipsis,
                    textStyle: TextStyle(
                        color: Color(0x400e2283),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Times'),
                  ),
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}
