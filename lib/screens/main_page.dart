import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hopin/Assistant/assistant_method.dart';
import 'package:hopin/Model/directions.dart';
import 'package:hopin/global/global.dart';
import 'package:hopin/global/map_key.dart';
import 'package:hopin/infoHandler/app_info.dart';
import 'package:hopin/screens/precise_pickup_location.dart';
import 'package:hopin/screens/search_places_screen.dart';
import 'package:hopin/widgets/progress_dialog.dart';
// import 'package:google_maps_flutter_web/google_maps_flutter_web.dart' as lol;
import 'package:location/location.dart' as loc;
import 'package:geolocator/geolocator.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:provider/provider.dart';

// import 'package:geo'
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  LatLng? pickLocation;
  loc.Location location = loc.Location();
  String? _address;

  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapControler;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  double serachLocationContainerHeight = 220;
  double waitingResponseFromDriverContainerHeight = 0;
  double assignedDriverInfoDriverContainerHeight = 0;

  Position? userCurrentPosition;
  var geoLocation = Geolocator();

  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;

  List<LatLng> pLineCordinateList = [];
  Set<Polyline> polyLineSet = {};

  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};

  String? userName = "";
  String? userEmail = "";

  bool navigationDrawer = true;

  bool activeNearbyDriversLoaded = false;

  BitmapDescriptor? activeNearbyIcon;

  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;

    LatLng latLngPosition =
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 15);

    newGoogleMapControler!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress =
        await AssistantMethods.searchAddressForGeographicCoordinates(
            userCurrentPosition!, context);
    print("This is our Address" + humanReadableAddress);

    userName = userModelCurrentInfo!.name;
    userEmail = userModelCurrentInfo!.email;
  }

  Future<void> drawPolylineFromOriginToDestination(bool darkTheme) async {
    var originPosition =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationPosition =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    var originLatlng = LatLng(
        originPosition!.locationLatitude!, originPosition!.locationLongitude!);
    var destinationLatlng = LatLng(destinationPosition!.locationLatitude!,
        destinationPosition!.locationLongitude!);

    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        message: "Please wait...",
      ),
    );

    var directionsDetailsInfo =
        await AssistantMethods.ObtainedOriginToDestinationDirectionDetails(
            originLatlng, destinationLatlng);
    setState(() {
      tripDirectionDetailsInfo = directionsDetailsInfo;
    });

    Navigator.pop(context);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodePolylinePointsResultList =
        pPoints.decodePolyline(directionsDetailsInfo.e_points!);
    pLineCordinateList.clear();
    if (decodePolylinePointsResultList.isNotEmpty) {
      decodePolylinePointsResultList.forEach((PointLatLng pointLatLng) {
        pLineCordinateList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    polyLineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        color: darkTheme ? Colors.amberAccent : Colors.blue,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCordinateList,
        startCap: Cap.roundCap,
        geodesic: true,
        width: 5,
      );
      polyLineSet.add(polyline);
    });
    LatLngBounds boundsLatlng;
    if (originLatlng.latitude > destinationLatlng.latitude &&
        originLatlng.longitude > destinationLatlng.longitude) {
      boundsLatlng =
          LatLngBounds(southwest: destinationLatlng, northeast: originLatlng);
    } else if (originLatlng.longitude > destinationLatlng.longitude) {
      boundsLatlng = LatLngBounds(
          southwest: LatLng(originLatlng.latitude, destinationLatlng.longitude),
          northeast:
              LatLng(destinationLatlng.latitude, originLatlng.longitude));
    } else if (originLatlng.latitude > destinationLatlng.latitude) {
      boundsLatlng = LatLngBounds(
          southwest: LatLng(destinationLatlng.latitude, originLatlng.longitude),
          northeast:
              LatLng(originLatlng.latitude, destinationLatlng.longitude));
    } else {
      boundsLatlng =
          LatLngBounds(southwest: originLatlng, northeast: destinationLatlng);
    }

    newGoogleMapControler!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatlng, 65));

    Marker originMarker = Marker(
      markerId: MarkerId("originID"),
      infoWindow:
          InfoWindow(title: originPosition.locationName, snippet: "Origin"),
      position: originLatlng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    Marker destinationMarker = Marker(
      markerId: MarkerId("destinationID"),
      infoWindow: InfoWindow(
          title: destinationPosition.locationName, snippet: "Destination"),
      position: destinationLatlng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    setState(() {
      markerSet.add(originMarker);
      markerSet.add(destinationMarker);
    });
    Circle originCircle = Circle(
        circleId: CircleId("originID"),
        fillColor: Colors.green,
        radius: 12,
        strokeWidth: 3,
        strokeColor: Colors.white,
        center: originLatlng);
    Circle destinationCircle = Circle(
        circleId: CircleId("destinationID"),
        fillColor: Colors.red,
        radius: 12,
        strokeWidth: 3,
        strokeColor: Colors.white,
        center: destinationLatlng);
    setState(() {
      circleSet.add(originCircle);
      circleSet.add(destinationCircle);
    });
  }

  // getAddressFromLatlng() async {
  //   try {
  //     GeoData data = await Geocoder2.getDataFromCoordinates(
  //         latitude: pickLocation!.latitude,
  //         longitude: pickLocation!.longitude,
  //         googleMapApiKey: mapKey);
  //     setState(() {
  //       Directions userPickUpAddress = Directions();
  //       userPickUpAddress.locationLatitude = pickLocation!.latitude;
  //       userPickUpAddress.locationLongitude = pickLocation!.longitude;
  //       userPickUpAddress.locationName = data.address;
  //       // _address = data.address;

  //       Provider.of<AppInfo>(context, listen: false)
  //           .updatePickUpLocationAddress(userPickUpAddress);
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    checkIfLocationPermissionAllowed();
  }

  // String
  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              initialCameraPosition: _kGooglePlex,
              polylines: polyLineSet,
              markers: markerSet,
              circles: circleSet,
              onMapCreated: (GoogleMapController controller) {
                _controllerGoogleMap.complete(controller);
                newGoogleMapControler = controller;
                setState(() {});
                locateUserPosition();
              },
              // onCameraMove: (CameraPosition? position) {
              //   if (pickLocation != position!.target) {
              //     setState(() {
              //       pickLocation = position.target;
              //     });
              //   }
              // },
              // onCameraIdle: () {
              //   getAddressFromLatlng();
              // },
            ),
            // Align(
            //   alignment: Alignment.center,
            //   child: Padding(
            //     padding: const EdgeInsets.only(bottom: 35.0),
            //     child: Image.asset(
            //       'images/pick.jpg',
            //       height: 45,
            //       width: 45,
            //     ),
            //   ),
            // ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: darkTheme ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: darkTheme
                                      ? Colors.grey.shade900
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(children: [
                                  Padding(
                                    padding: EdgeInsets.all(5),
                                    child: Row(children: [
                                      Icon(Icons.location_on_outlined,
                                          color: darkTheme
                                              ? Colors.amber.shade400
                                              : Colors.blue),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "From",
                                            style: TextStyle(
                                              color: darkTheme
                                                  ? Colors.amber.shade400
                                                  : Colors.blue,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            Provider.of<AppInfo>(context)
                                                        .userPickUpLocation !=
                                                    null
                                                ? (Provider.of<AppInfo>(context)
                                                            .userPickUpLocation!
                                                            .locationName!)
                                                        .substring(0, 24) +
                                                    "..."
                                                : "Not Getting Address",
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14),
                                            // overflow: TextOverflow.visible,
                                            // softWrap: true,
                                          )
                                        ],
                                      )
                                    ]),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Divider(
                                    height: 1,
                                    thickness: 2,
                                    color: darkTheme
                                        ? Colors.amber.shade400
                                        : Colors.blue,
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(5),
                                    child: GestureDetector(
                                      onTap: () async {
                                        //search scrrreeen
                                        var responseFromSearchScreen =
                                            await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (c) =>
                                                        SearchPlacesScreen()));
                                        if (responseFromSearchScreen ==
                                            "ObtainedDropOff") {
                                          setState(() {
                                            // openNavigationDrawer=false;
                                          });
                                        }
                                        await drawPolylineFromOriginToDestination(
                                            darkTheme);
                                      },
                                      child: Row(children: [
                                        Icon(Icons.location_on_outlined,
                                            color: darkTheme
                                                ? Colors.amber.shade400
                                                : Colors.blue),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "To",
                                              style: TextStyle(
                                                color: darkTheme
                                                    ? Colors.amber.shade400
                                                    : Colors.blue,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              Provider.of<AppInfo>(context)
                                                          .userDropOffLocation !=
                                                      null
                                                  ? Provider.of<AppInfo>(
                                                          context)
                                                      .userDropOffLocation!
                                                      .locationName!
                                                  : "Destination Address",
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14),
                                              // overflow: TextOverflow.visible,
                                              // softWrap: true,
                                            )
                                          ],
                                        )
                                      ]),
                                    ),
                                  )
                                ]),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: [
                                  ElevatedButton(
                                      onPressed: () {},
                                      child: Text(
                                        "Change Pick Up",
                                        style: TextStyle(
                                            color: darkTheme
                                                ? Colors.black
                                                : Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                          primary: darkTheme
                                              ? Colors.amber.shade400
                                              : Colors.blue,
                                          textStyle: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16))),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (c) =>
                                                    precisePickupLocation()));
                                      },
                                      child: Text(
                                        "Request a Ride",
                                        style: TextStyle(
                                            color: darkTheme
                                                ? Colors.black
                                                : Colors.white),
                                      ), 
                                      style: ElevatedButton.styleFrom(
                                          primary: darkTheme
                                              ? Colors.amber.shade400
                                              : Colors.blue,
                                          textStyle: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)))
                                ],
                              )
                            ],
                          ),
                        )
                      ])),
            )

            // Positioned(
            //   top: 40,
            //   right: 20,
            //   left: 20,
            //   child: Container(
            //     decoration: BoxDecoration(
            //       border: Border.all(color: Colors.black),
            //       color: Colors.white,
            //     ),
            //     padding: EdgeInsets.all(20),
            //     child: Text(
            //       Provider.of<AppInfo>(context).userPickUpLocation != null
            //           ? (Provider.of<AppInfo>(context)
            //                       .userPickUpLocation!
            //                       .locationName!)
            //                   .substring(0, 24) +
            //               "..."
            //           : "Not Getting Address",
            //       overflow: TextOverflow.visible,
            //       softWrap: true,
            //     ),
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}
