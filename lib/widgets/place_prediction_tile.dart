import 'package:flutter/material.dart';
import 'package:hopin/Model/predicted_places.dart';

class PlacePredictionTileDesign extends StatefulWidget {
  // const PlacePredictionTileDesign({super.key});
  final PredictedPlaces? predictedPlaces;

  PlacePredictionTileDesign({this.predictedPlaces});

  @override
  State<PlacePredictionTileDesign> createState() =>
      _PlacePredictionTileDesignState();
}

class _PlacePredictionTileDesignState extends State<PlacePredictionTileDesign> {


getPlaceDirectionDetails(){
  
}


  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return ElevatedButton(
      onPressed: () {},
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
