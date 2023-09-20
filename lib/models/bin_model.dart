class Bin {
  String name;
  num volume;
  num? latitude;
  num? longitude;

  Bin(
      {required this.name,
      required this.volume,
      this.latitude,
      this.longitude});

  @override
  String toString() {
    return '{ ${this.name}, ${this.volume} }';
  }
}
