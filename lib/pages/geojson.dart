import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geojson/geojson.dart';

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


class HomeState extends State<Home> {
  late List<Model> features = <Model>[];
  late bool loading = false;
  late List<Polyline> lines;
  late GeoJson geo = GeoJson();
  late List<Polygon> polygons = <Polygon>[];



  List<LatLng> reedPolygons(GeoJsonPolygon polygon){
    List<LatLng> points = [];
    for (var el in polygon.geoSeries){
      for(var p in el.toLatLng()) {
        points.add(p);
      }
    }
    return points;
  }

  List<LatLng> reedMultiPolygon(GeoJsonMultiPolygon multiPolygon) {
    List<LatLng> points = [];
    for(var mp in multiPolygon.polygons) {
      for (var el in mp.geoSeries) {
        for (var p in el.toLatLng()) {
          points.add(p);
        }
      }
    }
    return points;
  }

  Future<void> parseAndDrawAssetsOnMap() async {
    geo.processedPolygons.listen((GeoJsonPolygon polygon) {
      polygons.add(
              Polygon(
                  points: reedPolygons(polygon),
                  label: polygon.name
              ));
      // setState(()=> polygons.add(
      //     Polygon(
      //         points: reedPolygons(polygon),
      //         label: polygon.name
      //     )
      // ));
    });

    geo.processedMultiPolygons.listen((GeoJsonMultiPolygon multiPolygon) {
      polygons.add(
              Polygon(
                points: reedMultiPolygon(multiPolygon),
                label: multiPolygon.name,
              ));
      // setState(() => polygons.add(
      //     Polygon(
      //       points: reedMultiPolygon(multiPolygon),
      //       label: multiPolygon.name,
      //     )
      // ));
    });

    // geo.endSignal.listen((_) => geo.dispose());

    final data = await rootBundle
        .loadString('ao.geojson');

    await geo.parseInMainThread(
      data,
      nameProperty: "NAME",
    );

    loading = true;
  }

  @override
  void initState() {
    parseAndDrawAssetsOnMap();
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
              // if (polygons.isNotEmpty) {
              if (polygons.isNotEmpty) {
                  return FlutterMap(
                      options: MapOptions(
                        center: LatLng(55.775100, 37.542100),
                        zoom: 10,
                      ),
                      layers: [
                        TileLayerOptions(
                          urlTemplate:'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        ),
                        PolygonLayerOptions(
                            polygons: polygons
                        ),
                      ]
                  );
                } else {
                  return const CircularProgressIndicator();
                }
            }
        )
    );
  }
}