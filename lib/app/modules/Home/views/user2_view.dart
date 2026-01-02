import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/home_controller.dart';

class User2Page extends StatefulWidget {
  const User2Page({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _User2PageState createState() => _User2PageState();
}

class _User2PageState extends State<User2Page> {
  HomeController controller = Get.put(HomeController());
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int selectedDay = 1;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المستخدم 2', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.teal.shade900,
        actions: [
          IconButton(
            onPressed: () => controller.logout(),
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          // Day Selection UI
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'اختر اليوم:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                DropdownButton<int>(
                  value: selectedDay,
                  items: [1, 5, 10, 15, 20, 25].map((day) {
                    return DropdownMenuItem(
                      value: day,
                      child: Text(' يوم  $day'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDay = value!;
                    });
                  },
                ),
              ],
            ),
          ),

          // Customer List with Year-Independent Filter
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('customers')
                  .where('assignedTo', isEqualTo: uid)
                  .where('visable', isEqualTo: true)
                  // We fetch all visible customers for this user 
                  // and filter by day locally to ignore the year.
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                // Filtering the list based on the day only
                var filteredCustomers = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  if (data['date'] == null) return false;
                  DateTime docDate = (data['date'] as Timestamp).toDate();
                  return docDate.day == selectedDay;
                }).toList();

                if (filteredCustomers.isEmpty) {
                  return _buildEmptyState();
                }

                int customerCount = filteredCustomers.length;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'عدد العملاء: $customerCount',
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.teal.shade900
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: customerCount,
                        itemBuilder: (context, index) {
                          var customer = filteredCustomers[index];

                          return Card(
                            elevation: 5,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow(Icons.person, 'الاسم:', customer['name']),
                                  _buildPhoneRow(Icons.phone, 'رقم الهاتف:', customer['number']),
                                  _buildInfoRow(Icons.attach_money, 'الدفعة المقدمة:', customer['advance']),
                                  _buildInfoRow(Icons.qr_code, 'الكود:', customer['code']),
                                  const Divider(thickness: 1),
                                  // Showing the day extracted from the saved date
                                  _buildInfoRow(
                                    Icons.event_note, 
                                    'اليوم:', 
                                    DateFormat('d').format((customer['date'] as Timestamp).toDate())
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Bottom Settings Text (Text2)
          StreamBuilder<Map<String, dynamic>>(
            stream: controller.fetchSettingsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox();
              }

              if (snapshot.hasData) {
                var data = snapshot.data!;
                controller.text2.value = data['text2'] ?? '';

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.grey[200],
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      controller.text2.value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              } else {
                return const SizedBox();
              }
            },
          )
        ],
      ),
    );
  }

  // Helper for "No Data" UI
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.warning_amber_rounded, size: 80, color: Colors.orange),
          SizedBox(height: 10),
          Text(
            'لا توجد بيانات لهذا اليوم!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal.shade900),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneRow(IconData icon, String label, String number) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal.shade900),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => controller.makePhoneCall(number),
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}