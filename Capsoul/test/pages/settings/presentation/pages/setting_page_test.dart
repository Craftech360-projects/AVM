// import 'dart:async';

// import 'package:capsoul/backend/schema/bt_device.dart';
// import 'package:capsoul/features/bluetooth_bloc/bluetooth_bloc.dart';
// import 'package:capsoul/pages/onboarding/page.dart';
// import 'package:capsoul/pages/settings/presentation/pages/setting_page.dart';
// import 'package:capsoul/src/common_widget/list_tile.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:package_info_plus/package_info_plus.dart';

// // Mock BluetoothBloc
// class MockBluetoothBloc extends Mock implements BluetoothBloc {}

// void main() {
//   late MockBluetoothBloc mockBluetoothBloc;

//   setUp(() {
//     mockBluetoothBloc = MockBluetoothBloc();

//     PackageInfo.setMockInitialValues(
//       appName: 'Capsoul',
//       packageName: 'com.example.capsoul',
//       version: '1.0.0',
//       buildNumber: '1',
//       buildSignature: '',
//     );
//   });

//   Widget createWidgetUnderTest() {
//     return ScreenUtilInit(
//       designSize: const Size(1080, 1920),
//       minTextAdapt: true,
//       splitScreenMode: true,
//       builder: (context, child) {
//         return MaterialApp(
//           home: BlocProvider<BluetoothBloc>.value(
//             value: mockBluetoothBloc,
//             child: const SettingPage(),
//           ),
//         );
//       },
//     );
//   }

//   group('SettingPage', () {
//     testWidgets('renders Settings page with correct version info',
//         (WidgetTester tester) async {
//       // Arrange
//       when(() => mockBluetoothBloc.state).thenReturn(BluetoothInitial());

//       await tester.binding.setSurfaceSize(
//         const Size(1080, 1920),
//       );

//       // Act
//       await tester.pumpWidget(createWidgetUnderTest());
//       await tester.pumpAndSettle();

//       // Assert
//       expect(find.text('Settings'), findsOneWidget);
//       expect(find.textContaining('Version: '), findsOneWidget);
//       expect(find.text('Device not connected'), findsOneWidget);
//     });

//     testWidgets('displays correct device info when connected',
//         (WidgetTester tester) async {
//       // Arrange
//       final connectedDevice = BTDeviceStruct(
//         id: '123',
//         name: 'Test Device',
//       );

//       when(() => mockBluetoothBloc.state)
//           .thenReturn(BluetoothConnected(connectedDevice, batteryLevel: 80));

//       await tester.binding.setSurfaceSize(
//         const Size(1080, 1920),
//       );

//       // Act
//       await tester.pumpWidget(createWidgetUnderTest());
//       await tester.pumpAndSettle();

//       // Assert
//       expect(find.text('Battery Level: 80%'), findsOneWidget);
//     });

//     testWidgets('navigates to ConnectedDevice page when device is connected',
//         (WidgetTester tester) async {
//       // Arrange
//       final connectedDevice = BTDeviceStruct(
//         id: '123',
//         name: 'Test Device',
//       );

//       when(() => mockBluetoothBloc.state)
//           .thenReturn(BluetoothConnected(connectedDevice, batteryLevel: 80));

//       await tester.binding.setSurfaceSize(
//         const Size(1080, 1920),
//       );

//       // Act
//       await tester.pumpWidget(createWidgetUnderTest());

//       // Find the device info tile and tap it
//       final deviceTile = find.byType(CustomListTile);
//       expect(deviceTile, findsOneWidget);

//       // Simulate a tap on the device tile
//       await tester.tap(deviceTile);
//       await tester.pumpAndSettle();

//       // Assert: Check if the ConnectedDevice page is displayed
//       expect(find.byType(ConnectedDevice), findsOneWidget);
//     });

//     testWidgets('navigates to FindDevicesPage when device is disconnected',
//         (WidgetTester tester) async {
//       // Arrange
//       when(() => mockBluetoothBloc.state).thenReturn(BluetoothDisconnected());

//       await tester.binding.setSurfaceSize(
//         const Size(1080, 1920),
//       );

//       // Act
//       await tester.pumpWidget(createWidgetUnderTest());

//       // Find the device info tile and tap it
//       final deviceTile = find.byType(CustomListTile);
//       expect(deviceTile, findsOneWidget);

//       // Simulate a tap on the device tile
//       await tester.tap(deviceTile);
//       await tester.pumpAndSettle();

//       // Assert: Check if the FindDevicesPage is displayed
//       expect(find.byType(FindDevicesPage), findsOneWidget);
//     });

