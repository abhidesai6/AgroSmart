import 'dart:convert';
import 'package:agri/model/HttpException.dart';
import 'package:agri/model/weatherConvert.dart';
import 'package:agri/model/weatherModel.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class CurrentWeather extends StatefulWidget {
  static const String id = 'current_weather';
  @override
  _CurrentWeatherState createState() => _CurrentWeatherState();
}

class _CurrentWeatherState extends State<CurrentWeather> {
  List<Weather> weathers = List<Weather>();
  int day, day1, day2, day3, day4, day5;
  Weather weather;
  String date;
  var cityname;
  var locationMessage = "";
  var apiKey = '5ad105a2ca3f7716284999d27d1b04e5';
  double lat, lon;
  int days = 7;
  String capitalize(String a) {
    print("${a[0].toUpperCase()}${a.substring(1)}");
    return "${a[0].toUpperCase()}${a.substring(1)}";
  }

  void getCurrentLocation() async {
    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);

    var lastPosition = await Geolocator.getLastKnownPosition();
    print(lastPosition);

    setState(() {
      locationMessage =
          "$position.altitude ,$position.latitude , $position.longitude";
      lat = position.latitude;
      lon = position.longitude;
    });
    getData();
    weather = await getWeatherData();
    weathers = await getForecast();
    print(weather.cityName);
    cityname = weather.cityName;
    print(weathers[0].description);
    var date1 =
        DateTime.fromMillisecondsSinceEpoch(weather.time * 1000).toString();
    print(date1);
    var date2 = date1.split(" ");
    date = date2[0];
    date2 = date.split("-");
    day = int.parse(date2[2]);
    print(day);
    print(date2);
    day1 = day + 1;
    day2 = day + 2;
    day3 = day + 3;
    day4 = day + 4;
    day5 = day + 5;
    print(weathers.length);
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  void getData() async {
    var url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
    //var url = 'http://api.openweathermap.org/data/2.5/weather?lat=14.6102473&121.0043158&appid=secret';
    //var url = 'http://api.openweathermap.org/data/2.5/weather?lat=14.6102473&lon=121.0043158&appid=secret';
    //20.0252268081483, 73.76779917236001
    print(url);

    var request = await http.get(Uri.parse(url));
    // print(request.body.toString());
    if (request.statusCode == 200) {
      String data = request.body.toString();
      var city = jsonDecode(data)['name'];
      var description = jsonDecode(data)['weather'][0]['description'];
      // final weatherJson = json.decode(request.body);
      // Weather.fromJson(weatherJson);
      print('Welcome to $city city!');
      print('Weather: $description');
    } else {
      print(request.statusCode);
      print(
          'Latitude is: $lat *** Longitude is: $lon'); // this prints longitude and latitude values
      print(
          'request $url'); // when I entered the url in postman, I'm getting the same error 400
    }
  }

