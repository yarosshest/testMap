import 'dart:convert';
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

List<LatLng> parsePolygon(var polygon){
  List<LatLng> pol = [];
  for(var xy in polygon) {
    pol.add(LatLng(xy[1], xy[0]));
  }
  return pol;
}

class Obj{
  late String name;
  late Color color;
  late List<List<LatLng>> polygons = [];

  List<Polygon> toPolygon(){
    List<Polygon> map = [];

    for(List<LatLng> polygon in polygons ){
      Polygon pol = Polygon(
        points: polygon,
        color: color,
        label: name,
      );
      map.add(pol);
    }

    return map;
  }
}

List<Polygon> prepPolygons(List<Obj> objects){
  List<List<Polygon>> ep = [];
  for(Obj obj in objects){
    ep.add(obj.toPolygon());
  }
  List<Polygon> ret = ep.expand((element) => element).toList();
  return ret;
}

Future<List<Polygon>> parseAndDrawAssetsOnMap() async {
  // final String response = await rootBundle.loadString('aoCrop.geojson');
  final String response = await rootBundle.loadString('ao.geojson');
  final data = await json.decode(response);

  List<Obj> objects = [];

  for (var feat in  data["features"] ){
    Obj obj = Obj();
    obj.name = feat["properties"]["NAME"];
    obj.color = Colors.blueAccent;

    List<List<LatLng>> geom = [];

    for(var coordinates in feat['geometry']["coordinates"]){
      for(var coord in coordinates){
        List<LatLng> pol = [];
        if (coord[0] is double){
          pol = parsePolygon(coordinates);
        }
        else{
          pol = parsePolygon(coord);
        }
        geom.add(pol);
      }
    }
    obj.polygons = geom;
    objects.add(obj);
  }
  print("parsed");
  return prepPolygons(objects);
}

class HomeState extends State<Home> {
  late bool loading = false;
  late List<Polyline> lines;
  late GeoJson geo = GeoJson();
  late Future<List<Polygon>> polygons;

  @override
  void initState() {
    polygons = parseAndDrawAssetsOnMap();
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
        body: FutureBuilder<List<Polygon>>(
          future: polygons,
          builder: (context,  AsyncSnapshot<List<Polygon>> snapshot) {
            if (snapshot.hasData) {
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
                        polygons: snapshot.data as List<Polygon>
                    ),
                  ]
              );
            } else {
              return const CircularProgressIndicator.adaptive();
            }
          }
        )
    );
  }
}