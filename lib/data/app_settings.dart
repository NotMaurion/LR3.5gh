import 'package:isar/isar.dart';

part 'app_settings.g.dart';

@collection
class AppSettings {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String key;

  String value;

  AppSettings({
    required this.key,
    required this.value,
  });
}
