import 'package:capsoul/backend/schema/bt_device.dart';
import 'package:capsoul/features/capture/presentation/capture_page.dart';
import 'package:capsoul/features/connectivity_bloc/connectivity_bloc.dart';
import 'package:capsoul/features/memories/bloc/memory_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'capture_page_test.mocks.dart';

@GenerateMocks([BTDeviceStruct])
void main() {
  late MockBTDeviceStruct mockBTDevice;
  late MemoryBloc memoryBloc;
  late ConnectivityBloc connectivityBloc;

  setUp(() {
    mockBTDevice = MockBTDeviceStruct();
    when(mockBTDevice.id).thenReturn('mockDeviceId');

    memoryBloc = MemoryBloc();
    connectivityBloc = ConnectivityBloc();
  });

  tearDown(() {
    memoryBloc.close();
    connectivityBloc.close();
  });
  group('CapturePage Initial State', () {
    testWidgets('CapturePage renders with MemoryBloc', (tester) async {
      (tester) async {
        // Pump the widget
        await tester.pumpWidget(MaterialApp(
          home: CapturePage(
            device: mockBTDevice,
            refreshMemories: () {},
            refreshMessages: () {},
            batteryLevel: 50,
            hasSeenTutorial: true,
          ),
        ));

        // Check for widget tree rendering
        expect(find.byType(CapturePage), findsOneWidget);
      };
    });

    test('should initialize CapturePageState with default values', () {
      final capturePageState = CapturePageState();

      // Validate initial state variables
      expect(capturePageState.segments, isEmpty);
      expect(capturePageState.dismissedList, isEmpty);
      expect(capturePageState.btDevice, isNull);
      expect(capturePageState.memoryCreating, isFalse);
      //  expect(capturePageState._hasTranscripts, isFalse);
      expect(capturePageState.streamStartedAtSecond, isNull);
      expect(capturePageState.firstStreamReceivedAt, isNull);
      expect(capturePageState.secondsMissedOnReconnect, isNull);
      expect(capturePageState.conversationId, isNotEmpty);
    });

    test('should initialize with provided BTDevice', () {
      final capturePageState = CapturePageState();
      capturePageState.btDevice = mockBTDevice;

      expect(capturePageState.btDevice, isNotNull);
      expect(capturePageState.btDevice!.id, equals('mockDeviceId'));
    });

    test('should initialize with AutomaticKeepAliveClientMixin', () {
      final capturePageState = CapturePageState();

      // Check the wantKeepAlive property from mixin
      expect(capturePageState.wantKeepAlive, isTrue);
    });

    // testWidgets('should initialize CaptureMemoryPage with correct data',
    //     (tester) async {
    //   // Pump the widget with required BlocProviders
    //   await tester.pumpWidget(
    //     MultiBlocProvider(
    //       providers: [
    //         BlocProvider<MemoryBloc>.value(value: memoryBloc),
    //         BlocProvider<ConnectivityBloc>.value(value: connectivityBloc),
    //       ],
    //       child: MaterialApp(
    //         home: CapturePage(
    //           device: mockBTDevice,
    //           refreshMemories: () {},
    //           refreshMessages: () {},
    //           batteryLevel: 100,
    //           hasSeenTutorial: true,
    //         ),
    //       ),
    //     ),
    //   );

    //   // Verify the child widget (CaptureMemoryPage) receives correct initial values
    //   final captureMemoryPage =
    //       tester.widget<CaptureMemoryPage>(find.byType(CaptureMemoryPage));
    //   expect(captureMemoryPage.device, equals(mockBTDevice));
    //   expect(captureMemoryPage.hasSeenTutorial, isTrue);
    //   expect(captureMemoryPage.memoryCreating, isFalse);
    //   expect(captureMemoryPage.hasTranscripts, isFalse);
    // });
  });
}
