import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:senjorams/main.dart';
import 'package:senjorams/models/place_model.dart';

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
  final Completer<GoogleMapController> _mapController = Completer();
  GlobalKey _globalKey = GlobalKey();

  List<Place> _places = [];
  List<Place> _placesTrashCan = [];

  LocationData? _currentLocation; 
  Marker poiMarker = Marker(markerId: const MarkerId("currentLocation"), alpha: 0);

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    _loadData();
  }
  @override
  void setState(fn){
    if(mounted) {
      super.setState(fn);
    }
  }
  void _loadData() {
    final String? saved = prefs?.getString('savedPlaces');
    print(saved);
    if(saved != null){
      final List<dynamic> decoded = json.decode(saved);
      _places = decoded.map((place) => Place.fromJson(Map<String, dynamic>.from(place))).toList();
    }
  }
  //could just use the returned json from api call instead
  Future<void> _saveData() async {
    final String placeL = json.encode(_places);
    await prefs?.setString('savedPlaces', placeL);
  }
  
  Future<Place?> fetchPoi(LatLng position) async{
    Map data = {
    "maxResultCount": 1,
    "locationRestriction": {
      "circle": {
        "center": {
          "latitude": position.latitude,
          "longitude": position.longitude},
        "radius": 50.0
      }
    },
    "rankPreference": "DISTANCE"
    };
    http.Response response =  await http.post(Uri.parse('https://places.googleapis.com/v1/places:searchNearby'),
      headers: {
        "Content-Type": "application/json",
        "X-Goog-Api-Key": apiKey,
        "X-Goog-FieldMask": "places.location,places.id,places.displayName,places.iconBackgroundColor,places.formattedAddress,places.reviews,places.regularOpeningHours,places.rating,places.photos,places.userRatingCount,places.iconMaskBaseUri"
       },
      body: json.encode(data),
    );
    Map values = jsonDecode(response.body);
    log(response.body);
    try{
      return Place.fromJson(values["places"][0]);
    }
    catch(e){
      log(e.toString());
      return null;
    }
  }
  
  void getCurrentLocation() async{
    Location location = Location();

    location.getLocation().then((location){
      setState((){
        _currentLocation=location;
      });
    });


    location.onLocationChanged.listen((newLocation) {
      setState(() {
        _currentLocation=newLocation;
      });
     });
  }
  void _moveCameraToPosition(LatLng position) async{
    GoogleMapController googleMapController = await _mapController.future;
    googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 15.0,
              target: position
            )
          )
        );
  }

  final CarouselController _controller = CarouselController();
  int _current = 0;
  Widget _imageCarouselWithInticator(Place place, StateSetter setModalState){
    final List<Widget> imageSliders = place.photos!.map((item) => Container(
      margin: const EdgeInsets.all(5.0),
      child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          child: Stack(
            children: <Widget>[
              Image.network('https://places.googleapis.com/v1/${item.name}/media?maxHeightPx=400&maxWidthPx=400&key=$apiKey',fit: BoxFit.cover, height: 400,), //cheap fix by setting height to 400
              Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(200, 0, 0, 0),
                        Color.fromARGB(0, 0, 0, 0)
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20.0),
                ),
              ),
            ],
          )),
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
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
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
  void _modalBottomSheet({required BuildContext context, required Place place}){
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                      child: const Icon(Icons.clear),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.55),
                    TextButton(
                      child: const Icon(Icons.check),
                      onPressed: () async {
                        if(_places.any((pl) => pl.id == place.id)){
                          return;
                        }
                        setState(() {_places.add(place); _saveData();});
                      }
                    )]
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                  const SizedBox(width: 10),
                  Image.network(
                    "${place.iconMaskBaseUri!}.png",
                    color: HexColor.fromHex(place.iconBackgroundColor!),
                    scale: 5,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                     child: Text(
                    place.displayName!.text,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    ),
                  )],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const SizedBox(width: 10),
                    RatingBarIndicator(
                      rating: place.rating ?? 1,
                      direction: Axis.horizontal,
                      itemCount: 5,
                      itemSize: 30.0,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      place.rating != null ? place.rating.toString() : "No reviews",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                ],
                ),
                const SizedBox(height: 20),
                Text(
                  "${place.formattedAddress!} " 
                ),
                const SizedBox(height: 20),
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
  void _toggleSelection(Place place) {
    setState(() {
      if (place.isSelected) {
        place.cardColor=Colors.white;
        place.isSelected = false;
        _placesTrashCan.remove(place);
      } else {
        place.cardColor=const Color.fromARGB(255, 223, 222, 222);
        place.isSelected = true;
        _placesTrashCan.add(place);
      }
    });
  }
  Widget _placesCard(int index){
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: _places[index].cardColor,
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        children: <Widget>[
          InkWell(
            onTap: _placesTrashCan.isEmpty ? () {
                _moveCameraToPosition(_places[index].location!); 
                setState(() {
                    poiMarker = Marker(
                    markerId: poiMarker.markerId, 
                    alpha: 1,
                    position: _places[index].location!
                  );
                });
              } : () => _toggleSelection(_places[index]),
            onLongPress: () {_toggleSelection(_places[index]);Feedback.forTap(context);},
            borderRadius: BorderRadius.circular(14),
            child: ListTile(
              selected: _places[index].isSelected,
              title: Text(
                _places[index].displayName!.text
              ),
              trailing: _placesTrashCan.isNotEmpty ? Checkbox(
                value: _places[index].isSelected,
                onChanged: (bool? value) { 
                  Feedback.forTap(context);
                  _toggleSelection(_places[index]);            
                },
              ) : null,
              ),
            )
          ],
        ),
      );
  }
  Widget _sideNavigationBar(){
    return Container(
      child: Drawer(
        child: Container(
          color: Colors.white,
          child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
              Expanded(
                child: ListView.builder(
                  itemCount: _places.length,
                  itemBuilder: (context, index){
                    return _placesCard(index);
                  },
                ),
              ),
          ],
        ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        endDrawer: _sideNavigationBar(),
        appBar: AppBar(
          title: const Text('Maps Sample App'),
          elevation: 2,
        ),
        body: _currentLocation==null ? const Center(child: Text("Loading"),) : GoogleMap(
          key: _globalKey,
          myLocationEnabled: true,
          zoomControlsEnabled: false,
          initialCameraPosition: CameraPosition(
            target: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
            zoom: 15.0,
          ),
          markers: {
            poiMarker
          },
          onTap: (argument) async {
            Place? poi = await fetchPoi(argument);
            if(poi != null && context.mounted) {
              _modalBottomSheet(context: context, place: poi);
            }
          },
          onMapCreated: (mapController) {
            _mapController.complete(mapController);
          })
    );
  }
}