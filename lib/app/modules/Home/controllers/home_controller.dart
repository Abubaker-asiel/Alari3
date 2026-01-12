import 'dart:math';
import 'package:alrai3/app/modules/Home/views/connect.dart';
import 'package:alrai3/app/modules/Home/views/log_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeController extends GetxController {
  @override
  void onInit() async {
    super.onInit();
    fetchSettings();
  }

  final List<String> userIds = [
    'JjXkhxNHt9fH75TyefV8SAkGJpl1',
    'ErimhgkALXNyeO6LprtAEsPapz13',
    'lPr8L9UXMnP4HMgFWZa44w8xC2c2',
  ];

  var isLoading = false.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController advanceController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Helper to replace Get.snackbar ---
  void _showSnackBar(String message, {bool isError = false}) {
    if (Get.context != null) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(fontFamily: 'Arial')),
          backgroundColor: isError ? Colors.redAccent : Colors.greenAccent[700],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
Stream<Map<String, dynamic>> fetchSettingsStream() {

  return _firestore.collection('settings')

      .doc('OwehizeKzoDUTPdEuoje')

      .snapshots()

      .map((docSnapshot) => docSnapshot.exists ? docSnapshot.data() ?? {} : {});

}
 Future<void> distributeDocuments(int day) async {
  DateTime now = DateTime.now();
  int currentMonth = now.month;

  try {
    // 1. Fetch all documents from the customers collection
    // Note: If your collection is very large (1000s of docs), 
    // consider adding a .where('visable', isEqualTo: true) to reduce the load.
    QuerySnapshot snapshot = await _firestore.collection('customers').get();

    // 2. Filter locally to match only the Day and the Current Month
    List<QueryDocumentSnapshot> allDocs = snapshot.docs.where((doc) {
      dynamic dateData = doc.get('date');
      DateTime? docDate;

      if (dateData is Timestamp) {
        docDate = dateData.toDate();
      } else if (dateData is String) {
        docDate = DateTime.tryParse(dateData);
      }

      // Check if the document's date matches the targeted Day and Month
      return docDate != null && 
             docDate.day == day && 
             docDate.month == currentMonth;
    }).toList();

    if (allDocs.isEmpty) {
      _showSnackBar('لا توجد مستندات لليوم $day في هذا الشهر.', isError: true);
      return;
    }

    // 3. Shuffle and Assign (Your existing logic)
    allDocs.shuffle(Random());
    List<String> shuffledUserIds = List.from(userIds)..shuffle(Random());
    
    Map<String, List<DocumentSnapshot>> assignedDocs = {};
    for (var user in shuffledUserIds) {
      assignedDocs[user] = [];
    }

    for (int i = 0; i < allDocs.length; i++) {
      String assignedUser = shuffledUserIds[i % shuffledUserIds.length];
      assignedDocs[assignedUser]?.add(allDocs[i]);
    }

    // 4. Batch Update
    WriteBatch batch = _firestore.batch();
    for (var user in assignedDocs.keys) {
      for (var doc in assignedDocs[user]!) {
        DocumentReference docRef = _firestore.collection('customers').doc(doc.id);
        batch.update(docRef, {'assignedTo': user, 'visable': true});
      }
    }

    await batch.commit();
    _showSnackBar('تم توزيع المستندات بنجاح.');

  } catch (e) {
    _showSnackBar('حدث خطأ أثناء التوزيع: $e', isError: true);
  }
}

  Future<void> saveCustomer(DateTime date) async {
    if (nameController.text.isEmpty ||
        numberController.text.isEmpty ||
        advanceController.text.isEmpty ||
        codeController.text.isEmpty) {
      _showSnackBar('يرجى ملء جميع الحقول!', isError: true);
      return;
    }

    try {
      isLoading.value = true;
      String assignedUser = userIds[Random().nextInt(userIds.length)];

      Map<String, dynamic> customerData = {
        'name': nameController.text,
        'number': numberController.text,
        'advance': advanceController.text,
        'code': codeController.text,
        'date': date,
        'timestamp': FieldValue.serverTimestamp(),
        'assignedTo': assignedUser,
        'visable': true
      };

      Map<String, dynamic> customerData2 = {
        'name': nameController.text,
        'number': numberController.text,
        'advance': advanceController.text,
        'code': codeController.text,
        'date': date,
        'timestamp': FieldValue.serverTimestamp(),
        'visable': true
      };

      await _firestore.collection('customers').add(customerData);
      await _firestore.collection('customers2').add(customerData2);

      _showSnackBar('تم حفظ بيانات العميل وتعيينه لمستخدم!');

      nameController.clear();
      numberController.clear();
      advanceController.clear();
      codeController.clear();
    } catch (e) {
      _showSnackBar('فشل حفظ بيانات العميل!', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    numberController.dispose();
    advanceController.dispose();
    codeController.dispose();
    super.onClose();
  }

  var emailController = TextEditingController().obs;
  var passwordController = TextEditingController().obs;
  var isLoading2 = false.obs;

  Future<void> login() async {
    isLoading2.value = true;
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.value.text.trim(),
        password: passwordController.value.text.trim(),
      );
      Get.off(Connect());
    } on FirebaseAuthException catch (e) {
      isLoading2.value = false;
      String errorMessage = 'حدث خطأ، حاول مرة أخرى.';
      if (e.code == 'user-not-found') {
        errorMessage = 'المستخدم غير موجود، تحقق من البريد الإلكتروني.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'كلمة المرور غير صحيحة، حاول مرة أخرى.';
      }
      _showSnackBar(errorMessage, isError: true);
    }
    emailController.value.clear();
    passwordController.value.clear();
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.offAll(LoginPage());
    } catch (e) {
      _showSnackBar('حدث خطأ أثناء تسجيل الخروج، حاول مرة أخرى.', isError: true);
    }
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri.parse('tel:$phoneNumber');
    if (!await launchUrl(phoneUri)) {
      throw 'لا يمكن تنفيذ المكالمة';
    }
  }

  var text1 = ''.obs;
  var text2 = ''.obs;
  var text3 = ''.obs;
  var text4 = ''.obs;

  void fetchSettings() async {
    DocumentSnapshot doc =
        await _firestore.collection('settings').doc('OwehizeKzoDUTPdEuoje').get();
    if (doc.exists) {
      text1.value = doc['text1'] ?? '';
      text2.value = doc['text2'] ?? '';
      text3.value = doc['text3'] ?? '';
      text4.value = doc['text4'] ?? '';
    }
  }

  void updateSetting(String field, int value) async {
    await _firestore.collection('settings').doc('OwehizeKzoDUTPdEuoje').update({
      field: value,
    });
    _showSnackBar('تم حفظ البيانات بنجاح!');
  }

  void updateTextField(String field, String value) async {
    await _firestore.collection('settings').doc('OwehizeKzoDUTPdEuoje').update({
      field: value,
    });
    _showSnackBar('تم ارسال الرسالة بنجاح!');
  }
}