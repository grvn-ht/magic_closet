import 'dart:typed_data';

class TimeSeriesTypeT {
  final DateTime time;
  final double temperature;

  TimeSeriesTypeT(this.time, this.temperature);
}

class TimeSeriesTypeH {
  final DateTime time;
  final double moisture;

  TimeSeriesTypeH(this.time, this.moisture);
}

class TimeSeriesTypeE {
  final DateTime time;
  final double ec;

  TimeSeriesTypeE(this.time, this.ec);
}

class TimeSeriesTypeP {
  final DateTime time;
  final double ph;

  TimeSeriesTypeP(this.time, this.ph);
}
