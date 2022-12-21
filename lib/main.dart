import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mvvm_plus/mvvm_plus.dart';
import 'package:bilocator/bilocator.dart';

void main() => runApp(myApp());

Widget myApp() => Bilocator<ColorService>(
    builder: () => ColorService(),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CounterPage(),
    ));

class CounterPage extends View<CounterPageViewModel> {
  CounterPage({super.key}) : super(builder: () => CounterPageViewModel(), location: Location.registry);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          Text(viewModel.letterCount.value,
              style: TextStyle(fontSize: 64, color: listenTo<ColorService>().color.value)),
          Text(viewModel.numberCount.toString(),
              style: TextStyle(fontSize: 64, color: listenTo<ColorService>().color.value)),
        ])),
        floatingActionButton: IncrementButton());
  }
}

class CounterPageViewModel extends ViewModel {
  int numberCount = 0;
  late final letterCount = ValueNotifier<String>('a')..addListener(buildView);

  void incrementNumber() {
    numberCount = numberCount == 25 ? 0 : numberCount + 1;
    buildView();
  }

  void incrementLetter() =>
      letterCount.value = letterCount.value == 'z' ? 'a' : String.fromCharCode(letterCount.value.codeUnits[0] + 1);
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
  late final isNumber = createProperty<bool>(false);
  String get buttonText => isNumber.value ? '+1' : '+a';
  void incrementCounter() {
    isNumber.value ? get<CounterPageViewModel>().incrementNumber() : get<CounterPageViewModel>().incrementLetter();
    isNumber.value = !isNumber.value;
  }
}

class ColorService extends Model {
  ColorService() {
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      color.value = <Color>[Colors.red, Colors.black, Colors.blue, Colors.orange][++_counter % 4];
    });
  }

  int _counter = 0;
  late final color = createProperty<Color>(Colors.orange);
  late Timer _timer;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
