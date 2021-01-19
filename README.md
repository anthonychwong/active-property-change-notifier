# Active Property Change Notifier

Actively pushes changes of itself and nested objects, including which property is changed, values before and after.

In other words, this can be partially observed, by either obtaining stream from `propertyChangesStreamOnPath` for one specific property, or combaining `when` on stream from `propertyChangesStream` for multiple properties.

| Package                                     | Version on pub.dev  |
| ------------------------------------------- | ------------------- |
| `active_property_change_notifier`           | [![](https://img.shields.io/pub/v/active_property_change_notifier)](https://pub.dev/packages/active_property_change_notifier) |
| `active_property_change_notifier_generator` | [![](https://img.shields.io/pub/v/active_property_change_notifier_generator)](https://pub.dev/packages/active_property_change_notifier_generator) |

## How to use

1. Add dependencies

   In `pubspec.yaml`, add the dependencies and run `pub get` to fetch the them.

   ```yaml
   dependencies:
     active_property_change_notifier:
     # other dependencies ...

   dev_dependencies:
     build_runner: 
     active_property_change_notifier_generator:
     # other dependencies ...
   ```

2. Declare data structure by mixin, add `part of` and annotations

   ```dart
   part 'main.g.dart';

   // other code ...

   @NotifyPropertyChange()
   mixin ObservableData on ActivePropertyChangeNotifier{
      int simpleProperty;
      String simpleStringProperty;
  
      @CustomField(ObservableData)
      @propagateChanges
      ObservableData nestedData;
   }

   // other code ...

   ```

   Usage of annotations
   - `NotifyPropertyChange` on the mixin to generate change notification codes
   - `CustomField` for object fields (since their type may not be properly obtained)
   - `propagateChanges` for other `ActivePropertyChangeNotifier` fields so that their changes would be streamed by the current one

3. Run code generation
   
   Run the command `flutter pub run build_runner build` to generate all the change notification boilerplates.

4. Enjoy

   ```dart
   ObservableData testSubject = ObservableDataImpl();
   
   testSubject
     .propertyChangesStreamOnPath("nestedData/simpleStringProperty")
     .listen((change){
       print("changes found in property ${change.propertyPath}.");
       // change.previousValue for value before change
       // change.currentValue for value after change
     });
   
   testSubject.nestedData.simpleProperty = 30;
   // output
   // > changes found in property nestedData/simpleStringProperty.
   ```

## Flutter Example

Since it comes with `Stream`s of property changes, use with `StreamBuilder` is easy.

```dart
StreamBuilder<int>(
  stream: testSubject
     .propertyChangesStreamOnPath("simpleProperty")
     .map((change) => change.currentValue),
  builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
      // code for other status ...
      if (snapshot.hasData) {
        return Text("count: ${snapshot.data}");
      }
    }
  }
)
```

## Limitations

Current design may vulnerable to race condition.

```dart
await Future.wait([
  Future.delayed(
    Duration(milliseconds: 50),
    () => testSubject.simpleProperty = 11 // this update never reflected.
  ),
  Future(() async {
    var stuff = testSubject.simpleProperty;
    await Future.delayed(Duration(milliseconds: 500));
    testSubject.simpleProperty = stuff + 100;
  })
]);
```

To avoid that, it should be used in situation with only one update source, e.g. only one "thread" doing the update, or use other state managment tools based on immutable states, such as `Redux`, `MobX` etc.

## TODO

- [ ] Unsubscribe the original when other `ActivePropertyChangeNotifier` instance is assign to fields annotated with `PropagateChanges`
- [ ] Allow customise generated class name
- [ ] Handle array
- [ ] Avoid manually typing property path
- [ ] Unit tests
- [ ] Document & API reference
