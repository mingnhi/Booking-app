import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/location_service.dart';

class LocationListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Danh sách địa điểm')),
      body: Consumer<LocationService>(
        builder: (context, locationService, _) {
          if (locationService.isLoading) return Center(child: CircularProgressIndicator());
          return ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: locationService.locations.length,
            itemBuilder: (context, index) {
              final location = locationService.locations[index];
              return ListTile(
                title: Text(location.location),
                subtitle: Text('ID: ${location.id}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => Navigator.pushNamed(context, '/location/edit/${location.id}'),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        await locationService.deleteLocation(location.id);
                        locationService.fetchLocations();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/location/create'),
        child: Icon(Icons.add),
      ),
    );
  }
}