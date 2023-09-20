import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});
  static const route = '/notification';

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: const EdgeInsets.only(top: 20.0),
        itemCount: 2,
        itemBuilder: (context, index) {
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
                              const Text(
                                "Bin has reached max capacity",
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                "24 May 2023 (14:30 Hrs.)",
                                style: TextStyle(
                                    color: Colors.grey.shade700, fontSize: 15),
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        "A bin at AU Mall has reached max capacity, please collect the waste.",
                        style: TextStyle(
                            color: Colors.grey.shade700, fontSize: 15),
                      ),
                    ]),
              ),
            ),
          );
        });
  }
}
