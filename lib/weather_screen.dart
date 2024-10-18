import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = 'Kalmunai';
      final res = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey'),
      );

      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw 'An Unexpected error occurred!';
      }

      return data;

      //data['list'][0]['main']['temp'];
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }

          final data = snapshot.data!;

          //main cart api elements
          final currentTemp = data['list'][0]['main']['temp'];
          final currentSky = data['list'][0]['weather'][0]['main'];

          final pressure = data['list'][0]['main']['pressure'];
          final windSpeed = data['list'][0]['wind']['speed'];
          final humidity = data['list'][0]['main']['humidity'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //MAIN CARD
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      //in order prevent border with edges
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        //to make a blur
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '$currentTemp K',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Icon(
                                currentSky == 'Clouds'
                                    ? Icons.cloud
                                    : currentSky == 'Clear'
                                        ? Icons.sunny
                                        : Icons.cloudy_snowing,
                                size: 64,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Text(
                                "$currentSky",
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                //----------//divider----------------------------------
                const SizedBox(
                  height: 20,
                ),

                //----------//WEATHER FORECAST-----------------------------
                const Text(
                  "Hourly Forecast",
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        //Data from API as Variables
                        final hourlyTimeAPI =
                            DateTime.parse(data['list'][index + 1]['dt_txt']);
                        final hourlyIconCloudsAPI = data['list'][index + 1]
                                ['weather'][0]['main'] ==
                            'Clouds';
                        final hourlyIconClearAPI = data['list'][index + 1]
                                ['weather'][0]['main'] ==
                            'Clear';
                        final hourlyTemp =
                            data['list'][index + 1]['main']['temp'];
                        //Widget to display
                        return HourlyForeCastItem(
                          time: DateFormat.j().format(hourlyTimeAPI),
                          icon: hourlyIconCloudsAPI
                              ? Icons.cloud
                              : hourlyIconClearAPI
                                  ? Icons.sunny
                                  : Icons.cloudy_snowing,
                          temperature: hourlyTemp.toString(),
                        );
                      }),
                ),
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     children: [
                //       for (int i = 0; i < 5; i++)
                //         HourlyForeCastItem(
                //           time: data['list'][i + 1]['dt'].toString(),
                //           icon: data['list'][i + 1]['weather'][0]['main'] ==
                //                   'Clouds'
                //               ? Icons.cloud
                //               : data['list'][i + 1]['weather'][0]['main'] ==
                //                       'Clear'
                //                   ? Icons.sunny
                //                   : Icons.cloudy_snowing,
                //           temperature:
                //               data['list'][i + 1]['main']['temp'].toString(),
                //         ),
                //     ],
                //   ),
                // ),

                //----------//divider-----------------------------
                const SizedBox(
                  height: 20,
                ),

                //----------// ADDITIONAL INFORMATION-----------------------------
                const Text(
                  "Additional Information",
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AdditionalInfoItem(
                      icon: Icons.water_drop,
                      label: "Humidity",
                      value: humidity.toString(),
                    ),
                    AdditionalInfoItem(
                      icon: Icons.air,
                      label: "Wind Speed",
                      value: windSpeed.toString(),
                    ),
                    AdditionalInfoItem(
                      icon: Icons.heat_pump,
                      label: "Pressure",
                      value: pressure.toString(),
                    ),
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