  Future<Weather> getWeatherData() async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
    print('fetching $url');
    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) {
      throw HTTPException(res.statusCode, "unable to fetch weather data");
    }
    final weatherJson = json.decode(res.body);
    // print(weatherJson) ;
    return Weather.fromJson(weatherJson);
  }

  Future<List<Weather>> getForecast() async {
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&cnt=$days&appid=$apiKey&units=metric';
    print('fetching $url');
    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) {
      throw HTTPException(res.statusCode, "unable to fetch weather data");
    }
    final forecastJson = json.decode(res.body);
    for (final item in forecastJson['list']) {
      weathers.add(Weather(
          time: item['main']['dt_txt'],
          description: item['weather'][0]['description'],
          temperature: intToDouble(
            item['main']['temp'],
          ),
          iconCode: item['weather'][0]['icon']));
    }
    return weathers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white70,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        height: MediaQuery.of(context).size.height * 0.3,
                        width: MediaQuery.of(context).size.width * 1,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(cityname,
                                style: new TextStyle(
                                    color: Colors.black,
                                    fontSize: 23.0,
                                    fontWeight: FontWeight.bold)),
                            Text(capitalize(weather.description),
                                style: new TextStyle(
                                    color: Colors.black, fontSize: 25.0)),
                            Text(weather.temperature.toString() + ' °C',
                                style: new TextStyle(color: Colors.black)),
                            Image.network(
                                'https://openweathermap.org/img/w/${weather.iconCode}.png'),
                            Text(date,
                                style: new TextStyle(color: Colors.black)),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: new Icon(Icons.refresh),
                tooltip: 'Refresh',
                onPressed: () => getCurrentLocation(),
                color: Colors.black,
              ),
            ),
            SafeArea(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 200.0,
                child: new ListView(
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    // first
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            height: 200,
                            width: 120,
                            child: new Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(cityname,
                                    style: new TextStyle(
                                        color: Colors.black, fontSize: 17)),
                                Text(capitalize(weathers[1].description),
                                    style: new TextStyle(
                                        color: Colors.black,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold)),
                                Text(weathers[0].minTemperature.toString(),
                                    style: new TextStyle(color: Colors.black)),
                                Image.network(
                                    'https://openweathermap.org/img/w/${weathers[1].iconCode}.png'),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Apr ',
                                        style:
                                            new TextStyle(color: Colors.black)),
                                    Text(day1.toString(),
                                        style:
                                            new TextStyle(color: Colors.black)),
                                    Text(' 2021',
                                        style:
                                            new TextStyle(color: Colors.black)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )),
                    //second
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            height: 200,
                            width: 120,
                            child: new Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(cityname,
                                    style: new TextStyle(
                                        color: Colors.black, fontSize: 17)),
                                Text(capitalize(weathers[2].description),
                                    style: new TextStyle(
                                        color: Colors.black,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold)),
                                Text(weathers[0].temperature.toString(),
                                    style: new TextStyle(color: Colors.black)),
                                Image.network(
                                    'https://openweathermap.org/img/w/${weathers[2].iconCode}.png'),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Apr ',
                                        style:
                                            new TextStyle(color: Colors.black)),
                                    Text(day2.toString(),
                                        style:
                                            new TextStyle(color: Colors.black)),
                                    Text(' 2021',
                                        style:
                                            new TextStyle(color: Colors.black)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )),

                    //third
                    //third
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            height: 200,
                            width: 120,
                            child: new Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(cityname,
                                    style: new TextStyle(
                                        color: Colors.black, fontSize: 17)),
                                Text(capitalize(weathers[3].description),
                                    style: new TextStyle(
                                        color: Colors.black,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold)),
                                Text(weathers[0].temperature.toString(),
                                    style: new TextStyle(color: Colors.black)),
                                Image.network(
                                    'https://openweathermap.org/img/w/${weathers[3].iconCode}.png'),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Apr ',
                                        style:
                                            new TextStyle(color: Colors.black)),
                                    Text(day3.toString(),
                                        style:
                                            new TextStyle(color: Colors.black)),
                                    Text(' 2021',
                                        style:
                                            new TextStyle(color: Colors.black)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )),
                    //fourth
                    //fourth
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            height: 200,
                            width: 120,
                            child: new Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(cityname,
                                    style: new TextStyle(
                                        color: Colors.black, fontSize: 17)),
                                Text(capitalize(weathers[4].description),
                                    style: new TextStyle(
                                        color: Colors.black,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold)),
                                Text(weathers[0].temperature.toString(),
                                    style: new TextStyle(color: Colors.black)),
                                Image.network(
                                    'https://openweathermap.org/img/w/${weathers[4].iconCode}.png'),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Apr ',
                                        style:
                                            new TextStyle(color: Colors.black)),
                                    Text(day4.toString(),
                                        style:
                                            new TextStyle(color: Colors.black)),
                                    Text(' 2021',
                                        style:
                                            new TextStyle(color: Colors.black)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )),
                    //fifth
                    //
                    //fifth
                    //
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            height: 200,
                            width: 120,
                            child: new Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(cityname,
                                    style: new TextStyle(
                                        color: Colors.black, fontSize: 17)),
                                Text(capitalize(weathers[5].description),
                                    style: new TextStyle(
                                        color: Colors.black,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold)),
                                Text(weathers[0].temperature.toString(),
                                    style: new TextStyle(color: Colors.black)),
                                Image.network(
                                    'https://openweathermap.org/img/w/${weathers[5].iconCode}.png'),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Apr ',
                                        style:
                                            new TextStyle(color: Colors.black)),
                                    Text(day5.toString(),
                                        style:
                                            new TextStyle(color: Colors.black)),
                                    Text(' 2021',
                                        style:
                                            new TextStyle(color: Colors.black)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }
}
