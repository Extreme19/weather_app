import 'package:flutter/material.dart';
//import http as http to enable api queries
import 'package:http/http.dart' as http;
//import dart's convert package for json conversion
import 'dart:convert';

void main(){
  runApp(WeatherApp());
}

class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  int temperature;
  String location = "London";
  int woeid = 44418;
  String weather = "clear";
  String abbreviation = '';
  String error ='';
  

  
//the full api url to be hit
  String searchApiUrl ='https://www.metaweather.com/api//location/search/?query=';
  //location api url
  String locationApiUrl = 'https://www.metaweather.com/api//location/';

  @override
  void initState() {

    super.initState();
    fetchLocation();
    
  }

  //api response async function
  void fetchSearch(String input) async{
    try {
      
    
    //api response variable
    var searchResult = await http.get(searchApiUrl + input);
    //decoding the json object received as response into a readable result
    var result = json.decode(searchResult.body)[0];
    setState(() {
      location = result['title'];
      woeid = result['woeid'];
      error = '';
    });
    }
    catch (e) {
      setState(() {
        error = 'Sorry, data not available';
      });
    }

  }

  //location function
  void fetchLocation()async{
    var locationResult = await http.get(locationApiUrl + woeid.toString());
    var result = json.decode(locationResult.body);
    var consolidatedWeather = result["consolidated_weather"];
    var data = consolidatedWeather[0];
    
    setState(() {
      temperature = data["the_temp"].round();
      weather = data["weather_state_name"].replaceAll(' ','').toLowerCase();
      abbreviation = data["weather_state_abbr"];
    });
  }

  //function to handle search query
  void onTextFieldSubmitted(String input)async{
    await fetchSearch(input);
    await fetchLocation();
  }



 @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
        decoration: BoxDecoration(
        image: DecorationImage(
        image: AssetImage('images/$weather.png'),
        fit: BoxFit.cover,
        )
        ),
        child:temperature == null ? Center(child: CircularProgressIndicator()) : Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
            Column(
              children: [
                Center(
                  child: Image.network(
                    'https://www.metaweather.com/static/img/weather/png/'+ '$abbreviation' +'.png',
                    width: 100,
                  )
                ),
                Center(
              child: Text(
                temperature.toString() + 'C', 
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 60
                ),
              ),
            ),
              Center(
                child: Text(
                  location, 
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 60
                  ),
                ),
              )

              ],
              
            ),
            Column(
                children: [
                  Container(
                    width: 300,
                    child: TextField(
                      onSubmitted: (String input){
                        onTextFieldSubmitted(input);
                      },
                      style: TextStyle(color: Colors.white, fontSize: 25,),
                      decoration: InputDecoration(
                        hintText: "Search another location",
                        hintStyle: TextStyle(color: Colors.white, fontSize: 20)
                        ,prefixIcon:  Icon(Icons.search, color: Colors.white, )
                      ),
                      ),
                  ),
                  Text(error, textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red, fontSize: 20))
                ]
              ),
            
          ],
          )
        )
      ),
    );
  }
}