class Bin {
  String name;
  num volume;
  num? latitude;
  num? longitude;
  int? timestamp;

  Bin({
    required this.name,
    required this.volume,
    this.latitude,
    this.longitude,
    this.timestamp,
  });

  @override
  String toString() {
    return '{ ${this.name}, ${this.volume} }';
  }
}
