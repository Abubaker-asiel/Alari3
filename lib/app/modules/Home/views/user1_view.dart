import 'package:alrai3/app/modules/Home/controllers/home_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class User1Page extends StatefulWidget {
  const User1Page({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _User1PageState createState() => _User1PageState();
}

class _User1PageState extends State<User1Page> {
  HomeController controller = Get.put(HomeController());
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int selectedDay = 1;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المستخدم 1', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        actions: [
          IconButton(
            onPressed: () => controller.logout(),
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          // Day Selector
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

          // Main Data Stream
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('customers')
                  .where('assignedTo', isEqualTo: uid)
                  .where('visable', isEqualTo: true)
                  // We remove the specific date query here to handle filtering by "Day only" below
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                // --- FILTERING LOGIC BY DAY ---
                var allDocs = snapshot.data!.docs;
                var filteredCustomers = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  if (data['date'] == null) return false;
                  
                  DateTime docDate = (data['date'] as Timestamp).toDate();
                  return docDate.day == selectedDay; // Matches ONLY the day, ignores year/month
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
                            color: Colors.blue.shade900),
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
                                  _buildInfoRow(
                                      Icons.event_note,
                                      'التاريخ الكامل:',
                                      DateFormat('yyyy-MM-dd').format(customer['date'].toDate())),
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

          // Settings/Text Stream at the bottom
          StreamBuilder<Map<String, dynamic>>(
            stream: controller.fetchSettingsStream(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var data = snapshot.data!;
                controller.text1.value = data['text1'] ?? '';

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
                      controller.text1.value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return const SizedBox();
            },
          )
        ],
      ),
    );
  }

  // Helper widget for "No Data"
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

  Widget _buildPhoneRow(IconData icon, String label, String number) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade900),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade900),
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
}