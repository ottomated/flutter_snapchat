import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapkit/snapkit.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_snapkit');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await SnapKitPlugin.platformVersion, '42');
  });
}
