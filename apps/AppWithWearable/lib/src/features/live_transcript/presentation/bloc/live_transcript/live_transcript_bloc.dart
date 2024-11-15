import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:friend_private/backend/schema/bt_device.dart';
import 'package:friend_private/src/features/live_transcript/data/datasources/ble_connection_datasource.dart';
import 'package:friend_private/src/features/live_transcript/presentation/bloc/connection/connection_bloc.dart';
import 'package:friend_private/utils/audio/wav_bytes.dart';
import 'package:friend_private/utils/ble/gatt_utils.dart';
import 'package:friend_private/utils/websockets.dart';

part 'live_transcript_event.dart';
part 'live_transcript_state.dart';

// enum BleAudioCodec { pcm16, pcm8, mulaw16, mulaw8, opus, unknown }

class LiveTranscriptBloc
    extends Bloc<LiveTranscriptEvent, LiveTranscriptState> {
  StreamSubscription<BluetoothAdapterState>? _bleAdapterSubscription;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<List<int>>? _audioDataSubscription;
  StreamSubscription<List<int>>? _batteryLevelSubscription;

  LiveTranscriptBloc() : super(LiveTranscriptState.initial()) {
    on<ScannedDevices>((event, emit) => _startListeningAdapterState());
    on<_AdapterListener>((event, emit) => _handleAdapterState(event, emit));
    on<_ScanListener>((event, emit) => _emitScanResults(event, emit));
    on<SelectedDevice>((event, emit) => _connectToDevice(event, emit));
    on<_BleConnectionListener>(
        (event, emit) => _handleConnectionState(event, emit));
    on<_AudioListener>((event, emit) => _handleAudioData(event, emit));
    on<_BatteryListener>((event, emit) => _emitBatteryLevel(event, emit));
    on<DisconnectDevice>((event, emit) => _disconnectDevice(event, emit));
  }

  /// Start listening for Bluetooth adapter state changes
  void _startListeningAdapterState() {
    _bleAdapterSubscription?.cancel();
    _bleAdapterSubscription = FlutterBluePlus.adapterState.listen((state) {
      add(_AdapterListener(bleAdapterState: state));
    });
  }

  /// Handle Bluetooth adapter state changes
  Future<void> _handleAdapterState(
      _AdapterListener event, Emitter<LiveTranscriptState> emit) async {
    if (event.bleAdapterState == BluetoothAdapterState.on) {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 5),
        withServices: [Guid("19b10000-e8f2-537e-4f6c-d104768a1214")],
        androidScanMode: AndroidScanMode.lowLatency,
      );

      _scanSubscription?.cancel();
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        add(_ScanListener(devices: results));
      });
    }
  }

  /// Emit scan results as state
  void _emitScanResults(
      _ScanListener event, Emitter<LiveTranscriptState> emit) {
    final visibleDevices = event.devices.map((result) {
      return BTDeviceStruct(
        id: result.device.remoteId.toString(),
        name: result.device.platformName,
        rssi: result.rssi,
      );
    }).toList();

    emit(state.copyWith(
      bleConnectionStatus: BluetoothDeviceStatus.searching,
      visibleDevices: visibleDevices,
    ));
  }

  /// Handle device connection logic
  Future<void> _connectToDevice(
      SelectedDevice event, Emitter<LiveTranscriptState> emit) async {
    final device = BluetoothDevice.fromId(event.connectedDevice.id);
    emit(state.copyWith(bleConnectionStatus: BluetoothDeviceStatus.processing));
    await device.connect(mtu: null, autoConnect: true);

    emit(state.copyWith(
      bleConnectionStatus: BluetoothDeviceStatus.connected,
      connectedDevice: event.connectedDevice,
    ));

    _connectionSubscription?.cancel();
    _connectionSubscription = device.connectionState.listen((connectionState) {
      add(_BleConnectionListener(bleListener: connectionState));
    });
  }

  /// Handle BLE connection state changes
  Future<void> _handleConnectionState(
      _BleConnectionListener event, Emitter<LiveTranscriptState> emit) async {
    if (event.bleListener == BluetoothConnectionState.connected) {
      emit(
          state.copyWith(bleConnectionStatus: BluetoothDeviceStatus.connected));
      await _initiateBatteryListener();
      await _fetchAudioCodec();
      await _initiateAudioListener();
    } else {
      emit(state.copyWith(
          bleConnectionStatus: BluetoothDeviceStatus.disconnected));
    }
  }

  Future<void> _fetchAudioCodec() async {
    final audioCodecService =
        await getServiceByUuid(state.connectedDevice!.id, friendServiceUuid);
    if (audioCodecService == null) return;

    var audioCodecCharacteristic = getCharacteristicByUuid(
        audioCodecService, audioCodecCharacteristicUuid);
    if (audioCodecCharacteristic == null) return;

    List<int> codecValue = await audioCodecCharacteristic.read();
    if (codecValue.isNotEmpty) {
      final codecId = codecValue.first;
      final codec = _mapCodecIdToEnum(codecId);
      // print('Codec details: $codecId, codec: $codec');
      emit(
        state.copyWith(
          // bleConnectionStatus: BluetoothDeviceStatus.connected,
          codec: codec,
        ),
      );
    }
  }

  BleAudioCodec _mapCodecIdToEnum(int codecId) {
    switch (codecId) {
      case 0:
        return BleAudioCodec.pcm16;
      case 1:
        return BleAudioCodec.pcm8;
      case 20:
        return BleAudioCodec.opus;
      default:
        return BleAudioCodec.unknown;
    }
  }

  Future<void> _initiateAudioListener() async {
    final device = BluetoothDevice.fromId(state.connectedDevice!.id);
    if (Platform.isAndroid) {
      await device.requestMtu(512);
    }
    final friendService =
        await getServiceByUuid(state.connectedDevice!.id, friendServiceUuid);
    //  // print(
    //       'remote id received ${state.connectedDevice!.id}: $friendServiceUuid');
    if (friendService == null) return;

    var audioDataCharacteristic = getCharacteristicByUuid(
        friendService, audioDataStreamCharacteristicUuid);
    if (audioDataCharacteristic == null) return;

    await audioDataCharacteristic.setNotifyValue(true);
    // print('Subscribed to audioBytes stream from AVM Device');

    _audioDataSubscription?.cancel();
    _audioDataSubscription =
        audioDataCharacteristic.lastValueStream.listen((rawAudio) {
      // log('is raw data received in bloc $rawAudio');
      add(_AudioListener(rawAudio: rawAudio));
    });

    device.cancelWhenDisconnected(_audioDataSubscription!);
  }

  Future<void> _initiateBatteryListener() async {
    final batteryService =
        await getServiceByUuid(state.connectedDevice!.id, batteryServiceUuid);
    if (batteryService == null) return;

    var batteryLevelCharacteristic =
        getCharacteristicByUuid(batteryService, batteryLevelCharacteristicUuid);
    if (batteryLevelCharacteristic == null) return;

    await batteryLevelCharacteristic.setNotifyValue(true);
    _batteryLevelSubscription?.cancel();
    _batteryLevelSubscription =
        batteryLevelCharacteristic.lastValueStream.listen((value) {
      add(_BatteryListener(value: value));
    });
  }

  /// Emit battery level updates to the state
  void _emitBatteryLevel(
      _BatteryListener event, Emitter<LiveTranscriptState> emit) {
    if (event.value.isNotEmpty) {
      emit(state.copyWith(
        bleBatteryLevel: event.value[0],
        bleConnectionStatus: BluetoothDeviceStatus.connected,
      ));
    }
  }

  /// Handle received audio data
  void _handleAudioData(
      _AudioListener event, Emitter<LiveTranscriptState> emit) {
    List<int> rawAudio = event.rawAudio;

    if (rawAudio.isEmpty) {
      log('Audio data is empty. Skipping processing.');
      return;
    }
    //print('Received Raw Audio (Before Trimming): ${rawAudio}');
    final codec = state.codec;
    //  print(codec);
    WavBytesUtil audioStorage =
        WavBytesUtil(codec: codec ?? BleAudioCodec.unknown);
    // rawAudio.removeRange(0, 3);

    // audioStorage.storeFramePacket(rawAudio);

    // if (state.wsConnectionState == WebsocketConnectionStatus.connected) {
    //   try {
    //     websocketChannel?.sink
    //         .add(rawAudio); // Send the raw audio data to WebSocket
    //     log('Audio data sent to WebSocket: ${rawAudio.length} bytes');
    //   } catch (e) {
    //     log('Failed to send audio data to WebSocket: $e');
    //   }
    // } else {
    //   log('WebSocket is not connected. Cannot send audio data.');
    // }

    // print('Processed Audio (After Trimming): ${rawAudio}');

    // Instead of storing, you can directly send the raw audio
    if (rawAudio.isNotEmpty) {
      //   // Assuming context is available for accessing the WebSocketBloc
      final websocketBloc = WebSocketBloc();
      websocketBloc.add(SendMessageWebSocket(rawAudio));
      log('Audio data sent to WebSocket: ${rawAudio.length} bytes');
    } else {
      // log('Processed audio is empty, nothing to send.');
    }
  }

  /// Handle device disconnection
  Future<void> _disconnectDevice(
      DisconnectDevice event, Emitter<LiveTranscriptState> emit) async {
    final device = BluetoothDevice.fromId(event.btDeviceStruct.id);
    await device.disconnect();
    _cleanupSubscriptions();

    emit(LiveTranscriptState.initial());
    add(ScannedDevices());
  }

  /// Cleanup all active subscriptions
  void _cleanupSubscriptions() {
    _bleAdapterSubscription?.cancel();
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    _audioDataSubscription?.cancel();
    _batteryLevelSubscription?.cancel();
  }

  @override
  Future<void> close() {
    _cleanupSubscriptions();
    return super.close();
  }
}