//     tearDown(() {
//       mockBluetoothBloc.close();
//       TestWidgetsFlutterBinding.ensureInitialized()
//           .window
//           .clearPhysicalSizeTestValue();
//     });
//   });
// }

//     // testWidgets('tap on Profile navigates to ProfilePage', (tester) async {
//     //   // Act: Build the widget tree for SettingPage
//     //   await tester.pumpWidget(
//     //     MaterialApp(
//     //       home: BlocProvider(
//     //         create: (_) => mockBluetoothBloc,
//     //         child: const SettingPage(),
//     //       ),
//     //     ),
//     //   );

//     //   // Find the Profile tile and tap it
//     //   final profileTile = find.byWidgetPredicate(
//     //     (widget) => widget is ItemAddOn && widget.title == 'Profile',
//     //   );
//     //   expect(profileTile, findsOneWidget);

//     //   await tester.tap(profileTile);
//     //   await tester.pumpAndSettle();

//     //   // Assert: Ensure that the ProfilePage is pushed
//     //   expect(
//     //     find.text('ProfilePage'),
//     //     findsOneWidget, // Update with actual title
//     //   );
//     // });
//   });
// }

import 'package:capsoul/backend/schema/bt_device.dart';
import 'package:capsoul/features/bluetooth_bloc/bluetooth_bloc.dart';
import 'package:capsoul/pages/home/device.dart';
import 'package:capsoul/pages/onboarding/page.dart';
import 'package:capsoul/pages/settings/presentation/pages/setting_page.dart';
import 'package:capsoul/src/common_widget/list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Mock BluetoothBloc
class MockBluetoothBloc extends Mock implements BluetoothBloc {
  @override
  Future<void> close() => Future.value();
}

void main() {
  late MockBluetoothBloc mockBluetoothBloc;

  setUp(() {
    mockBluetoothBloc = MockBluetoothBloc();

    PackageInfo.setMockInitialValues(
      appName: 'Capsoul',
      packageName: 'com.example.capsoul',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  Widget createWidgetUnderTest() {
    return ScreenUtilInit(
      designSize: const Size(1080, 1920),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          home: BlocProvider<BluetoothBloc>.value(
            value: mockBluetoothBloc,
            child: const SettingPage(),
          ),
        );
      },
    );
  }

  group('SettingPage', () {
    testWidgets('renders Settings page with correct version info',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockBluetoothBloc.state).thenReturn(BluetoothInitial());

      await tester.binding.setSurfaceSize(
        const Size(1080, 1920),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Settings'), findsOneWidget);
      expect(find.textContaining('Version: '), findsOneWidget);
      expect(find.text('Device not connected'), findsOneWidget);
    });

    testWidgets('displays correct device info when connected',
        (WidgetTester tester) async {
      // Arrange
      final connectedDevice = BTDeviceStruct(
        id: '123',
        name: 'Test Device',
      );

      when(() => mockBluetoothBloc.state)
          .thenReturn(BluetoothConnected(connectedDevice, batteryLevel: 80));

      await tester.binding.setSurfaceSize(
        const Size(1080, 1920),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Battery Level: 80%'), findsOneWidget);
    });

    testWidgets('navigates to ConnectedDevice page when device is connected',
        (WidgetTester tester) async {
      // Arrange
      final connectedDevice = BTDeviceStruct(
        id: '123',
        name: 'Test Device',
      );

      when(() => mockBluetoothBloc.state)
          .thenReturn(BluetoothConnected(connectedDevice, batteryLevel: 80));

      await tester.binding.setSurfaceSize(
        const Size(1080, 1920),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Find the device info tile and tap it
      final deviceTile = find.byType(CustomListTile);
      expect(deviceTile, findsOneWidget);

      // Simulate a tap on the device tile
      await tester.tap(deviceTile);
      await tester.pumpAndSettle();

      // Assert: Check if the ConnectedDevice page is displayed
      expect(find.byType(ConnectedDevice), findsOneWidget);
    });

    testWidgets('navigates to FindDevicesPage when device is disconnected',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockBluetoothBloc.state).thenReturn(BluetoothDisconnected());

      await tester.binding.setSurfaceSize(
        const Size(1080, 1920),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Find the device info tile and tap it
      final deviceTile = find.byType(CustomListTile);
      expect(deviceTile, findsOneWidget);

      // Simulate a tap on the device tile
      await tester.tap(deviceTile);
      await tester.pumpAndSettle();

      // Assert: Check if the FindDevicesPage is displayed
      expect(find.byType(FindDevicesPage), findsOneWidget);
    });

    tearDown(() {
      mockBluetoothBloc.close();
      TestWidgetsFlutterBinding.ensureInitialized()
          .window
          .clearPhysicalSizeTestValue();
    });
  });
}
