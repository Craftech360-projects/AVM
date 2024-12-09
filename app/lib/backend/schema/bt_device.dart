// ignore_for_file: public_member_api_docs, sort_constructors_first
class BTDeviceStruct {
  String name;
  String id;
  int? rssi;
  List<int>? fwver;

  BTDeviceStruct({
    required this.id,
    required this.name,
    this.rssi,
    this.fwver,
  });

  factory BTDeviceStruct.fromJson(Map<String, dynamic> json) {
    return BTDeviceStruct(
      id: json['id'] as String,
      name: json['name'] as String,
      rssi: json['rssi'] as int?,
      fwver: json['fwver'] as List<int>?,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'rssi': rssi, 'fwver': fwver?.toList()};

  @override
  String toString() {
    return 'BTDeviceStruct(name: $name, id: $id, rssi: $rssi, fwver: $fwver)';
  }
}
