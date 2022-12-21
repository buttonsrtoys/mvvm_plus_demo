import 'package:flutter_test/flutter_test.dart';
import 'package:mvvm_plus_demo/main.dart';

void main() {
  int letterCount = 0;
  int numberCount = 0;
  int buildViewCount = 0;

  setUpAll(() {
    letterCount = 0;
    numberCount = 0;
    buildViewCount = 0;
  });

  void onIncrementNumber() => numberCount++;

  void onIncrementLetter() => letterCount++;

  IncrementButtonViewModel buildIncrementButtonViewModel() {
    final incrementButtonViewModel = IncrementButtonViewModel(
      onIncrementNumber: onIncrementNumber,
      onIncrementLetter: onIncrementLetter,
    );

    incrementButtonViewModel.buildView = () => buildViewCount++;

    return incrementButtonViewModel;
  }

  group("increment button", () {
    test("calls both callbacks in correct sequence", () {
      expect(letterCount, 0);
      expect(numberCount, 0);
      expect(buildViewCount, 0);

      final incrementButtonViewModel = buildIncrementButtonViewModel();

      incrementButtonViewModel.incrementCounter();

      expect(letterCount, 1);
      expect(numberCount, 0);
      expect(buildViewCount, 1);

      incrementButtonViewModel.incrementCounter();

      expect(letterCount, 1);
      expect(numberCount, 1);
      expect(buildViewCount, 2);
    });
  });
}
