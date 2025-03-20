import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:task_reminder/services/notificationservice.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  @override
  void initState() {
    super.initState();
    loadScheduledNotifications();
  }

  var dateTime = DateTime.now().obs;
  var schedule = DateTime.now().obs;
  var time = TimeOfDay.fromDateTime(DateTime.now()).obs;

  final TextEditingController title = TextEditingController();
  final TextEditingController desc = TextEditingController();

  final NotificationService notificationService = NotificationService();

  var notifications = <Map<String, dynamic>>[].obs;

  void addNotification() {
    Map<String, dynamic> newNotification = {
      "id": schedule.value.millisecondsSinceEpoch ~/ 1000,
      "title": title.text,
      "description": desc.text,
      "time": schedule.value.toIso8601String(),
    };
    notifications.add(newNotification);
    saveScheduledNotifications();
  }

  Future<void> saveScheduledNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('scheduled_notifications', jsonEncode(notifications));
  }

  // Future<void> saveNotifications() async {
  // final prefs = await SharedPreferences.getInstance();
  // await prefs.setString('scheduled_notifications', jsonEncode(notifications));
  // } 

  Future<void> loadScheduledNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedData = prefs.getString('scheduled_notifications');

    if (storedData != null) {
      notifications.value = List<Map<String, dynamic>>.from(
        jsonDecode(storedData),
      );

      // Reschedule all saved notifications
      for (var notification in notifications) {
        DateTime scheduledTime = DateTime.parse(notification['time']);
        notificationService.scheduleNotification(
          notification['id'],
          notification['title'],
          notification['description'],
          scheduledTime,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double x = MediaQuery.of(context).size.width;
    double y = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: y * 0.02),

            //details card
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  margin: EdgeInsets.all(10),
                  clipBehavior: Clip.hardEdge,
                  child: Column(
                    children: [
                      //title
                      Container(
                        width: x * 0.8,
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: TextField(
                          controller: title,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            hintText: 'Title',
                          ),
                        ),
                      ),

                      //description
                      Container(
                        width: x * 0.8,
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: TextField(
                          controller: desc,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            label: Text("Description"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            //data and time card
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.all(0),
                  width: x * 0.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //date
                      Container(
                        margin: EdgeInsets.all(10),
                        width: x * 0.35,
                        height: x * 0.35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Card(
                          clipBehavior: Clip.hardEdge,
                          child: InkWell(
                            onTap: () async {
                              final DateTime? newlySelectedDate =
                                  await showDatePicker(
                                    context: context,
                                    initialDate: dateTime.value,
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2095),
                                  );

                              if (newlySelectedDate == null) {
                                return;
                              } else {
                                dateTime.value = newlySelectedDate;
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Text("Date"),
                                  SizedBox(height: 10),
                                  Icon(Icons.date_range),
                                  SizedBox(height: 10),
                                  Obx(
                                    () => Text(
                                      "${dateTime.value.year}/${dateTime.value.month}/${dateTime.value.day}",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      //time
                      Container(
                        margin: EdgeInsets.all(10),
                        width: x * 0.35,
                        height: x * 0.35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Card(
                          clipBehavior: Clip.hardEdge,
                          child: InkWell(
                            onTap: () async {
                              final TimeOfDay? slectedTime =
                                  await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );

                              if (slectedTime == null) {
                                return;
                              } else {
                                time.value = slectedTime;
                              }

                              DateTime newDT = DateTime(
                                dateTime.value.year,
                                dateTime.value.month,
                                dateTime.value.day,
                                slectedTime.hour,
                                slectedTime.minute,
                              );

                              schedule.value = newDT;
                            },
                            child: Container(
                              margin: EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Text("Time"),
                                  SizedBox(height: 10),
                                  Icon(Icons.timer_outlined),
                                  SizedBox(height: 10),
                                  Obx(
                                    () => Text(
                                      "${time.value.hour}:${time.value.minute}",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            //schedule button
            Container(
              margin: EdgeInsets.all(5),
              width: x * 0.8,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(2)),
              child: ElevatedButton(
                onPressed: () {
                  if (title.text.isEmpty || desc.text.isEmpty) {
                    return;
                  } else {
                    notificationService.scheduleNotification(
                      schedule.value.millisecondsSinceEpoch ~/ 1000,
                      title.text.toString(),
                      desc.text.toString(),
                      schedule.value,
                    );
                    addNotification();
                    FocusScope.of(context).unfocus();
                    title.clear();
                    desc.clear();
                  }
                },
                child: Text("Click to Schedule"),
              ),
            ),

            //task list
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final item = notifications[index];
                    return Card(
                      child: ListTile(
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            notifications.removeAt(
                              index,
                            ); 
                            // saveNotifications();
                            saveScheduledNotifications();
                          },
                        ),
                        title: Text(
                          item["title"],
                          style: TextStyle(fontSize: 20),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item["description"],
                              style: TextStyle(fontSize: 15),
                            ),
                            Text(
                              DateFormat(
                                'hh:mm a',
                              ).format(DateTime.parse(item["time"])),
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
