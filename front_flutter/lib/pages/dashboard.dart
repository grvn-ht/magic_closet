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

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late CookieService cookieService;
  final HttpService httpService = HttpService();
  List<TimeSeriesType> temperatureData = [];

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      cookieService = WebCookieService();
    } else {
      cookieService = AppCookieService();
    }
    fetchTemperatureData();
  }

  Future<void> fetchTemperatureData() async {
    try {
      List<TimeSeriesType> data = await httpService.getTemperatureData();
      setState(() {
        temperatureData = data;
      });
    } catch (e) {
      print('Error fetching temperature data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        child: const Text("humidity"),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0), // Add padding here
                      child: Container(
                        height: 100.0,
                        color: Colors.red,
                        child: const Text("humidity"),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0), // Add padding here
                      child: Container(
                        height: 100.0,
                        color: Colors.red,
                        child: const Text("humidity"),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0), // Add padding here
                      child: Container(
                        height: 100.0,
                        color: Colors.red,
                        child: const Text("humidity"),
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
                            _createSampleData(temperatureData),
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
                            _createSampleData(temperatureData),
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
                            _createSampleData(temperatureData),
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
                            _createSampleData(temperatureData),
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
                        child: const Text("photo"),
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

  List<charts.Series<TimeSeriesType, DateTime>> _createSampleData(sensorData) {
    return [
      charts.Series<TimeSeriesType, DateTime>(
        id: 'sensor_data',
        domainFn: (TimeSeriesType type, _) => type.time,
        measureFn: (TimeSeriesType type, _) => type.sensor_data,
        data: sensorData,
      )
    ];
  }
}
