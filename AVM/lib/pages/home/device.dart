import 'package:avm/backend/mixpanel.dart';
import 'package:avm/backend/preferences.dart';
import 'package:avm/backend/schema/bt_device.dart';
import 'package:avm/core/assets/app_images.dart';
import 'package:avm/core/constants/constants.dart';
import 'package:avm/core/theme/app_colors.dart';
import 'package:avm/pages/home/custom_scaffold.dart';
import 'package:avm/utils/ble/connect.dart';
import 'package:flutter/material.dart';

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

    return CustomScaffold(
      showBackBtn: true,
      showGearIcon: true,
      title: Text(deviceConnected ? 'Connected Device' : 'No Device Connected',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 19)),
      body: FutureBuilder<_DeviceInfo>(
        future: _DeviceInfo.getDeviceInfo(widget.device),
        builder: (BuildContext context, AsyncSnapshot<_DeviceInfo> snapshot) {
          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(AppImages.appLogo, height: 120, width: 120),
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
                h10,
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
                      h15,
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
                      h10,
                    ],
                  ),
                widget.device != null
                    ? Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: br10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: widget.batteryLevel > 75
                                    ? AppColors.green
                                    : widget.batteryLevel > 20
                                        ? AppColors.orange
                                            .withValues(alpha: 0.5)
                                        : AppColors.red,
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
                    : Container(),
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
                            'Your AVM is ${widget.device == null ? "unpaired" : "disconnected"} 😔'),
                      ));
                      MixpanelManager().disconnectFriendClicked();
                    },
                    child: Text(
                      widget.device == null ? "Unpair" : "Disconnect",
                      style:
                          const TextStyle(color: AppColors.red, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
