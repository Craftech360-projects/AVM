// ignore_for_file: unused_local_variable

import 'package:altio/backend/mixpanel.dart';
import 'package:altio/backend/preferences.dart';
import 'package:altio/backend/schema/bt_device.dart';
import 'package:altio/core/assets/app_images.dart';
import 'package:altio/core/constants/constants.dart';
import 'package:altio/core/theme/app_colors.dart';
import 'package:altio/pages/home/custom_scaffold.dart';
import 'package:altio/utils/ble/connect.dart';
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
    var modelNumber = 'Altio';
    var firmwareRevision = '1.0.2';
    var hardwareRevision = 'Seed Xiao BLE Sense';
    var manufacturerName = 'CFT360 Design Studio';

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
  Widget build(BuildContext context) {
    var deviceId = widget.device?.id ?? SharedPreferencesUtil().deviceId;
    var deviceName = widget.device?.name ?? SharedPreferencesUtil().deviceName;
    var deviceConnected = widget.device != null;

    return CustomScaffold(
      showBackBtn: true,
      showGearIcon: true,
      title: Text("Manage Device",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 19)),
      body: FutureBuilder<_DeviceInfo>(
        future: _DeviceInfo.getDeviceInfo(widget.device),
        builder: (BuildContext context, AsyncSnapshot<_DeviceInfo> snapshot) {
          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset(AppImages.appLogo, width: 120),
                Column(
                  children: [
                    Text(
                      '$deviceName (${deviceId.replaceAll(':', '').split('-').last.substring(0, 6)})',
                      style: const TextStyle(
                        color: AppColors.purpleDark,
                        fontSize: 17.0,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    h8,
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
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: AppColors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.electric_bolt,
                                    size: 13,
                                    color: AppColors.white,
                                  ),
                                ),
                                w4,
                                Text(
                                  '${widget.batteryLevel.toString()}% Battery',
                                  style: const TextStyle(
                                    color: AppColors.purpleDark,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(),
                    h8,
                    InkWell(
                      onTap: () {
                        if (widget.device != null) {
                          bleDisconnectDevice(widget.device!);
                        }
                        SharedPreferencesUtil().deviceId = '';
                        SharedPreferencesUtil().deviceName = '';
                        avmSnackBar(context,
                            'Capsaul has been ${widget.device == null ? "unpaired" : "disconnected"} successfully.');
                        MixpanelManager().disconnectCapsaulClicked();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 22.0),
                        decoration: BoxDecoration(
                          color: AppColors.purpleDark.withValues(alpha: 0.9),
                          borderRadius: br12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.device == null
                                  ? Icons.bluetooth_disabled
                                  : Icons.bluetooth,
                              color: AppColors.white,
                            ),
                            Text(
                              widget.device == null
                                  ? "Unpair Device"
                                  : "Disconnect Device",
                              style: const TextStyle(
                                  color: AppColors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (snapshot.hasData)
                  Column(
                    children: [
                      Text(
                        '${snapshot.data?.modelNumber}, firmware ${snapshot.data?.firmwareRevision}',
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: AppColors.blueGreyDark,
                          fontSize: 13.0,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Designed by ${snapshot.data?.manufacturerName}',
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: AppColors.blueGreyDark,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      h8,
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
