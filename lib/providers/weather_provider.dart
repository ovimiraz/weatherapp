import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:weatherapp_2/models/current_weather.dart';
import 'package:weatherapp_2/models/forecast_weather.dart';
import 'package:weatherapp_2/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:weatherapp_2/utils/helper_functions.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
enum LocationConversionStatus {
  success, failed,
}

class WeatherProvider extends ChangeNotifier{

  CurrentWeather? currentWeather;
  ForecastWeather? forecastWeather;
  String unit = metric;
  double latitude = 23.8041, longitude = 90.4125;
  String unitSimbol = celsius;
  final String baseurl = 'https://api.openweathermap.org/data/2.5/';
  bool get  hasDataLoaded => currentWeather!= null && forecastWeather!= null;
  bool shouldGetLocationFromCityName = false;

  Future<void> getData() async{
   if(!shouldGetLocationFromCityName){
     final position = await determinePosition();
     latitude = position.latitude;
     longitude = position.longitude;
   }

    await _getCurrentData();
    await _getForeCastData();
  }



  Future<void> getTempUnitFromPref ()async{
  final status = await getTempUnitStatus();
  unit = status? imperial: metric;
  unitSimbol = status? fahrenheit: celsius;

  }

  Future<void>_getCurrentData() async {
    await getTempUnitFromPref();
    final endurl = 'weather?lat=$latitude&lon=$longitude&appid=$weatherApiKey&units=$unit';
    final url = Uri.parse('$baseurl$endurl');
    try {
      final response = await http.get(url);
      final json = jsonDecode(response.body) ;
      if(response.statusCode == 200){
        currentWeather = CurrentWeather.fromJson(json);
        notifyListeners();
      }else{
       print(json['massges']);
      }
    }catch (error){
      print(error.toString());
    }
}


  Future<void>_getForeCastData() async {
    await getTempUnitFromPref();
    final endurl = 'forecast?lat=$latitude&lon=$longitude&appid=$weatherApiKey&units=$unit';
    final url = Uri.parse('$baseurl$endurl');
    try {
      final response = await http.get(url);
      final json = jsonDecode(response.body) ;
      if(response.statusCode == 200){
        forecastWeather = ForecastWeather.fromJson(json);
        notifyListeners();
      }else{
        print(json['massges']);
      }
    }catch (error){
      print(error.toString());
    }
  }

  Future<void> convertCityToLtlng(String city) async {
    try{
      final locationlist =await geo.locationFromAddress(city);
      if(locationlist.isNotEmpty){
        final location = locationlist.first;
        latitude = location.latitude;
        longitude = location.longitude;
        shouldGetLocationFromCityName = true;
        getData();
      }
    }catch(error){
      print(error.toString());
    }

  }


  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

}