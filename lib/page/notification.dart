import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});
  static const route = '/notification';

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> notificationsStream;

  @override
  void initState() {
    super.initState();
    // Initialize the stream to fetch documents from the "notifications" collection
    notificationsStream = _firestore.collection("notifications").snapshots();
  }

  String timestampToDate(int timestamp) {
    var dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var date = DateFormat('MM/dd/yyyy, HH:mm').format(dt);

    return date.toString();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: notificationsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While waiting for data, display a loading indicator
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // If there's an error, display an error message
          return Text('Error: ${snapshot.error}');
        } else {
          // If data is available, build the ListView
          final notifications = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.only(top: 20.0),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              // Extract data from the document snapshot
              final data = notifications[index].data() as Map<String, dynamic>;

              return Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 6.0),
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(18.0),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.error,
                              color: Colors.red.shade800,
                              size: 46.0,
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['title'] ?? '',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  timestampToDate(data['timestamp']) ?? '',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Text(
                          data['content'] ?? '',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return ListView.builder(
  //     padding: const EdgeInsets.only(top: 20.0),
  //     itemCount: 2,
  //     itemBuilder: (context, index) {
  //       return Padding(
  //         padding: const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 6.0),
  //         child: Card(
  //           child: ListTile(
  //             contentPadding: const EdgeInsets.all(18.0),
  //             title: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Row(
  //                     children: [
  //                       Icon(
  //                         Icons.error,
  //                         color: Colors.red.shade800,
  //                         size: 46.0,
  //                       ),
  //                       const SizedBox(
  //                         width: 15,
  //                       ),
  //                       Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           const Text(
  //                             "Bin has reached max capacity",
  //                             style: TextStyle(
  //                                 fontSize: 17, fontWeight: FontWeight.w500),
  //                           ),
  //                           Text(
  //                             "24 May 2023 (14:30 Hrs.)",
  //                             style: TextStyle(
  //                                 color: Colors.grey.shade700, fontSize: 15),
  //                           ),
  //                         ],
  //                       )
  //                     ],
  //                   ),
  //                   const SizedBox(
  //                     height: 12,
  //                   ),
  //                   Text(
  //                     "A bin at AU Mall has reached max capacity, please collect the waste.",
  //                     style:
  //                         TextStyle(color: Colors.grey.shade700, fontSize: 15),
  //                   ),
  //                 ]),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
}
