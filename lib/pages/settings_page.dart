import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherapp_2/providers/weather_provider.dart';
import 'package:weatherapp_2/utils/helper_functions.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool status =  false;
  @override
  void initState() {
   getTempUnitStatus().then((value) {
     setState(() {
       status = value;
     });
   });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setting'),
        backgroundColor: Colors.blue.shade200,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Show temperature in fahrenheit'),
            subtitle: Text('Defult is celsius'),
            value: status,
            onChanged: (value) async{
             setState(() {
               status= value;
             });
             await setTempUnitStatus(status);
             Provider.of<WeatherProvider>(context, listen: false).getData();
            },
          )
        ],
      ),
    );
  }


}
