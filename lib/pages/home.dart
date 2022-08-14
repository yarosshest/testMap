import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class Polygon {
  const Polygon(this.name, this.color);

  final String name;
  final Color color;
}

class Dot {
  const Dot(this.name, this.latitude, this.longitude);

  final String name;
  final double latitude;
  final double longitude;
}

class HomeState extends State<Home> {
  late MapShapeSource mapSource;
  late MapZoomPanBehavior zoomPanBehavior;
  late List<Polygon> features = <Polygon>[];
  late List<Dot> dots = <Dot>[];
  late bool loading = false;

  int selectedIndex = -1;

  Future<void> readJson() async {
    String response = await rootBundle.loadString('ao.geojson');
    var data = await json.decode(response)["features"];

    for (var i in data) {
      var prop = i["properties"];
      if (!features.contains(prop["NAME"]) && prop["NAME"] != null) {
        features.add(Polygon(
            prop["NAME"],
            Color((math.Random().nextDouble() * 0xFFFFFF).toInt())
                .withOpacity(0.5)));
      }
    }

    response = await rootBundle.loadString('dots.json');
    data = await json.decode(response)["features"];

    for (var i in data) {
      var prop = i["properties"];
      var geom = i["geometry"];
      if (!dots.contains(prop["NAME"]) && prop["NAME"] != null) {
        dots.add(
            Dot(prop["NAME"], geom["coordinates"][1], geom["coordinates"][0]));
      }
    }

    mapSource = MapShapeSource.asset(
      'ao.geojson',
      shapeDataField: 'NAME',
      dataCount: features.length,
      dataLabelMapper: (int index) => features[index].name,
      primaryValueMapper: (int index) => features[index].name,
      shapeColorValueMapper: (int index) => features[index].color,
    );
    setState(() {
      loading = true;
    });
  }

  @override
  void initState() {
    zoomPanBehavior = MapZoomPanBehavior(
      enableDoubleTapZooming: true,
      enableMouseWheelZooming: true,
      zoomLevel: 10,
    );
    readJson();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey,
        appBar: AppBar(
          title: const Text("Карта"),
          centerTitle: true,
        ),
        body: FutureBuilder(builder: (BuildContext context, snapshot) {
          if (loading) {
            return Padding(
                padding: const EdgeInsets.all(15),
                child: SfMapsTheme(
                    data: SfMapsThemeData(
                      shapeHoverColor: const Color(0xC6282840),
                      shapeHoverStrokeColor: Colors.black,
                      shapeHoverStrokeWidth: 2,
                    ),
                    child: SfMaps(
                      layers: [
                        MapTileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          initialFocalLatLng: const MapLatLng(55.7751, 37.5421),
                          zoomPanBehavior: zoomPanBehavior,
                          initialMarkersCount: dots.length,
                          markerBuilder: (BuildContext context, int index) {
                            return MapMarker(
                                latitude: dots[index].latitude,
                                longitude: dots[index].longitude,
                                iconColor: Colors.blue,
                                child:
                                    const Icon(Icons.account_balance_outlined));
                          },
                          tooltipSettings: const MapTooltipSettings(
                              color: Colors.red,
                              strokeColor: Colors.black,
                              strokeWidth: 1.5),
                          markerTooltipBuilder: (BuildContext context, int index) {
                            return Container(
                              width: 150,
                              padding: const EdgeInsets.all(10),
                              child: Text(dots[index].name),
                            );
                          },
                          sublayers: [
                            MapShapeSublayer(
                              source: mapSource,
                              showDataLabels: true,
                              dataLabelSettings: const MapDataLabelSettings(
                                  overflowMode: MapLabelOverflow.ellipsis,
                                  textStyle: TextStyle(
                                    color: Colors.black,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  )),
                              strokeWidth: 2,
                              strokeColor: const Color(0xff0873e8),
                              selectedIndex: selectedIndex,
                              onSelectionChanged: (int index) {
                                setState(() {
                                  selectedIndex = index;
                                });
                              },
                              selectionSettings: const MapSelectionSettings(
                                color: Color(0x400e2283),
                                strokeColor: Colors.red,
                                strokeWidth: 3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )));
          } else {
            return const CircularProgressIndicator.adaptive();
          }
        }));
  }
}
