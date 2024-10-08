// Future<void> _fetchServiceData() async {
//   // Iterate through each service
//   for (var service in _services) {
//     print('Service UUID: ${service.uuid.toString()}');

//     // Look for the specific service containing your desired characteristic
//     if (service.uuid.toString() == '19b10000-e8f2-537e-4f6c-d104768a1214') {
//       // Iterate through the characteristics of the service
//       for (var characteristic in service.characteristics) {
//         print('Characteristic UUID: ${characteristic.uuid.toString()}');

//         // Check if it's the characteristic with the value you're looking for (0x6D, 'm')
//         if (characteristic.uuid.toString() ==
//             '19b10003-e8f2-537e-4f6c-d104768a1214') {
//           try {
//             // Read the current value of the characteristic
//             var value = await characteristic.read();

//             // Convert the value (0x6D) into the character 'm'
//             if (value.isNotEmpty) {
//               String charValue = String.fromCharCode(value[0]);
//               print(
//                   'Read value from characteristic: $charValue'); // Should print 'm'
//               setState(() {
//                 swingSpeed = '$charValue'; // Use the value in your app
//               });
//             }
//           } catch (e) {
//             print(
//                 'Error reading characteristic ${characteristic.uuid.toString()}: $e');
//           }

//           // If the characteristic supports notifications, listen for data
//           if (characteristic.properties.notify) {
//             await characteristic.setNotifyValue(true);
//             characteristic.value.listen((value) {
//               // Handle notification updates
//               String charValue = String.fromCharCode(value[0]);
//               print('Notification from ${characteristic.uuid}: $charValue');
//             });
//           }
//         }
//       }
//     }
//   }
// }
