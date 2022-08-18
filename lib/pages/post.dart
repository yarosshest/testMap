import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Line extends Text {
  const Line(String text, {super.key})
      : super(
          text,
          textAlign: TextAlign.left,
          style: const TextStyle(
            decoration:TextDecoration.none,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.cyan,
          ),
        );
}

class Post extends StatefulWidget {
  final Map data;
  const Post({Key? key, required this.data}) : super(key: key);

  @override
  PostState createState() => PostState();
}

class PostState extends State<Post> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Line(widget.data["Unnamed: 0"]),
        Line("ID объекта: ${widget.data["ID объекта"]}"),
        Line("Адрес объекта: ${widget.data["Адрес объекта"]}"),
        Line("Долгота: ${widget.data["Долгота"]}"),
        Line("Широта: ${widget.data["Широта"]}"),
        Line("Получателя услуги: ${widget.data["Получателя услуги"]}"),
        Line("Тип поста: ${widget.data["тип поста"]}"),
        Line("Колиество постов: ${widget.data["колиество постов"]}"),
        Line("Категория поста: ${widget.data["категория поста"]}"),
        Line("Стоимость часа: ${widget.data["стоимость часа"]}"),
        Line(
            "Количество часов в смену: ${widget.data["количество часов в смену"]}"),
        ElevatedButton(
          child: const Text("Выход"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
