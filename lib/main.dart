import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'dart:math' show cos, sqrt, asin;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  late List<dynamic> _data;
  bool _sortAscending = true;
  int _sortColumnIndex = 0;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final url = Uri.parse('https://fluttermysqlsames.000webhostapp.com/getData.php');
    final response = await http.get(url);
    setState(() {
      _data = jsonDecode(response.body);
    });
  }

  void _showImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(),
          body: Center(
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                height: MediaQuery.of(context).size.height,
              ),
            ),
          ),
        ),
      ),
    );
  }
  LocationData? _currentLocation;

  Future<void> _getCurrentLocation() async {
    LocationData? locationData;
    var location = Location();
    try {
      locationData = await location.getLocation();
    } catch (e) {
      print('Could not get location: $e');
    }
    if (locationData != null) {
      print('Latitude: ${locationData.latitude}');
      print('Longitude: ${locationData.longitude}');
      setState(() {
        _currentLocation = locationData;
      });
    }
  }

  Widget build(BuildContext context) {
    // Define the number of items to display per page
    final int _perPage = 10;
    // Calculate the number of pages
    final int _totalPages = (_data.length / _perPage).ceil();

    // Define the current page and the start/end indices for the displayed items
    int _currentPage = 0;
    int _startIndex = _currentPage * _perPage;
    int _endIndex = (_startIndex + _perPage < _data.length)
        ? _startIndex + _perPage
        : _data.length;

    // Define a function to update the displayed items based on the current page
    void _updateDisplayedItems() {
      _startIndex = _currentPage * _perPage;
      _endIndex = (_startIndex + _perPage < _data.length)
          ? _startIndex + _perPage
          : _data.length;
    }

    // Update the displayed items on initial build
    _updateDisplayedItems();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: _data == null
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            DataTable(
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAscending,
              columns: [
                DataColumn(
                  label: Text('Nazwa'),
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      _sortColumnIndex = columnIndex;
                      _sortAscending = ascending;
                      _data.sort((a, b) => a['name'].compareTo(b['name']));
                      if (!_sortAscending) {
                        _data = _data.reversed.toList();
                      }
                    });
                  },
                ),
                DataColumn(
                  label: Text('Miasto'),
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      _sortColumnIndex = columnIndex;
                      _sortAscending = ascending;
                      _data.sort((a, b) => a['Miasto'].compareTo(b['Miasto']));
                      if (!_sortAscending) {
                        _data = _data.reversed.toList();
                      }
                    });
                  },
                ),
                DataColumn(label: Text('Opis')),
                DataColumn(label: Text('Zdjęcie')),
                DataColumn(
                  label: Text('Ocena'),
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      _sortColumnIndex = columnIndex;
                      _sortAscending = ascending;
                      _data.sort(
                            (a, b) => double.parse(a['ocena']).compareTo(double.parse(b['ocena'])),
                      );
                      if (!_sortAscending) {
                        _data = _data.reversed.toList();
                      }
                    });
                  },
                ),
                DataColumn(label: Text('Link')),
              ],
              rows: List<DataRow>.generate(
                _endIndex - _startIndex,
                    (index) => DataRow(
                  cells: [
                    DataCell(
                      Text(
                        _data[index]['name'],
                        style: TextStyle(
                          fontSize: 17,

                        ),
                      ),
                    ),

                    DataCell(
                      Text(
                        _data[index]['Miasto'],
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                    DataCell(
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Opis'),
                                content: Text(_data[index]['opis']),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text('Zobacz opis'),
                      ),
                    ),
                    DataCell(
                      ElevatedButton(
                        onPressed: () {
                          _showImage(context, _data[index]['img']);
                        },
                        child: Text('Pokaż zdjęcie'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.orange,
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          Text(
                            _data[index]['ocena'],
                            style: TextStyle(fontSize: 17),
                          ),
                          Icon(Icons.star, color: Colors.yellow),
                        ],
                      ),
                    ),
                    DataCell(
                      ElevatedButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _data[index]['Googlge_link']));
                        },
                        child: Text('Link'),
                      ),
                    ),
                  ],


                ),
              ),
            ),
            // Add pagination buttons here
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous page button
                ElevatedButton(
                  onPressed: (_currentPage == 0)
                      ? null
                      : () {
                    setState(() {
                      _currentPage--;
                      _updateDisplayedItems();
                    });
                  },
                  child: const Text('Prev'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey[300],
                  ),
                ),
                // Current page indicator
                Text('Page ${_currentPage + 1} of $_totalPages'),
                // Next page button
                ElevatedButton(
                  onPressed: (_currentPage == _totalPages - 1)
                      ? null
                      : () {
                    setState(() {
                      _currentPage++;
                      _updateDisplayedItems();
                    });
                  },
                  child: const Text('Next'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey[300],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _getCurrentLocation,
            child: const Text('near'),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () {
              // Handle button press
            },
            child: const Text('all'),
          ),
        ],
      ),

    );
  }


}








