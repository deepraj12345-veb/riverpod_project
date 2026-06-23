import 'package:uuid/uuid.dart';
var uuid = const Uuid();

class Todo {
  String id;
  String title;
  String description;
  
  Todo({
    required this.title,
    required this.description,
    String? id,
  }) : id = id ?? uuid.v4();
}