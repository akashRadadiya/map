import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class locationController extends GetxController {


  Position _position = Position(
      longitude: 0,
      latitude: 0,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 1,
      heading: 1,
      speed: 1,
      speedAccuracy: 1);

  bool _loading = false;

  bool get loading => _loading;

  Position get position => _position;

  Placemark _address = Placemark();

  Placemark get address => _address;


  Future<void> getCurrentlocation({GoogleMapController? mapController}) async {
    bool serviceEnable;


    /*Location Permition*/
    LocationPermission permission;
    var serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied){
        return Future.error('Location Permission are denied');
      }
    }
    if (permission == LocationPermission.deniedForever){
      return Future.error('Location permission are permanently denied');
    }


    try {
      Position newLocalData = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      if (mapController != null) {
        mapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(newLocalData.latitude, newLocalData.longitude),
                zoom: 17)));
        _position = newLocalData;

        List<Placemark> placemarks = await placemarkFromCoordinates(
            newLocalData.latitude, newLocalData.longitude);
        _address = placemarks.first;
      }
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
    _loading = false;
  }

  void updatePosition(CameraPosition position) async {
    _position = Position(
        longitude: position.target.longitude,
        latitude: position.target.latitude,
        timestamp: DateTime.now(),
        accuracy: 1,
        altitude: 1,
        heading: 1,
        speed: 1,
        speedAccuracy: 1);
    _loading = true;
  }

  Future<void> dragableAddress() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _position.latitude, _position.longitude);
      _address = placemarks.first;
      _loading = false;
    } catch (e) {
      _loading = false;
    }
  }
}
