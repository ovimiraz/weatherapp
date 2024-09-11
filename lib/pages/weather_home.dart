import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:weatherapp_2/pages/settings_page.dart';
import 'package:weatherapp_2/providers/weather_provider.dart';
import 'package:weatherapp_2/utils/constants.dart';
import 'package:weatherapp_2/utils/helper_functions.dart';

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key});

  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  @override
  void didChangeDependencies() {
    Provider.of<WeatherProvider>(context, listen: false).getData();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                final result = await showSearch(
                    context: context,
                    delegate: _CitySearchDelegate()) as String;
                if (result.isNotEmpty) {
                  EasyLoading.show(status: 'Please wait');
                  final status =
                      await Provider.of<WeatherProvider>(context, listen: false)
                          .convertCityToLtlng(result);
                  EasyLoading.dismiss();
                }
              },
              icon: const Icon(Icons.search)),
          IconButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsPage())),
              icon: const Icon(Icons.settings))
        ],
        title: Text('Home'),
        backgroundColor: Colors.blue.shade200,
        centerTitle: true,
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, child) {
          return provider.hasDataLoaded
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _currentweathersections(provider),
                      _foreCastWeatherSections(provider, context),
                    ],
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(),
                );
        },
      ),
    );
  }

  Widget _currentweathersections(WeatherProvider provider) {
    return Column(
      children: [
        SizedBox(height: 20,),
        Text(
          getFormattedDateTime(provider.currentWeather!.dt!),
          style:
          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),

        ),
        Text(
          '${provider.currentWeather!.name},${provider.currentWeather!.sys!.country}',
          style: TextStyle(fontSize: 30, ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
                '$iconUrlPrefix${provider.currentWeather!.weather![0].icon}$iconUrlSufix'),
            Text(
              '${provider.currentWeather!.main!.temp!.toStringAsFixed(0)}$degree${provider.unitSimbol}',
              style: TextStyle(fontSize: 70),
            ),
          ],
        ),
        Text(
            'Feels like : ${provider.currentWeather!.main!.feelsLike!.toStringAsFixed(0)}$degree$celsius',
            style: TextStyle(fontSize: 30)),
        SizedBox(
          height: 70,
        ),
        Text(
          '${provider.currentWeather!.weather![0].description}',
          style: TextStyle(fontSize: 20),
        ),
      ],
    );
  }

  Widget _foreCastWeatherSections(
      WeatherProvider provider, BuildContext context) {
    final forecastitemlist = provider.forecastWeather!.list!;
    return SizedBox(
      height: 200,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: forecastitemlist.length,
        itemBuilder: (context, index) {
          final item = forecastitemlist[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                children: [
                  Text(getFormattedDateTime(item.dt!, pattern: 'EEE HH:mm')),
                  Image.network(
                      '$iconUrlPrefix${item.weather![0].icon}$iconUrlSufix'),
                  Text(
                      ('${item.main!.tempMax!.toStringAsFixed(0)}/${item.main!.tempMin!.toStringAsFixed(0)}$degree${provider.unitSimbol}')),
                  Text(item.weather![0].description!)
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CitySearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, query);
        },
        icon: Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListTile(
      onTap: () {
        close(context, query);
      },
      title: Text(query),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredList = query.isEmpty
        ? city
        : city
            .where((city) => city.toLowerCase().startsWith(query.toLowerCase()))
            .toList();

    return ListView.builder(
        itemCount: filteredList.length,
        itemBuilder: (context, index) => ListTile(
              onTap: () {
                query = filteredList[index];
                close(context, query);
              },
              title: Text(filteredList[index]),
            ));
  }
}
