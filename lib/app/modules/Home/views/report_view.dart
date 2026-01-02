import 'package:alrai3/app/modules/Home/views/fixed_report.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int selectedDay = 1; // اليوم الافتراضي
  String searchQuery = ''; // 🔹 نص البحث

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime targetDate = DateTime(now.year, 1, selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 تقرير العملاء', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => ReportsPage2());
            },
            icon: const Icon(Icons.people, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔹 اختيار اليوم
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('اختر اليوم:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                DropdownButton<int>(
                  value: selectedDay,
                  items: [1, 5, 10, 15, 20, 25].map((day) {
                    return DropdownMenuItem(
                      value: day,
                      child: Text(' يوم $day'),
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

          // 🔹 شريط البحث
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                labelText: '🔍 ابحث عن عميل',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          const SizedBox(height: 10),

          // 🔹 نص يوضح اليوم المختار
          Text(' تقرير عملاء يوم $selectedDay', style: const TextStyle(fontSize: 20)),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('customers')
                  .where('date', isEqualTo: Timestamp.fromDate(targetDate))
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 80, color: Colors.orange),
                        SizedBox(height: 10),
                        Text('لا توجد بيانات لهذا اليوم!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }

                var customers = snapshot.data!.docs
                    .where((doc) =>
                        doc['name'].toString().toLowerCase().contains(searchQuery) ||
                        doc['number'].toString().contains(searchQuery))
                    .toList(); // 🔹 تطبيق الفلترة بالبحث

                int customerCount = customers.length; // 🔹 عدد العملاء

                return Column(
                  children: [
                    // 🔹 عرض عدد العملاء
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'عدد العملاء: $customerCount',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                      ),
                    ),

                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: customerCount,
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

                                  // 🔹 أزرار "تم الدفع" و "حذف العميل"
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (customer['visable'])
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            await _firestore.collection('customers').doc(customer.id).update({'visable': false});

                                            // إظهار Snackbar باستخدام GetX
                                            Get.snackbar(
                                              'تم', 'تم الدفع بنجاح!',
                                              snackPosition: SnackPosition.BOTTOM,
                                              backgroundColor: Colors.green,
                                              colorText: Colors.white,
                                              borderRadius: 10,
                                              margin: const EdgeInsets.all(15),
                                              snackStyle: SnackStyle.FLOATING,
                                            );
                                          },
                                          icon: const Icon(Icons.check_circle, color: Colors.white),
                                          label: const Text('تم الدفع', style: TextStyle(color: Colors.white)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.greenAccent,
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          ),
                                        ),

                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          await _firestore.collection('customers').doc(customer.id).delete();

                                          // إظهار Snackbar باستخدام GetX
                                          Get.snackbar(
                                            'تم الحذف', 'تم حذف ${customer['name']} بنجاح!',
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                            borderRadius: 10,
                                            margin: const EdgeInsets.all(15),
                                            snackStyle: SnackStyle.FLOATING,
                                          );
                                        },
                                        icon: const Icon(Icons.delete, color: Colors.white),
                                        label: const Text('حذف العميل', style: TextStyle(color: Colors.white)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.redAccent,
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        ),
                                      ),
                                    ],
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
        ],
      ),
    );
  }

  // 🔹 دالة بناء صف بيانات العميل
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade900),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 16), overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
