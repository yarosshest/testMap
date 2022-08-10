import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geojson/geojson.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

class Home extends StatefulWidget{
  const Home({Key? key}):super(key: key);

  @override
  HomeState createState() => HomeState();

}

List<MapLatLng> parsePolygon(var polygon){
  List<MapLatLng> pol = [];
  for(var xy in polygon) {
    pol.add(MapLatLng(xy[1], xy[0]));
  }
  return pol;
}


class Obj{
  late String name;
  late Color color;
  late List<MapLatLng> polygon = [];

}

Future<List<Obj>> parseAndDrawAssetsOnMap() async {
  // final String response = await rootBundle.loadString('aoCrop.geojson');
  final String response = await rootBundle.loadString('ao.geojson');
  final data = await json.decode(response);

  List<Obj> objects = [];

  for (var feat in  data["features"] ){
    for(var coordinates in feat['geometry']["coordinates"]){
      for(var coord in coordinates){
        Obj obj = Obj();
        obj.name = feat["properties"]["NAME"];
        obj.color = Colors.blueAccent;

        List<MapLatLng> pol;

        if (coord[0] is double){
          pol = parsePolygon(coordinates);
        }
        else{
          pol = parsePolygon(coord);
        }
        obj.polygon = pol;
        objects.add(obj);
      }
    }
  }
  print("parsed");
  return objects;
}

class HomeState extends State<Home> {
  late bool loading = false;
  late List<Polyline> lines;
  late GeoJson geo = GeoJson();
  late Future<List<Obj>> polygons;
  late MapZoomPanBehavior zoomPanBehavior;

  @override
  void initState() {
    zoomPanBehavior = MapZoomPanBehavior(
      enableDoubleTapZooming: true,
      zoomLevel: 10,
    );
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
        body: FutureBuilder<List<Obj>>(
            future: polygons,
            builder: (context,  AsyncSnapshot<List<Obj>> snapshot) {
              if (snapshot.hasData) {
                return SfMaps(layers: [
                  MapTileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  initialFocalLatLng: const MapLatLng(55.7751, 37.5421),
                  zoomPanBehavior: zoomPanBehavior,
                  sublayers: [
                    MapPolygonLayer(
                    polygons: List<MapPolygon>.generate(
              (snapshot.data as List<Obj>).length,(int index) {return MapPolygon(
              points: (snapshot.data as List<Obj>)[index].polygon,
              strokeColor: (snapshot.data as List<Obj>)[index].color,
              );},).toSet(),
              )]
              )]);
              } else {
                return const CircularProgressIndicator.adaptive();
              }
            }
        )
    );
  }
}