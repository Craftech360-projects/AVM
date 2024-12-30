import 'package:avm/backend/mixpanel.dart';
import 'package:avm/backend/preferences.dart';
import 'package:avm/backend/schema/bt_device.dart';
import 'package:avm/core/theme/app_colors.dart';
import 'package:avm/utils/ble/connect.dart';
<<<<<<< HEAD
import 'package:avm/core/widgets/device_widget.dart';
=======
import 'package:avm/widgets/device_widget.dart';
import 'package:flutter/material.dart';

// Update with the actual path to your CustomScaffold file
>>>>>>> origin/fix/reconnectdevice

class ConnectedDevice extends StatefulWidget {
  final BTDeviceStruct? device;
  final int batteryLevel;

  const ConnectedDevice(
      {super.key, required this.device, required this.batteryLevel});

  @override
  State<ConnectedDevice> createState() => _ConnectedDeviceState();
}

class _DeviceInfo {
  String modelNumber;
  String firmwareRevision;
  String hardwareRevision;
  String manufacturerName;

<<<<<<< HEAD
    return CustomScaffold(
        showBackBtn: true,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const DeviceAnimationWidget(),
            Text(
              "Connected to:",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            Text(
              '$deviceName (${deviceId.replaceAll(':', '').split('-').last.substring(0, deviceId.replaceAll(':', '').split('-').last.length > 6 ? 6 : deviceId.replaceAll(':', '').split('-').last.length)})',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            h20,
            widget.device != null
                ? Container(
                    decoration: BoxDecoration(
                      color: AppColors.black,
                      borderRadius: br10,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [],
                    ),
                  )
                : const SizedBox.shrink(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              decoration: BoxDecoration(
                color: AppColors.commonPink,
                // border: Border.all(color: AppColors.purpleBright),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextButton(
                onPressed: () {
                  if (widget.device != null) {
                    bleDisconnectDevice(widget.device!);
                  }
                  Navigator.of(context).pop();
                  SharedPreferencesUtil().deviceId = '';
                  SharedPreferencesUtil().deviceName = '';
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        'Your AVM is ${widget.device == null ? "unpaired" : "disconnected"}'),
                  ));
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FindDevicesPage(
                        isFromOnboarding: false,
                        goNext: () {},
                      ),
                    ),
                  );
                },
                child: Text(
                  widget.device == null ? "Unpair" : "Disconnect",
                  style: const TextStyle(
                      color: AppColors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ));
=======
  _DeviceInfo(this.modelNumber, this.firmwareRevision, this.hardwareRevision,
      this.manufacturerName);

  static Future<_DeviceInfo> getDeviceInfo(BTDeviceStruct? device) async {
    var modelNumber = 'AVM';
    var firmwareRevision = '1.0.2';
    var hardwareRevision = 'Seed Xiao BLE Sense';
    var manufacturerName = 'Craftech 360';

    if (device == null) {
      return _DeviceInfo(
          modelNumber, firmwareRevision, hardwareRevision, manufacturerName);
    }

    // String deviceId = device.id;

    // var deviceInformationService = await getServiceByUuid(deviceId, deviceInformationServiceUuid);
    // if (deviceInformationService != null) {
    //   var modelNumberCharacteristic = getCharacteristicByUuid(deviceInformationService, modelNumberCharacteristicUuid);
    //   if (modelNumberCharacteristic != null) {
    //     modelNumber = String.fromCharCodes(await modelNumberCharacteristic.read());
    //   }
    //
    //   var firmwareRevisionCharacteristic =
    //       getCharacteristicByUuid(deviceInformationService, firmwareRevisionCharacteristicUuid);
    //   if (firmwareRevisionCharacteristic != null) {
    //     firmwareRevision = String.fromCharCodes(await firmwareRevisionCharacteristic.read());
    //   }
    //
    //   var hardwareRevisionCharacteristic =
    //       getCharacteristicByUuid(deviceInformationService, hardwareRevisionCharacteristicUuid);
    //   if (hardwareRevisionCharacteristic != null) {
    //     hardwareRevision = String.fromCharCodes(await hardwareRevisionCharacteristic.read());
    //   }
    //
    //   var manufacturerNameCharacteristic =
    //       getCharacteristicByUuid(deviceInformationService, manufacturerNameCharacteristicUuid);
    //   if (manufacturerNameCharacteristic != null) {
    //     manufacturerName = String.fromCharCodes(await manufacturerNameCharacteristic.read());
    //   }
    // }

    return _DeviceInfo(
      modelNumber,
      firmwareRevision,
      hardwareRevision,
      manufacturerName,
    );
  }
}

