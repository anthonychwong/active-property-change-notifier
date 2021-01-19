import 'package:active_property_change_notifier/active_property_change_notifier.dart';

part 'main.g.dart';

@NotifyPropertyChange()
mixin ObservableData on ActivePropertyChangeNotifier{
  int simpleProperty;
  String simpleStringProperty;

  @CustomField(ObservableData)
  @propagateChanges
  ObservableData nestedData;
}

void main() async {
  ObservableData testSubject = ObservableDataImpl();
  
  testSubject.propertyChangesStream().listen((change){
    print("value changed on ${change.propertyPath} from ${change.previousValue} to ${change.currentValue}");
  });
  testSubject.propertyChangesStream().listen((change) => print("another listener found changes in path: ${change.propertyPath}"));
  testSubject.propertyChangesStreamOnPath("nestedData/simpleStringProperty").listen((change) => print("only listen for path ${change.propertyPath}."));
  
  testSubject.nestedData = ObservableDataImpl();
  
  testSubject.simpleProperty = 10;
  testSubject.simpleStringProperty = "Hello";
  testSubject.nestedData.simpleProperty = 20;
  testSubject.nestedData.simpleStringProperty = "Hello";
  
  testSubject.simpleProperty = 20;
  testSubject.simpleStringProperty = "Hello world";
  testSubject.nestedData.simpleProperty = 30;
  testSubject.nestedData.simpleStringProperty = "Hello world";
}
