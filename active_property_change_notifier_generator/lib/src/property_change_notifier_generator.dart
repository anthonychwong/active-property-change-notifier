import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';

import 'package:active_property_change_notifier/active_property_change_notifier.dart';

class PropertyChangeNotifierGenerator extends GeneratorForAnnotation<NotifyPropertyChange> {

  final _customFieldChecker = const TypeChecker.fromRuntime(CustomField);
  final _nestedChecker = const TypeChecker.fromRuntime(PropagateChanges);

  Iterable<String> getBody(ClassElement classElement) => 
    classElement.fields.map((e) {
      String name = e.displayName;
      String type = e.type.getDisplayString();
      String nested_logic = "";

      if (_customFieldChecker.hasAnnotationOfExact(e)) {
        type = _customFieldChecker
          .firstAnnotationOfExact(e)
          .getField('type')
          .toTypeValue()
          .getDisplayString();
      }

      if(_nestedChecker.hasAnnotationOfExact(e)){
        nested_logic = '''
    _${name}.propertyChangesStream()
      .map((e) => PropertyChange("${name}/" + e.propertyPath, e.previousValue, e.currentValue))
      .listen((e) => streamController.add(e));''';
      }

      return '''
  ${type} _${name};
  ${type} get ${name} => _${name};
  set ${name}(${type} value){
    if(_${name} == value) return;
    
    var previous = _${name};
    _${name} = value;
    streamController.add(PropertyChange("${name}", previous, value));${nested_logic}
  }
  ''';});
  
  @override
  FutureOr<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {

    if(element is ClassElement){
      ClassElement classElement = element;
      
      Iterable<String> body = getBody(classElement);

      return '''
class ${classElement.displayName}Impl extends ActivePropertyChangeNotifier with ${classElement.displayName}{
  ${body.join("\n  ")}
}''';
    }

    return "// Hey! Annotation found for " + element.displayName + "!";
  }
}
