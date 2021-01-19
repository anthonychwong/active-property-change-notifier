import 'dart:async';
import 'package:meta/meta.dart';

class PropertyChange <T>{
  final String propertyPath;
  final T previousValue;
  final T currentValue;

  PropertyChange(this.propertyPath, this.previousValue, this.currentValue);
}

abstract class ActivePropertyChangeNotifier {
  @protected
  StreamController<PropertyChange> streamController;
  
  @mustCallSuper
  ActivePropertyChangeNotifier(){
    streamController = StreamController.broadcast(sync: true);
  }

  Stream<PropertyChange> propertyChangesStream() => streamController.stream;

  Stream<PropertyChange> propertyChangesStreamOnPath(String path) => streamController.stream.where((event) => event.propertyPath == path);

  @mustCallSuper
  void dispose(){
    streamController.close();
  }
}
