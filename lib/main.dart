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
          Text(
            viewModel.text,
            style: TextStyle(
              fontSize: 64,
              color: listenTo<ColorService>().color.value,
            ),
          ),
        ])),
        floatingActionButton: IncrementButton(
          onIncrementLetter: viewModel.incrementLetter,
          onIncrementNumber: viewModel.incrementNumber,
        ));
  }
}

class CounterPageViewModel extends ViewModel {
  // late final letterCount = ValueNotifier<String>('a')..addListener(buildView);
  late final letterCount = createProperty<String>('a');
  late final numberCount = createProperty<int>(0);

  void incrementNumber() => numberCount.value = numberCount.value == 25 ? 0 : numberCount.value + 1;

  void incrementLetter() =>
      letterCount.value = letterCount.value == 'z' ? 'a' : String.fromCharCode(letterCount.value.codeUnits[0] + 1);

  String get text => letterCount.value + numberCount.value.toString();
}

class IncrementButton extends View<IncrementButtonViewModel> {
  IncrementButton({
    required VoidCallback onIncrementLetter,
    required VoidCallback onIncrementNumber,
    super.key,
  }) : super(
            builder: () => IncrementButtonViewModel(
                  onIncrementLetter: onIncrementLetter,
                  onIncrementNumber: onIncrementNumber,
                ));

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: viewModel.incrementCounter,
      child: Text(viewModel.buttonText, style: const TextStyle(fontSize: 24)),
    );
  }
}

class IncrementButtonViewModel extends ViewModel {
  IncrementButtonViewModel({
    required this.onIncrementLetter,
    required this.onIncrementNumber,
  });

  final VoidCallback onIncrementNumber;
  final VoidCallback onIncrementLetter;

  late final isNumber = createProperty<bool>(false);
  String get buttonText => isNumber.value ? '+1' : '+a';

  void incrementCounter() {
    isNumber.value ? onIncrementNumber() : onIncrementLetter();
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
