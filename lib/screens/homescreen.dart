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

  //add notification to map
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

  //store scheduled notifications
  Future<void> saveScheduledNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('scheduled_notifications', jsonEncode(notifications));
  }

  //get store scheduled notifications
  Future<void> loadScheduledNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedData = prefs.getString('scheduled_notifications');

    if (storedData != null) {
      notifications.value = List<Map<String, dynamic>>.from(
        jsonDecode(storedData),
      );

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
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.greenAccent,
                Colors.white
              ],
            ),
          ),
          child: Column(
            children: [
              
              //welcome text
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.all(10),
                    child: Text(
                      "Welcome to Task Reminder",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    ),
                  ),
                ],
              ),
              
              //details card
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    color: Colors.greenAccent,
                    elevation: 4,
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
                                borderRadius: BorderRadius.circular(12),
                              ),
                              hintText: 'Add Your Title Here',
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
                                borderRadius: BorderRadius.circular(12),
                              ),
                              label: Text("Add Your Description Here"),
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
                    child: Card(
                      color: Colors.greenAccent,
                      elevation: 4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //date
                          Container(
                            margin: EdgeInsets.all(10),
                            width: x * 0.3,
                            height: x * 0.3,
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
                            width: x * 0.3,
                            height: x * 0.3,
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
                  ),
                ],
              ),
          
              SizedBox(height: 10),
              //schedule button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // shape: RoundedRectangleBorder(
                  //   borderRadius: BorderRadius.circular(100),
                  // ),
                  minimumSize: Size(150, 60),
                  shape: CircleBorder(),
                  elevation: 2,
                ),
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
                // child: Text("+", style: TextStyle(color: Colors.black),),
                child: Icon(Icons.add, size: 30),
              ),
              SizedBox(height: 10),

              //task list
              Expanded(
                child: Obx(
                  () => ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                        child: Card(
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
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
