import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_bins_flutter/models/bin_model.dart';

class BinScreen extends StatefulWidget {
  const BinScreen({super.key});

  @override
  State<BinScreen> createState() => _BinScreenState();
}

class _BinScreenState extends State<BinScreen> {
  List<Bin> binData = [];

  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  final List<int> colorCodes = <int>[600, 500, 100];

  @override
  void initState() {
    super.initState();
    _activateListeners();
  }

  String timestampToDate(int? timestamp) {
    var dt = DateTime.fromMillisecondsSinceEpoch(timestamp!);
    var date = DateFormat('MM/dd/yyyy, HH:mm').format(dt);

    return date.toString();
  }

  void _activateListeners() {
    _database.child("bins").onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<Object?, Object?>?;
      if (data != null && mounted) {
        setState(() {
          binData = data.entries.map((e) {
            final value = e.value as Map<Object?, Object?>;
            final name = value['name'] as String? ?? "";
            final volume = value['capacity'] is num
                ? (value['capacity'] as num).toDouble()
                : 0.0; // Handle null or non-double values
            final timestamp =
                value['timeEdited'] is num ? (value['timeEdited'] as int) : 0;
            return Bin(name: name, volume: volume, timestamp: timestamp);
          }).toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bins Status')),
      body: ListView.builder(
          itemCount: binData.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 6.0),
              child: Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(18.0),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        binData[index].name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 22.0),
                      ),
                      Text.rich(
                        TextSpan(children: [
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Icon(
                              Icons.info,
                              color: binData[index].volume >= 9
                                  ? Colors.red[600]
                                  : binData[index].volume >= 6
                                      ? Colors.yellow[800]
                                      : Colors.green[600],
                            ),
                          ),
                          const WidgetSpan(
                            child: SizedBox(width: 5),
                          ),
                          TextSpan(
                            text: binData[index].volume >= 9
                                ? "Totally Full"
                                : binData[index].volume >= 6
                                    ? "Almost Full"
                                    : "Clear",
                            style: TextStyle(
                                color: binData[index].volume >= 9
                                    ? Colors.red[600]
                                    : binData[index].volume >= 6
                                        ? Colors.yellow[800]
                                        : Colors.green[600]),
                          ),
                        ]),
                      )
                    ],
                  ),
                  minVerticalPadding: 2.0,
                  subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Capacity: ${binData[index].volume <= 12 ? ((binData[index].volume / 12) * 100).round() : '100'}%',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                        Text(
                          'Last Updated: ${timestampToDate(binData[index].timestamp)} Hrs.',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ]),
                ),
              ),
            );
          }),
    );
  }
}
