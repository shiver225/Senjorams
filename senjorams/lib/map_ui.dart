import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:senjorams/main.dart';
import 'package:senjorams/models/place_model.dart';
import 'package:senjorams/models/place_prediction_model.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:math' as math;

const apiKey="AIzaSyAVd3YlwDIiYmq1Lmq1rpXkkxaN5V0zUNc"; //not safe i bet
extension HexColor on Color {
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
  final TextEditingController _searchFieldController = TextEditingController();
  final CarouselController _controller = CarouselController();
  //GlobalKey _globalKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final Map<PolylineId, Polyline> _polylines = {};
  List<LatLng> _polylineCoordinates = [];


  List<Place> _places = [];
  final List<PlacePrediction> _searchResult = [];
  final List<Place> _placesTrashCan = [];
  Place? _markedPlace;

  LocationData? _currentLocation; 
  LatLng? _poiMarkerLocation;
  bool _isPoiMarkerVisible = false;
  Timer? _debounce;

  int _current = 0; //index for image carousel
  late String _timeString = '';
  late dynamic timer;
  late FocusNode _mapFocusNode;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadData();
    _updateTime(); // Update time initially
    timer =
        Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
    _mapFocusNode = FocusNode();
  }
  void _updateTime() {
    final DateTime now = DateTime.now();
    setState(() {
      _timeString = DateFormat.Hms().format(now);
    });
  }
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
  void _loadData() {
    final String? saved = prefs?.getString('savedPlaces');
    print(saved);
    if (saved != null) {
      final List<dynamic> decoded = json.decode(saved);
      _places = decoded
          .map((place) => Place.fromJson(Map<String, dynamic>.from(place)))
          .toList();
    }
  }
  //could just use the returned json from api call instead
  Future<void> _saveData() async {
    final String placeL = json.encode(_places);
    await prefs?.setString('savedPlaces', placeL);
  }
  Future<Place?> _nearbySearch(LatLng position) async{
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
    "excludedTypes": ["parking", "atm"],
    };

    try{
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
    
      return Place.fromJson(values["places"][0]);
    }
    catch(e){
      log(e.toString());
      return null;
    }
  }
  Future<Place?> _fetchPoi(String placeId) async{
    try{
      http.Response response =  await http.get(Uri.parse('https://places.googleapis.com/v1/places/$placeId'),
        headers: {
          "Content-Type": "application/json",
          "X-Goog-Api-Key": apiKey,
          "X-Goog-FieldMask": "location,id,displayName,iconBackgroundColor,formattedAddress,reviews,regularOpeningHours,rating,photos,userRatingCount,iconMaskBaseUri"
          },
      );
      Map<String,dynamic> value = jsonDecode(response.body);
      log(response.body);

      return Place.fromJson(value);
      }
    catch(e){
      log(e.toString());
      return null;
    }
  }
  
  Future<List<PlacePrediction>?> _autoCopleteSearch(String value) async{
    if(value.isEmpty){
      return null;
    }
    Map data = {
      "input": value,
      "locationBias": {
        "circle": {
          "center": {
            "latitude": _currentLocation?.latitude,
            "longitude": _currentLocation?.longitude},
          "radius": 500.0
        }
      },
    };

    try{
      http.Response response =  await http.post(Uri.parse('https://places.googleapis.com/v1/places:autocomplete'),
        headers: {
          "Content-Type": "application/json",
          "X-Goog-Api-Key": apiKey,
          },
        body: json.encode(data),
      );
      Map values = jsonDecode(response.body);
      log(response.body);
      return (values["suggestions"] as List<dynamic>).map((place) => PlacePrediction.fromJson(Map<String, dynamic>.from(place)["placePrediction"])).toList();
    }
    catch(e){
      log(e.toString());
      return null;
    }
  }
  double _calculateDistane(List<LatLng> polyline) {
    double totalDistance = 0;
    for (int i = 0; i < polyline.length; i++) {
      if (i < polyline.length - 1) { // skip the last index
        totalDistance += _getStraightLineDistance(
            polyline[i + 1].latitude,
            polyline[i + 1].longitude,
            polyline[i].latitude,
            polyline[i].longitude);
      }
    }
    return totalDistance;
  }
  double _getStraightLineDistance(lat1, lon1, lat2, lon2) {
    var R = 6371; // Radius of the earth in km
    var dLat = _deg2rad(lat2 - lat1);
    var dLon = _deg2rad(lon2 - lon1);
    var a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) *
            math.cos(_deg2rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    var c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    var d = R * c; // Distance in km
    return d * 1000; //in m
  }

  dynamic _deg2rad(deg) {
    return deg * (math.pi / 180);
  }

  void _createPolylines(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    PolylinePoints _polylinePoints;
    // Initializing PolylinePoints
    _polylinePoints = PolylinePoints();
    List<LatLng> _polylineCoordinatesTemp = [];
    // Generating the list of coordinates to be used for
    // drawing the polylines
    PolylineResult result = await _polylinePoints.getRouteBetweenCoordinates(
      apiKey, // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.transit,
    );

    // Adding the coordinates to the list
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        _polylineCoordinatesTemp.add(LatLng(point.latitude, point.longitude));
      });
    }

    // Defining an ID
    PolylineId id = PolylineId('poly');
    _polylineCoordinates = _polylineCoordinatesTemp;
    // Initializing Polyline
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: _polylineCoordinates,
      width: 6,
    );

    // Adding the polyline to the map
    _polylines[id] = polyline;
}
  void _getCurrentLocation() async {
    Location location = Location();
    location.getLocation().then((location) {
      setState(() {
        _currentLocation = location;
      });
    });
    location.onLocationChanged.listen((newLocation) {
      setState(() {
        _currentLocation = newLocation;
        if(_polylines.isNotEmpty){
          _createPolylines(_currentLocation!.latitude!, _currentLocation!.longitude!, _polylineCoordinates.last.latitude, _polylineCoordinates.last.longitude);
        }
      });
    });
  }
  void _moveCameraToPosition(LatLng position) async {
    GoogleMapController googleMapController = await _mapController.future;
    googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(zoom: 15.0, target: position)));
  }
  Widget _imageCarouselWithInticator(Place place, StateSetter setModalState) {
    final List<Widget> imageSliders = place.photos!
        .map((item) => Container(
              margin: const EdgeInsets.all(5.0),
              child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                  child: Stack(
                    children: <Widget>[
                      Image.network(
                        'https://places.googleapis.com/v1/${item.name}/media?maxHeightPx=400&maxWidthPx=400&key=$apiKey',
                        fit: BoxFit.cover,
                        height: 400,
                      ), //cheap fix by setting height to 400
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
            ))
        .toList();
    return SizedBox(
      height: 300,
      child: Column(children: [
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
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
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

  void _modalBottomSheet({required Place place}){
    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled:true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState){
          return FractionallySizedBox(
            heightFactor: 0.85,
           child: Stack(
            children: [
              Positioned(
                top: MediaQuery.of(context).size.height *0.1,
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: Column(
                    children: <Widget>[   
                      Row(
                        children: <Widget>[
                          TextButton(
                            child: const Icon(
                              Icons.clear, 
                              color: Colors.red,
                              size: 28,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Spacer(),
                          if(!_places.any((pl) => pl.id == place.id)) 
                          TextButton(
                            child: const Text(
                              "IŠSAUGOTI",
                              style: TextStyle(
                                color: Color.fromARGB(255, 132, 180, 187),
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                ),
                              ),
                            onPressed: () async {
                              setState(() {_places.add(place); _saveData();});
                              Navigator.pop(context);
                            }
                          )
                          ]
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
                            place.rating != null ? place.rating.toString() : "Nėra atsiliepimų",
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
                        (place.regularOpeningHours != null
                            ? (place.regularOpeningHours!.openNow
                                ? "Atidaryta"
                                : "Uždaryta")
                                : ""),
                            style: TextStyle(
                          color: place.regularOpeningHours != null
                              ? (place.regularOpeningHours!.openNow
                                  ? const Color.fromARGB(255, 121, 190, 41) // Pastel green for "Open"
                                  : const Color.fromARGB(255, 196, 196, 74)) // Pastel yellow for "Closed"
                              : Colors.black, // Default color
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      if(place.photos!=null) _imageCarouselWithInticator(place, setModalState),
                    ],
                  ),
                ),
              ),
              Positioned(
                left:10,
                bottom: MediaQuery.of(context).size.height * 0.75,
                child: ElevatedButton(
                  onPressed: () {
                    setState((){
                      if(!_isPoiMarkerVisible) {return;}
                      _polylines.clear();
                      _createPolylines(_currentLocation!.latitude!, _currentLocation!.longitude!, _poiMarkerLocation!.latitude, _poiMarkerLocation!.longitude);
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF4E1C4),
                  ),
                  child: const Icon(
                    Icons.directions,
                    color: Colors.black,
                  ),
                )
              )
            ]
        ));
        });
        });
  }

  void _toggleSelection(Place place) {
    setState(() {
      if (place.isSelected) {
        place.cardColor = Colors.white;
        place.isSelected = false;
        _placesTrashCan.remove(place);
      } else {
        place.cardColor = const Color.fromARGB(255, 223, 222, 222);
        place.isSelected = true;
        _placesTrashCan.add(place);
      }
    });
  }
  String _formatDistance(double distance){
    if(distance >= 1000)
    {
      return (distance/1000).toStringAsFixed(2) + "km";
    }
    return distance.toStringAsFixed(2) + "m";
  }
  Widget _placesCard(int index) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    color: Color.fromARGB(255, 255, 228, 181), // Same color as your location button
    elevation: 4, // Increased elevation for more visible shadow
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        InkWell(
          onTap: _placesTrashCan.isEmpty
              ? () {
                  _moveCameraToPosition(_places[index].location!);
                  _modalBottomSheet(place: _places[index]);
                  setState(() {
                    _poiMarkerLocation = _places[index].location;
                    _isPoiMarkerVisible = true;
                  });
                  if (_scaffoldKey.currentState!.isEndDrawerOpen) {
                    _scaffoldKey.currentState!.closeEndDrawer();
                  }
                }
              : () => _toggleSelection(_places[index]),
          onLongPress: () {
            _toggleSelection(_places[index]);
            Feedback.forTap(context);
          },
          borderRadius: BorderRadius.circular(14),
          child: ListTile(
            selected: _places[index].isSelected,
            title: Text(
              _places[index].displayName!.text,
              style: TextStyle(
                color: Colors.black, // Black text color
                fontWeight: FontWeight.bold, // Make the text slightly bolder
                fontSize: 16, // Adjust the font size as needed
              ),
            ),
            trailing: _placesTrashCan.isNotEmpty
                ? Checkbox(
                    value: _places[index].isSelected,
                    onChanged: (bool? value) {
                      Feedback.forTap(context);
                      _toggleSelection(_places[index]);
                    },
                  )
                : null,
          ),
        )
      ],
    ),
  );
}
  Widget _sideNavigationBar() {
  return Drawer(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 100,
          alignment: AlignmentDirectional.center,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFF92C7CF), // Match the app's accent color
          ),
          child: const Text(
            "SAVED PLACES",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _places.length,
            itemBuilder: (_, index) {
              return _placesCard(index);
            },
          ),
        ),
        if (_placesTrashCan.isNotEmpty)
          ButtonTheme(
            minWidth: 200.0,
            height: 100.0,
            child: IconButton(
              onPressed: () async {
                _places.removeWhere(
                  (item) => _placesTrashCan.contains(item),
                );
                // Disable alarm
                await _saveData();
                setState(() {
                  _placesTrashCan.clear();
                  _isPoiMarkerVisible = false;
                  _polylines.clear();
                });
              },
              icon: const Icon(
                Icons.delete,
                size: 100,
                color: Colors.black, // Match the app's accent color
              ),
            ),
          ),
      ],
    ),
  );
}
@override
Widget build(BuildContext context) {
  bool mapLoaded = _currentLocation != null;
  return GestureDetector(
    onTap: () {
      FocusScope.of(context).unfocus();
    },
    child: Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset : false,
      endDrawer: _sideNavigationBar(),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Shimmer effect while loading the map
          if (!mapLoaded)
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
              ),
            ),
          if (!mapLoaded)
            const Center(
              child: Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 24.0,
                  //fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (mapLoaded)
            GoogleMap(
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              initialCameraPosition: CameraPosition(
                target: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
                zoom: 15.0,
              ),
              polylines: Set<Polyline>.of(_polylines.values),
              markers: {
                if (_poiMarkerLocation != null) Marker(
                  markerId: const MarkerId("selectedPlace"), 
                  visible: _isPoiMarkerVisible,
                  position: _poiMarkerLocation!,
                  onTap: () => {if(_markedPlace!=null && _isPoiMarkerVisible) {_modalBottomSheet(place: _markedPlace!)}},
                )
              },
              onTap: (location) {
                if(_polylines.isNotEmpty){return;}
                if (_debounce?.isActive ?? false) _debounce!.cancel();
                _debounce = Timer(const Duration(milliseconds: 1000), () async
                  {
                    Place? poi = await _nearbySearch(location);
                    if(poi == null) {return;}
                    _modalBottomSheet(place: poi);
                    _markedPlace=poi;
                    
                  });
                  setState(() {
                    _poiMarkerLocation=location;
                    _isPoiMarkerVisible = true;
                  });
              },
              onMapCreated: (mapController) {
                _mapController.complete(mapController);
              }
            ),
          if (mapLoaded && _polylines.isNotEmpty)
            Positioned(
              bottom: 20,
              child: Text(
                _formatDistance(_calculateDistane(_polylineCoordinates)),
                style: const TextStyle(
                  fontSize: 50, 
                  color: Color(0xFF92C7CF), 
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow( // bottomLeft
                      offset: Offset(-1.5, -1.5),
                      color: Colors.black
                    ),
                    Shadow( // bottomRight
                      offset: Offset(1.5, -1.5),
                      color: Colors.black
                    ),
                    Shadow( // topRight
                      offset: Offset(1.5, 1.5),
                      color: Colors.black
                    ),
                    Shadow( // topLeft
                      offset: Offset(-1.5, 1.5),
                      color: Colors.black
                    ),
                  ]),
                ),
            ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              leading: Padding(
                padding: const EdgeInsets.only(
                    left: 30), // Adjust the left padding as needed
                child: IconButton(
                  icon: const FaIcon(FontAwesomeIcons.arrowLeft),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20), // Adjust the padding as needed
                  child: IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      _scaffoldKey.currentState!.openEndDrawer();
                    },
                  ),
                ),
              ],
              automaticallyImplyLeading: false,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(50),
                ),
              ),
              backgroundColor: const Color(0xFF92C7CF),
              title: Text(
                _timeString,
                style:
                    const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            ),
          ),
          if (mapLoaded) // Render text field and my location button only if map has finished loading
            Positioned(
              left: 0,
              right: 0,
              top: 100, // Adjusted to leave space for the text input field
              child: Container(
              width: 350,
              height: 75,
              padding: const EdgeInsets.all(8),
              child:TypeAheadField<PlacePrediction>(
                controller: _searchFieldController,
                itemBuilder: (context, place) {
                  return ListTile(
                    title: Text(place.structuredFormat.mainText.text),
                    subtitle: Text(place.structuredFormat.secondaryText.text),
                  );
                },
                builder: (context, controller, focusNode) {
                  return TextField(
                    controller: _searchFieldController,
                    focusNode: focusNode,
                    autofocus: false,
                    onTapOutside: (event) => {focusNode.unfocus()},
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Color(0xFF92C7CF),
                          width: 2.0, // Thicker border
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Color(0xFF92C7CF),
                          width: 2.0, // Thicker border when focused
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Color(0xFF92C7CF),
                          width: 2.0, // Thicker border when enabled
                        ),
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.blueAccent), // More colorful search icon
                      suffixIcon: IconButton(
                        onPressed: () {
                          _searchFieldController.clear();
                          setState(() {
                            _searchResult.clear();
                          });
                        },
                        icon: const Icon(Icons.cancel, color: Colors.redAccent), // More colorful cancel icon
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      hintText: 'Paieška',
                      hintStyle: const TextStyle(fontSize: 18, color: Color.fromARGB(255, 58, 58, 58)),
                    ),
                  );
                },
                debounceDuration: const Duration(milliseconds: 1000),
                suggestionsCallback: (value) async {
                  return await _autoCopleteSearch(value);
                },
                onSelected: (value) async {
                  //
                  _searchFieldController.text = value.text.text;

                  Place? place = await _fetchPoi(value.placeId);
                  if(place == null){return;}
                  _moveCameraToPosition(LatLng(place.location!.latitude, place.location!.longitude));
                  FocusManager.instance.primaryFocus?.unfocus();
                  setState(() {
                    _poiMarkerLocation=LatLng(place.location!.latitude, place.location!.longitude);
                    _isPoiMarkerVisible = true;
                    _markedPlace=place;
                  });
                  _modalBottomSheet(place: place);
                },
              )
            ),
          ),
        if (mapLoaded) 
          Positioned(
            bottom: 15,
            left: 15,
            child: FloatingActionButton(
              heroTag: "btnLeft",
              onPressed: () {
                setState(() {
                  _isPoiMarkerVisible = false;
                  _polylines.clear();
                });
              },
              backgroundColor: Color(0xFFF4E1C4), // Light sand color
              child: const Icon(Icons.directions_off, color: Colors.black),
            ),
        ),
        if (mapLoaded)
          Positioned(
            bottom: 15,
            right: 15,
            child: FloatingActionButton(
              heroTag: "btnRight",
              onPressed: () => _moveCameraToPosition(LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!)),
              backgroundColor: Color(0xFFF4E1C4), // Light sand color
              child: const Icon(Icons.location_on, color: Colors.black),
            ),
          ),
        ],
      ),
    ),
  );
}
}