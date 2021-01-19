import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:active_property_change_notifier_generator/src/property_change_notifier_generator.dart';

Builder propertyChangeNotifier(BuilderOptions options) =>
    SharedPartBuilder([PropertyChangeNotifierGenerator()], 'property_change_notifier');
