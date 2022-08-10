import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class Home extends StatefulWidget{
  const Home({Key? key}):super(key: key);

  @override
  HomeState createState() => HomeState();

}
class Model {
  const Model(this.name, this.color);

  final String name;
  final Color color;
}


class HomeState extends State<Home>{
  late MapShapeSource mapSource;
  late MapZoomPanBehavior zoomPanBehavior;
  late List<Model> features = <Model>[];
  late bool loading = false;

  int selectedIndex = 3;

  Future<void> readJson()  async {
    final String response =  await rootBundle.loadString('ao.geojson');
    final data = await  json.decode(response)["features"];

    for(var i in data){
      var prop = i["properties"];
      if (!features.contains(prop["NAME"]) && prop["NAME"] != null){
        features.add(Model(
            prop["NAME"],
            Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(0.5)
        )
        );
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
          body: FutureBuilder(
            builder: (BuildContext context, snapshot) {
              if (loading) {
                return SfMaps(layers: [
                  MapTileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  initialFocalLatLng: const MapLatLng(55.7751, 37.5421),
                  zoomPanBehavior: zoomPanBehavior,
                  sublayers: [
                    MapShapeSublayer(
                        source: mapSource,
                        showDataLabels: true,
                        // color: const Color(0x400e4e83),
                        // strokeWidth: 2,
                        // strokeColor: const Color(0x400e2283),
                        selectedIndex: selectedIndex,
                        onSelectionChanged: (int index) {
                          setState(() { selectedIndex = index;});
                          },
                        shapeTooltipBuilder: (BuildContext context, int index){
                          return Text(features[index].name);
                        },
                        selectionSettings:MapSelectionSettings(
                          color: Colors.orange,
                          strokeColor: Colors.red[900],
                          strokeWidth: 3,
                        ),
                    ),
                  ],
                  ),
                ],
                );
              } else {
                return const CircularProgressIndicator();
              }
            }
        )
      );
  }
}

