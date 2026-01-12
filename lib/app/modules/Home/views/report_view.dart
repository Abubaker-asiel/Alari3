
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int selectedDay = 1; // اليوم الافتراضي
  String searchQuery = ''; // نص البحث

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 تقرير العملاء', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        actions: [
          IconButton(
            onPressed: () {
              // Note: Ensure ReportsPage2 exists or is correctly imported
              // Get.to(() => ReportsPage2()); 
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
                suffixIcon: const Icon(Icons.search),
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
                  // We remove the .where('date') query to filter by day regardless of year
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                // 🔹 Filter logic: Check both the Day AND the Search Query
                var filteredCustomers = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  
                  // 1. Day Check
                  if (data['date'] == null) return false;
                  DateTime docDate = (data['date'] as Timestamp).toDate();
                  bool matchesDay = docDate.day == selectedDay;

                  // 2. Search Check
                  String name = data['name']?.toString().toLowerCase() ?? '';
                  String number = data['number']?.toString() ?? '';
                  bool matchesSearch = name.contains(searchQuery) || number.contains(searchQuery);

                  return matchesDay && matchesSearch;
                }).toList();

                if (filteredCustomers.isEmpty) {
                  return _buildEmptyState();
                }

                int customerCount = filteredCustomers.length;

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
                          var customer = filteredCustomers[index];
                          var data = customer.data() as Map<String, dynamic>;

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
                                  _buildInfoRow(Icons.person, 'الاسم:', data['name'] ?? ''),
                                  _buildInfoRow(Icons.phone, 'رقم الهاتف:', data['number'] ?? ''),
                                  _buildInfoRow(Icons.attach_money, 'الدفعة المقدمة:', data['advance'] ?? ''),
                                  _buildInfoRow(Icons.qr_code, 'الكود:', data['code'] ?? ''),
                                  const Divider(thickness: 1),

                                  // 🔹 أزرار "تم الدفع" و "حذف العميل"
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Button only shows if customer is visible
                                      if (data['visable'] == true)
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            await _firestore.collection('customers').doc(customer.id).update({'visable': false});
                                            Get.snackbar(
                                              'تم', 'تم الدفع بنجاح!',
                                              snackPosition: SnackPosition.BOTTOM,
                                              backgroundColor: Colors.green,
                                              colorText: Colors.white,
                                            );
                                          },
                                          icon: const Icon(Icons.check_circle, color: Colors.white),
                                          label: const Text('تم الدفع', style: TextStyle(color: Colors.white)),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
                                        ),

                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          await _firestore.collection('customers').doc(customer.id).delete();
                                          Get.snackbar(
                                            'تم الحذف', 'تم الحذف بنجاح!',
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: Colors.red,
                                            colorText: Colors.white,
                                          );
                                        },
                                        icon: const Icon(Icons.delete, color: Colors.white),
                                        label: const Text('حذف', style: TextStyle(color: Colors.white)),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
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

  // Helper widget for empty results
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber_rounded, size: 80, color: Colors.orange),
          SizedBox(height: 10),
          Text('لا توجد بيانات لهذه التصفية!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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