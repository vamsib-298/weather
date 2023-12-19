import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather/screens/detail_screen.dart';

class Weather {
  final String city;
  final String description;
  final double temperature;
  final String weatherIcon;

  Weather({
    required this.city,
    required this.description,
    required this.temperature,
    required this.weatherIcon,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Weather> _citiesWeather;
  final TextEditingController _cityController = TextEditingController();
  late List<Weather> _filteredCities;

  @override
  void initState() {
    super.initState();
    _citiesWeather = [];
    _filteredCities = List.from(_citiesWeather);
    // Fetch weather for random cities only if the list is empty
    if (_citiesWeather.isEmpty) {
      _getRandomCitiesWeather();
    }
  }

  Future<void> _getRandomCitiesWeather() async {
    final List<String> randomCities = [
      'Mumbai',
      'Delhi',
      'Bangalore',
      'Hyderabad',
      'Chennai',
      'Kolkata',
      'Ahmedabad',
      'Pune',
      'Jaipur',
      'Lucknow',
    ];

    for (var cityName in randomCities) {
      await _getCurrentWeatherByCity(cityName);
    }
  }

  Future<void> _getCurrentWeatherByCity(String cityName) async {
    try {
      const apiKey = '63618d6a98582d2f7d459f5e7d26842f';
      final apiUrl =
          'https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=$apiKey';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final weather = Weather(
          city: data['name'],
          description: data['weather'][0]['description'],
          temperature: (data['main']['temp'] - 273.15),
          weatherIcon: data['weather'][0]['icon'],
        );

        if (!_citiesWeather.any((w) => w.city == weather.city)) {
          setState(() {
            _citiesWeather.add(weather);
            _filteredCities = List.from(_citiesWeather);
          });
        }

        // Navigate to CityWeatherDetail screen
        _navigateToCityWeatherDetail(weather);
      } else {
        throw Exception('Failed to load weather data for $cityName');
      }
    } catch (e) {
      // Handle errors, e.g., no internet connection
      print('Error fetching weather data: $e');
    }
  }

  void _navigateToCityWeatherDetail(Weather weather) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CityWeatherDetail(weather: weather),
      ),
    );
  }

  Widget _buildCityBox(Weather weather) {
    return GestureDetector(
      onTap: () {
        _navigateToCityWeatherDetail(weather);
      },
      child: SizedBox(
        width: 200,
        height: 100,
        child: Card(
          margin: const EdgeInsets.all(5.0),
          child: ListTile(
            leading: const Icon(Icons.location_city),
            title: Text(weather.city),
            trailing: Text('${weather.temperature.toStringAsFixed(1)}°C'),
          ),
        ),
      ),
    );
  }

  void _filterCities(String keyword) {
    setState(() {
      _filteredCities = _citiesWeather
          .where((city) =>
              city.city.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search bar at the top with padding
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 33.0, 8.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 155, 213, 184),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.search,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _cityController,
                      onChanged: (value) {
                        _filterCities(value);
                      },
                      decoration: const InputDecoration(
                        hintText: 'Enter city name',
                        hintStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // List of fixed-size boxes displaying different cities with current weather data
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCities.length,
              itemBuilder: (context, index) {
                return _buildCityBox(_filteredCities[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