class _ConnectedDeviceState extends State<ConnectedDevice> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var deviceId = widget.device?.id ?? SharedPreferencesUtil().deviceId;
    var deviceName = widget.device?.name ?? SharedPreferencesUtil().deviceName;
    var deviceConnected = widget.device != null;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(deviceConnected ? 'Connected Device' : 'Paired Device',
            style: TextStyle(
                color: AppColors.grey,
                fontSize: 20,
                fontWeight: FontWeight.w500)),
        backgroundColor: AppColors.white,
      ),
      body: FutureBuilder<_DeviceInfo>(
        future: _DeviceInfo.getDeviceInfo(widget.device),
        builder: (BuildContext context, AsyncSnapshot<_DeviceInfo> snapshot) {
          return Column(
            children: [
              const SizedBox(height: 32),
              const DeviceAnimationWidget(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    '$deviceName (${deviceId.replaceAll(':', '').split('-').last.substring(0, 6)})',
                    style: const TextStyle(
                      color: AppColors.purpleDark,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  if (snapshot.hasData)
                    Column(
                      children: [
                        Text(
                          '${snapshot.data?.modelNumber}, firmware ${snapshot.data?.firmwareRevision}',
                          style: const TextStyle(
                            color: AppColors.blueGreyDark,
                            fontSize: 10.0,
                            fontWeight: FontWeight.w500,
                            height: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'by ${snapshot.data?.manufacturerName}',
                          style: const TextStyle(
                            color: AppColors.greyMedium,
                            fontSize: 10.0,
                            fontWeight: FontWeight.w500,
                            height: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  widget.device != null
                      ? Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: widget.batteryLevel > 75
                                      ? const Color.fromARGB(255, 0, 255, 8)
                                      : widget.batteryLevel > 20
                                          ? Colors.yellow.shade700
                                          : Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                '${widget.batteryLevel.toString()}% Battery',
                                style: const TextStyle(
                                  color: AppColors.purpleDark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ))
                      : const SizedBox.shrink()
                ],
              ),
              const SizedBox(height: 32),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(83, 158, 158, 158),
                    border: Border.all(color: Colors.grey),
                    // border: const GradientBoxBorder(
                    //   gradient: LinearGradient(colors: [
                    //     Color.fromARGB(127, 208, 208, 208),
                    //     Color.fromARGB(127, 188, 99, 121),
                    //     Color.fromARGB(127, 86, 101, 182),
                    //     Color.fromARGB(127, 126, 190, 236)
                    //   ]),
                    //   width: 2,
                    // ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextButton(
                      onPressed: () {
                        if (widget.device != null) {
                          bleDisconnectDevice(widget.device!);
                        }
                        Navigator.of(context).pop();
                        SharedPreferencesUtil().deviceId = '';
                        SharedPreferencesUtil().deviceName = '';
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'Your AVM is ${widget.device == null ? "unpaired" : "disconnected"}   😔'),
                        ));
                        MixpanelManager().disconnectFriendClicked();
                      },
                      child: Text(
                        widget.device == null ? "Unpair" : "Disconnect",
                        style:
                            const TextStyle(color: AppColors.red, fontSize: 16),
                      )))
            ],
          );
        },
      ),
    );
>>>>>>> origin/fix/reconnectdevice
  }
}
