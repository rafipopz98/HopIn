import 'package:flutter/material.dart';
import 'package:hopin/Assistant/request_assistan.dart';
import 'package:hopin/Model/directions.dart';
import 'package:hopin/Model/predicted_places.dart';
import 'package:hopin/global/global.dart';
import 'package:hopin/global/map_key.dart';
import 'package:hopin/infoHandler/app_info.dart';
import 'package:hopin/widgets/progress_dialog.dart';
import 'package:provider/provider.dart';

class PlacePredictionTileDesign extends StatefulWidget {
  // const PlacePredictionTileDesign({super.key});
  final PredictedPlaces? predictedPlaces;

  PlacePredictionTileDesign({this.predictedPlaces});

  @override
  State<PlacePredictionTileDesign> createState() =>
      _PlacePredictionTileDesignState();
}
 
class _PlacePredictionTileDesignState extends State<PlacePredictionTileDesign> {
  getPlaceDirectionDetails(String? placeId, context) async {
    showDialog( 
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        message: "Setting up DropOFF.PLease wait......",
      ),
    );
    String placeDirectionDetailsUrl =
        "https://maps.googleapis.com/maps/api/place/deatils/json?place_id=$placeId&key=$mapKey";
    var responseApi =
        await RequstAssistant.recieveRequest(placeDirectionDetailsUrl);
    Navigator.pop(context);
    if (responseApi == "Error Occured,Failed,No Response") {
      return;
    }

    if (responseApi["status"] == "OK") {
      Directions directions = Directions();
      directions.locationName = responseApi["result"]["name"];
      directions.locationid = placeId;
      directions.locationLatitude =
          responseApi["result"]["geometry"]["location"]["lat"];
      directions.locationLongitude =
          responseApi["result"]["geometry"]["location"]["lng"];
      // directions.locationLongitude=responseApi["result"]["name"];

      Provider.of<AppInfo>(context, listen: false)
          .updateDropOffLocationAddress(directions);

      setState(() {
        userDropOffAddress = directions.locationName!;
      });
      Navigator.pop(context, "ObtainedDropOff");
    } 
  } 

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return ElevatedButton(
      onPressed: () {
        getPlaceDirectionDetails(widget.predictedPlaces!.place_id, context);
      },
      style: ElevatedButton.styleFrom(
        primary: darkTheme ? Colors.black : Colors.white,
      ),
      child: Row(
        children: [
          Icon(
            Icons.add_location,
            color: darkTheme ? Colors.amber.shade400 : Colors.blue,
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.predictedPlaces!.main_text!,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                ),
              ),
              Text(
                widget.predictedPlaces!.secondary_text!,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                ),
              ),
            ],
          ))
        ],
      ),
    );
  }
}
