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
        floatingActionButton: IncrementButton(incrementLowercase: viewModel.incrementLowercase));
  }
}

class CounterPageViewModel extends ViewModel {
  int numberCount = 0;
  late final uppercaseCount = ValueNotifier<String>('A')..addListener(buildView);
  late final lowercaseCount = Property<String>('a')..addListener(buildView);
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
  IncrementButton({required VoidCallback incrementLowercase, super.key})
      : super(builder: () => IncrementButtonViewModel(incrementLowercase: incrementLowercase));

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: viewModel.incrementCounter,
      child: Text(viewModel.buttonText, style: const TextStyle(fontSize: 24)),
    );
  }
}

class IncrementButtonViewModel extends ViewModel {
  IncrementButtonViewModel({required this.incrementLowercase});
  final VoidCallback incrementLowercase;
  late final index = createProperty<int>(0);
  String get buttonText => <String>['+1', '+A', '+a'][index.value];
  void incrementCounter() {
    <VoidCallback>[
      get<CounterPageViewModel>().incrementNumber,
      get<CounterPageViewModel>().incrementUppercase,
      incrementLowercase,
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

  late Timer _timer;
  Color color = Colors.orange;
  int _counter = 0;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
