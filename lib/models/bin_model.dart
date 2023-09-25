class Bin {
  String name;
  num volume;
  num? latitude;
  num? longitude;
  int? timestamp;
  num? maxCapacity;

  Bin(
      {required this.name,
      required this.volume,
      this.latitude,
      this.longitude,
      this.timestamp,
      this.maxCapacity});

  @override
  String toString() {
    return '{ ${this.name}, ${this.volume} }';
  }
}
