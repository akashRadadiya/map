import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map/google_map/LocationController.dart';

class mapScreen extends StatefulWidget {
  const mapScreen({Key? key}) : super(key: key);

  @override
  State<mapScreen> createState() => _mapScreenState();
}

class _mapScreenState extends State<mapScreen> {
  GoogleMapController? _controller;
  List addressList = [];

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(locationController());
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Locate Me on Map',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery
                  .of(context)
                  .size
                  .height / 1.5,
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  GoogleMap(
                    mapType: MapType.terrain,

                    initialCameraPosition: CameraPosition(
                      target: LatLng(controller.position.latitude,
                          controller.position.longitude),

                      zoom: 15,
                    ),
                    zoomControlsEnabled: false,
                    zoomGesturesEnabled: true,
                    compassEnabled: false,
                    indoorViewEnabled: true,
                    mapToolbarEnabled: true,
                    onCameraIdle: () {
                      controller.dragableAddress();

                      setState(() {
                        addressList.add(
                            "Address: ${controller.address.street!}, ${controller.address
                                .subLocality!}, ${controller.address
                                .locality}, ${controller.address
                                .administrativeArea!}, ${controller.address
                                .country}");
                        addressList
                            .add("\nLatitude: ${controller.position.latitude}");
                        addressList
                            .add("Longitude: ${controller.position.longitude}");
                      });
                    },
                    onCameraMove: ((position) {
                      addressList.clear();

                      controller.updatePosition(position);
                    }),
                    onMapCreated: (GoogleMapController gmcontroller) {
                      _controller = gmcontroller;
                      if (_controller != null) {
                        controller.getCurrentlocation(
                            mapController: _controller);
                      }
                    },
                  ),
                  Positioned(
                    bottom: 16,
                    right: 0,
                    left: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            controller.getCurrentlocation(
                                mapController: _controller);
                          },
                          child: Container(
                            width: 35,
                            height: 35,
                            margin: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.white,
                            ),
                            child: const Icon(
                              Icons.my_location,
                              size: 30,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      alignment: Alignment.center,
                      height: MediaQuery
                          .of(context)
                          .size
                          .height,
                      child: Image.asset(
                        'assets/loc_marker.png',
                        width: 40,
                        height: 40,
                        color: Colors.black,
                      )),
                ],
              ),
            ),
            Card(
              elevation: 10,
              color: Colors.blue[100],
              child:  SizedBox(
                width: 350,
                height: 150,
                child: Center(child:
                ListView(
                  padding: const EdgeInsets.all(16),
                  shrinkWrap: true,
                  children: [
                    const Text(
                      "Map Location",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    for (int i = 0; i < addressList.length; i++)
                      Text(addressList[i].toString()),
                  ],
                )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
