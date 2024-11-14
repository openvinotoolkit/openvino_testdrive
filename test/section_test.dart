import 'package:flutter_test/flutter_test.dart';
// import 'package:inference/inference/speech/section.dart';

void main() {
  group("Section", () {
    group("process", () {
    //   test("process sets values in data", () async {
    //     final state = DynamicRangeLoading<int>(Section(0, 10));
    //     for (int j = 0; j < 10; j++) {
    //       await state.process((i) async {
    //         return j;
    //       });

    //       expect(state.data[j], j);
    //     }
    //   });

    //   test("process out of bounds throws error", () async {
    //     final state = DynamicRangeLoading<int>(Section(0, 10));
    //     for (int j = 0; j < 10; j++) {
    //       await state.process((i) async {
    //         return j;
    //       });
    //     }

    //     expect(() async {
    //       await state.process((i) async {
    //         return 1;
    //       });
    //     }, throwsException);
    //   });

    //   test("process continues after skip is done", () async {
    //     final state = DynamicRangeLoading<int>(Section(0, 10));
    //     state.skipTo(8);
    //     for (int j = 0; j < 2; j++) {
    //       await state.process((i) async {
    //         return j;
    //       });
    //     }
    //     expect(state.getNextIndex(), 0);
    //   });

    // });

    // test('getNextIndex throws error when state is complete', () {
    //     final state = DynamicRangeLoading<int>(Section(0, 0));
    //     expect(() {
    //       state.getNextIndex();
    //     },throwsException);
    // });

    // test('complete', () async {
    //     final state = DynamicRangeLoading<int>(Section(0, 10));
    //     for (int j = 0; j < 10; j++) {
    //       expect(state.complete, false);
    //       await state.process((i) async {
    //         return j;
    //       });
    //     }
    //     expect(state.complete, true);
    // });

    // group("skip", () {
    //   test("skips to specific index", () async {
    //     final state = DynamicRangeLoading<int>(Section(0, 10));
    //     state.skipTo(5);
    //     expect(state.getNextIndex(), 5);
    //     expect(state.activeSection.begin, 5);
    //     expect(state.activeSection.end, 10);
    //   });

    //   test("skips to partially complete section will go to end of that section ", () async {
    //     final state = DynamicRangeLoading<int>(Section(0, 10));

    //     for (int j = 0; j < 8; j++) {
    //       await state.process((i) async {
    //         return j;
    //       });
    //     }
    //     state.skipTo(5);
    //     expect(state.getNextIndex(), 8);
    //   });

    //   test("skips to fully complete section will not shift next index", () async {
    //     final state = DynamicRangeLoading<int>(Section(0, 10));
    //     state.skipTo(5);

    //     for (int j = 0; j < 5; j++) {
    //       await state.process((i) async {
    //         return j;
    //       });
    //     }
    //     state.skipTo(5);
    //     expect(state.getNextIndex(), 0);
    //   });
    });
  });
}
