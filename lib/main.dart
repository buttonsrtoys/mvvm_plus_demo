import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mvvm_plus/mvvm_plus.dart';
import 'package:bilocator/bilocator.dart';

void main() => runApp(myApp());

Widget myApp() => Bilocator<ColorService>(
      builder: () => ColorService(),
      child: MaterialApp(debugShowCheckedModeBanner: false, home: CounterPage()),
    );

class CounterPage extends View<CounterPageViewModel> {
  CounterPage({super.key}) : super(builder: () => CounterPageViewModel(), location: Location.registry);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Text(viewModel.text, style: TextStyle(fontSize: 64, color: listenTo<ColorService>().color)),
        ])),
        floatingActionButton: IncrementButton());
  }
}

class CounterPageViewModel extends ViewModel {
  int numberCount = 0;
  late final lowercaseCount = ValueNotifier<String>('a')..addListener(buildView);
  late final uppercaseCount = Property<String>('A')..addListener(buildView);
  // late final uppercaseCount = createProperty('A');

  void incrementNumber() {
    numberCount = numberCount == 25 ? 0 : numberCount + 1;
    buildView();
  }

  void incrementUppercase() => uppercaseCount.value =
      uppercaseCount.value == 'Z' ? 'A' : String.fromCharCode(uppercaseCount.value.codeUnits[0] + 1);

  void incrementLowercase() => lowercaseCount.value =
      lowercaseCount.value == 'z' ? 'a' : String.fromCharCode(lowercaseCount.value.codeUnits[0] + 1);

  String get text => numberCount.toString() + uppercaseCount.value + lowercaseCount.value;
}

class IncrementButton extends View<IncrementButtonViewModel> {
  IncrementButton({super.key}) : super(builder: () => IncrementButtonViewModel());

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: viewModel.incrementCounter,
      child: Text(viewModel.buttonText, style: const TextStyle(fontSize: 24)),
    );
  }
}

class IncrementButtonViewModel extends ViewModel {
  late final index = createProperty<int>(0);
  String get buttonText => <String>['+1', '+A', '+a'][index.value];
  void incrementCounter() {
    <void Function()>[
      get<CounterPageViewModel>().incrementNumber,
      get<CounterPageViewModel>().incrementUppercase,
      get<CounterPageViewModel>().incrementLowercase,
    ][index.value]();
    index.value = index.value == 2 ? 0 : index.value + 1;
  }
}

class ColorService extends Model {
  ColorService() {
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      color = <Color>[Colors.red, Colors.black, Colors.blue, Colors.orange][++_counter % 4];
      notifyListeners();
    });
  }

  int _counter = 0;
  Color color = Colors.orange;
  late Timer _timer;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
