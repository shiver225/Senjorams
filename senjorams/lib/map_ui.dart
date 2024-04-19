import 'dart:convert';
import 'dart:developer';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:senjorams/utilities/place.dart';

const apiKey="AIzaSyD3HD7vNTtRChKOhf3J6SN0niAiT_apYSk"; //not safe i bet
extension  HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => _MapSampleState();
}

class _MapSampleState extends State<MapSample> {
  late GoogleMapController mapController;
  LatLng? _currentPosition;
  GlobalKey _globalKey = GlobalKey();
  @override
    void initState() {
      super.initState();
      _getLocation();
    }

  Future<Place> fetchPoi(LatLng position) async{
    print('https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${position.latitude}%2C${position.longitude}&radius=200&key=$apiKey');

    Map data = {
    "maxResultCount": 1,
    "locationRestriction": {
      "circle": {
        "center": {
          "latitude": position.latitude,
          "longitude": position.longitude},
        "radius": 10.0
      }
    }
    };
    http.Response response =  await http.post(Uri.parse('https://places.googleapis.com/v1/places:searchNearby'),
      headers: {
        "Content-Type": "application/json",
       "X-Goog-Api-Key": apiKey,
       "X-Goog-FieldMask": "places.displayName,places.iconBackgroundColor,places.formattedAddress,places.reviews,places.regularOpeningHours,places.rating,places.photos,places.userRatingCount,places.iconMaskBaseUri"
       },
      body: json.encode(data),
    );
    Map values = jsonDecode(response.body);
    log(response.body);
    return Place.fromJson(values["places"][0]);//replace with class
  }
  _getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    double lat = position.latitude;
    double long = position.longitude;

    LatLng location = LatLng(lat, long);

    setState(() {
      _currentPosition = location;
      _globalKey=GlobalKey();
    });
  }
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  final CarouselController _controller = CarouselController();
  int _current = 0;
  Widget _imageCarouselWithInticator(Place place, StateSetter setModalState){
    final List<Widget> imageSliders = place.photos!.map((item) => Container(
      child: Container(
        margin: EdgeInsets.all(5.0),
        child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            child: Stack(
              children: <Widget>[
                Image.network('https://places.googleapis.com/v1/${item.name}/media?maxHeightPx=400&maxWidthPx=400&key=$apiKey',fit: BoxFit.cover, height: 400,), //cheap fix by setting height to 400
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(200, 0, 0, 0),
                          Color.fromARGB(0, 0, 0, 0)
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 20.0),
                  ),
                ),
              ],
            )),
      ),
    )).toList();
    return SizedBox(
          height: 300,
          child: Column(
            children: [
            Expanded(
              child: CarouselSlider(
                items: imageSliders,
                carouselController: _controller,
                options: CarouselOptions(
                    autoPlay: true,
                    enlargeCenterPage: true,
                    onPageChanged: (index, reason) {
                      setModalState(() {
                        _current = index;
                      });
                    }),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: place.photos!.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _controller.animateToPage(entry.key),
                  child: Container(
                    width: 12.0,
                    height: 12.0,
                    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black)
                            .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                  ),
                );
              }).toList(),
            ),
          ]),
        );
  }
  void _modalScrollPicker({required BuildContext context, required Place place}){
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled:true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState){
          return FractionallySizedBox(
          heightFactor: 0.75,
          child: Center(
            child: Column(
              children: <Widget>[   
                SizedBox(height: 20),
                Row(
                  children: [
                  SizedBox(width: 10),
                  Image.network(
                    place.iconMaskBaseUri! + ".png",
                    color: HexColor.fromHex(place.iconBackgroundColor!),
                    scale: 5,
                    ),
                  SizedBox(width: 10),
                  Flexible(
                     child: Text(
                    place.displayName!.text,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  )
                ],),
                SizedBox(height: 20),
                Row(
                  children: [
                    SizedBox(width: 10),
                    RatingBarIndicator(
                      rating: place.rating ?? 1,
                      direction: Axis.horizontal,
                      itemCount: 5,
                      itemSize: 30.0,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      place.rating != null ? place.rating.toString() : "No reviews",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                ],
                ),
                SizedBox(height: 20),
                Text(
                  place.formattedAddress!  + " " 
                ),
                SizedBox(height: 20),
                Text(
                  (place.regularOpeningHours != null ? (place.regularOpeningHours!.openNow ? "Open" : "Closed") : "")
                ),
                if(place.photos!=null) _imageCarouselWithInticator(place, setModalState),
              ],
            ),
          ),
        );
        });
        });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Maps Sample App'),
          elevation: 2,
        ),
        body: GoogleMap(
          key: _globalKey,
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _currentPosition ?? LatLng(0, 0),
            zoom: 15.0,
          ),
          onTap: (argument) async {
            Place poi = await fetchPoi(argument);
            _modalScrollPicker(context: context, place: poi);
          },
        ),
    );
  }
}