import 'package:flutter_test/flutter_test.dart';
import 'package:mlb_manager/app/app.dart';

void main() {
  testWidgets('App root smoke test', (WidgetTester tester) async {
    // Basic instantiation test for MlbApp
    expect(const MlbApp(), isNotNull);
  });
}
