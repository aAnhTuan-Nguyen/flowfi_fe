import '../../domain/entities/example_item.dart';

class ExampleItemModel {
  const ExampleItemModel({required this.id, required this.title});

  final String id;
  final String title;

  ExampleItem toEntity() => ExampleItem(id: id, title: title);
}
