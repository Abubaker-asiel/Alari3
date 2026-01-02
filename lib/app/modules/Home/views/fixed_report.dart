import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';


class ReportsPage2 extends StatefulWidget {
  const ReportsPage2({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ReportsPage2State createState() => _ReportsPage2State();
}

class _ReportsPage2State extends State<ReportsPage2> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int selectedDay = 1; // اليوم الافتراضي

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime targetDate = DateTime(now.year, 1, selectedDay);


    return Scaffold(
      appBar: AppBar(
        title: const Text('جميع العملاء', style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.pink.shade900,
      ),
      body: Column(
        children: [
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

Text(' تقرير عملاء يوم $selectedDay', style: TextStyle(fontSize: 20), ),
Expanded(
  child: StreamBuilder<QuerySnapshot>(
    stream: _firestore
        .collection('customers2')
        .where('date', isEqualTo: Timestamp.fromDate(targetDate))
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber_rounded, size: 80, color: Colors.orange),
              const SizedBox(height: 10),
              const Text(
                'لا توجد بيانات لهذا اليوم!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }

      var customers = snapshot.data!.docs;

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: customers.length,
        itemBuilder: (context, index) {
          var customer = customers[index];

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
                  _buildInfoRow(Icons.phone, 'رقم الهاتف:', customer['number']),
                  _buildInfoRow(Icons.attach_money, 'الدفعة المقدمة:', customer['advance']),
                  _buildInfoRow(Icons.qr_code, 'الكود:', customer['code']),
                  const Divider(thickness: 1),

                 
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await _firestore.collection('customers2').doc(customer.id).delete();
                        
                        // إظهار Snackbar باستخدام GetX
                        Get.snackbar(
                          'تم الحذف', 
                          'تم حذف ${customer['name']} بنجاح!',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                          borderRadius: 10,
                          margin: EdgeInsets.all(15),
                          snackStyle: SnackStyle.FLOATING,
                        );
                      },
                      icon: Icon(Icons.check_circle, color: Colors.white),
                      label: Text(
                        'حذف العميل',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
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
