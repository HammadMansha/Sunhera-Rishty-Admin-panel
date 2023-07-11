import 'package:flutter/cupertino.dart';

class ConnectionProvider with ChangeNotifier {
  Map<String, bool> connection = {};
  setConnection(Map map) {
    connection.clear();
    map.forEach((key, value) {
      if (value is bool) {
        connection[key] = value;
      } else {
        connection[key] = value['accepted'] ?? false;
      }
    });
    print("------------------------ Connection ${connection.toString()}");
    notifyListeners();
  }

  bool? checkConnection(id) {
    if (connection[id] == null) {
      return false;
    }
    return connection[id];
  }
}
