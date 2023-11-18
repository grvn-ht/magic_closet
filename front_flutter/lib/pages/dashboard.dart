//import 'package:flutter_application_1/old_project/graph.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_1/cookies/app_cookies.dart';
import 'package:flutter_application_1/cookies/web_cookies.dart';
import 'package:flutter_application_1/cookies/service.dart';
import 'package:flutter_application_1/providers/auth_provider.dart';
import 'package:flutter_application_1/graphs/chart_container.dart';
import 'package:flutter_application_1/graphs/line_chart.dart';
import 'package:flutter_application_1/graphs/time_serie.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_application_1/providers/time_series_type.dart';
import 'dart:async';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late Timer _timer;
  late CookieService cookieService;
  final HttpService httpService = HttpService();
  List<TimeSeriesTypeT> temperatureData = [];
  List<TimeSeriesTypeH> moistureData = [];
  List<TimeSeriesTypeP> phData = [];
  List<TimeSeriesTypeE> ecData = [];
  String imageData = '';

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      cookieService = WebCookieService();
    } else {
      cookieService = AppCookieService();
    }
    fetchTemperatureData();
    fetchMoistureData();
    fetchPhData();
    fetchEcData();
    //fetchImageData();
    //_timer = Timer.periodic(const Duration(hours: 1), (timer) {
    //  fetchImageData();
    //});
  }

  @override
  void dispose() {
    _timer
        .cancel(); // Cancel the timer to prevent memory leaks when the widget is disposed
    super.dispose();
  }

  Future<void> fetchTemperatureData() async {
    try {
      List<TimeSeriesTypeT> data = await httpService.getTemperatureData();
      setState(() {
        temperatureData = data;
      });
    } catch (e) {
      print('Error fetching temperature data: $e');
    }
  }

  Future<void> fetchMoistureData() async {
    try {
      List<TimeSeriesTypeH> data = await httpService.getMoistureData();
      setState(() {
        moistureData = data;
      });
    } catch (e) {
      print('Error fetching moisture data: $e');
    }
  }

  Future<void> fetchPhData() async {
    try {
      List<TimeSeriesTypeP> data = await httpService.getPhData();
      setState(() {
        phData = data;
      });
    } catch (e) {
      print('Error fetching ph data: $e');
    }
  }

  Future<void> fetchEcData() async {
    try {
      List<TimeSeriesTypeE> data = await httpService.getEcData();
      setState(() {
        ecData = data;
      });
    } catch (e) {
      print('Error fetching ec data: $e');
    }
  }

  /*
  Future<void> fetchImageData() async {
    try {
      final data = await httpService.getImageData();
      setState(() {
        imageData = data;
      });
    } catch (e) {
      print('Error fetching image data: $e');
    }
  }
  */
  @override
  Widget build(BuildContext context) {
    double? latestTemperatureValue;
    double? latestMoistureValue;
    double? latestPhValue;
    double? latestEcValue;

    if (temperatureData != null && temperatureData.isNotEmpty) {
      // Sort the data to get the latest EC value
      temperatureData.sort((a, b) => b.time.compareTo(a.time));
      latestTemperatureValue = temperatureData.first.temperature;
    }
    if (moistureData != null && moistureData.isNotEmpty) {
      // Sort the data to get the latest EC value
      moistureData.sort((a, b) => b.time.compareTo(a.time));
      latestMoistureValue = moistureData.first.moisture;
    }
    if (phData != null && phData.isNotEmpty) {
      // Sort the data to get the latest EC value
      phData.sort((a, b) => b.time.compareTo(a.time));
      latestPhValue = phData.first.ph;
    }
    if (ecData != null && ecData.isNotEmpty) {
      // Sort the data to get the latest EC value
      ecData.sort((a, b) => b.time.compareTo(a.time));
      latestEcValue = ecData.first.ec;
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Dashboard"),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await httpService.logout(context);
              },
            ),
          ],
        ),
        body: CustomScrollView(
          slivers: <Widget>[
            // SliverAppBar and other headers go here if needed

            SliverToBoxAdapter(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0), // Add padding here
                      child: Container(
                        height: 100.0,
                        color: Colors.red,
                        //child: const Text("humidity"),
                        child: Text(
                          latestTemperatureValue != null
                              ? 'Temp:\n ${latestTemperatureValue.toString()}'
                              : 'Temp: \n No data', //latestTemperatureValue.toString() : 'No data', // Show 'No data' if there's no EC value
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0), // Add padding here
                      child: Container(
                        height: 100.0,
                        color: Colors.red,
                        child: Text(
                          latestMoistureValue != null
                              ? 'Hum:\n ${latestMoistureValue.toString()}'
                              : 'Hum: \n No data', //latestMoistureValue.toString() : 'No data', // Show 'No data' if there's no EC value
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0), // Add padding here
                      child: Container(
                        height: 100.0,
                        color: Colors.red,
                        child: Text(
                          latestEcValue != null
                              ? 'Ec:\n ${latestEcValue.toString()}'
                              : 'Ec: \n No data', //latestPhValue.toString() : 'No data', // Show 'No data' if there's no EC value
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0), // Add padding here
                      child: Container(
                        height: 100.0,
                        color: Colors.red,
                        child: Text(
                          latestPhValue != null
                              ? 'Ph:\n ${latestPhValue.toString()}'
                              : 'Ph: \n No data', //latestEcValue.toString() : 'No data', // Show 'No data' if there's no EC value
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0), // Add padding here
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.teal[100],
                        child: Padding(
                          padding:
                              const EdgeInsets.all(16.0), // Add padding here
                          child: SimpleTimeSeriesChart(
                            _createSampleDataT(temperatureData),
                            animate: false,
                          ),
                        ),
                      ),
                    );
                  } else if (index == 1) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0), // Add padding here
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.teal[100],
                        child: Padding(
                          padding:
                              const EdgeInsets.all(16.0), // Add padding here
                          child: SimpleTimeSeriesChart(
                            _createSampleDataH(moistureData),
                          ),
                        ),
                      ),
                    );
                  } else if (index == 2) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0), // Add padding here
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.teal[100],
                        child: Padding(
                          padding:
                              const EdgeInsets.all(16.0), // Add padding here
                          child: SimpleTimeSeriesChart(
                            _createSampleDataP(phData),
                          ),
                        ),
                      ),
                    );
                  } else if (index == 3) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0), // Add padding here
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.teal[100],
                        child: Padding(
                          padding:
                              const EdgeInsets.all(16.0), // Add padding here
                          child: SimpleTimeSeriesChart(
                            _createSampleDataE(ecData),
                          ),
                        ),
                      ),
                    );
                  }
                },
                childCount: 4, // Change this to the number of scrolling items
              ),
            ),

            SliverToBoxAdapter(
              child: Row(children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0), // Add padding here
                    child: AspectRatio(
                      aspectRatio: 1.0, // Adjust this value
                      child: Container(
                        height: 500.0,
                        color: Colors.yellow,
                        //child: const Text("photo"),
                        child: Image.network(
                          'https://www.terjack.space/image', // Provide the URL of the image
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0), // Add padding here
                    child: AspectRatio(
                      aspectRatio: 1.0, // Adjust this value
                      child: Container(
                        height: 500.0,
                        color: Colors.yellow,
                        child: const Text("timelaps"),
                      ),
                    ),
                  ),
                ),
              ]),
            ),

            // Add more SliverGrids or SliverToBoxAdapters as needed
          ],
        )

        //SimpleTimeSeriesChart(_createSampleData(temperatureData)),
        );
  }

  List<charts.Series<TimeSeriesTypeT, DateTime>> _createSampleDataT(
      sensorData) {
    return [
      charts.Series<TimeSeriesTypeT, DateTime>(
        id: 'temperature',
        domainFn: (TimeSeriesTypeT type, _) => type.time,
        measureFn: (TimeSeriesTypeT type, _) => type.temperature,
        data: sensorData,
      )
    ];
  }

  List<charts.Series<TimeSeriesTypeH, DateTime>> _createSampleDataH(
      sensorData) {
    return [
      charts.Series<TimeSeriesTypeH, DateTime>(
        id: 'moisture',
        domainFn: (TimeSeriesTypeH type, _) => type.time,
        measureFn: (TimeSeriesTypeH type, _) => type.moisture,
        data: sensorData,
      )
    ];
  }

  List<charts.Series<TimeSeriesTypeE, DateTime>> _createSampleDataE(
      sensorData) {
    return [
      charts.Series<TimeSeriesTypeE, DateTime>(
        id: 'ec',
        domainFn: (TimeSeriesTypeE type, _) => type.time,
        measureFn: (TimeSeriesTypeE type, _) => type.ec,
        data: sensorData,
      )
    ];
  }

  List<charts.Series<TimeSeriesTypeP, DateTime>> _createSampleDataP(
      sensorData) {
    return [
      charts.Series<TimeSeriesTypeP, DateTime>(
        id: 'ph',
        domainFn: (TimeSeriesTypeP type, _) => type.time,
        measureFn: (TimeSeriesTypeP type, _) => type.ph,
        data: sensorData,
      )
    ];
  }
}
