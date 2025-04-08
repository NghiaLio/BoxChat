import 'dart:ui';

class Colortheme {
  static List<Color> colorList = const [
    Color.fromRGBO(32, 160, 144, 1.0),
    Color.fromRGBO(99 ,184 ,255 ,1.0),
    Color.fromRGBO(255, 110, 180 ,1.0),
    Color.fromRGBO(224 ,102, 255, 1.0)
  ];

  static String colorToRGBA(Color color){
    return '${color.red},${color.green},${color.blue},${color.alpha}';
  }

  static Color rgbaToColor(String input){
    List<String> parts = input.split(',');
    return Color.fromARGB(int.parse(parts[3]), int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }
}