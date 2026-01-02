
import 'package:alrai3/app/modules/Home/controllers/home_controller.dart';
import 'package:alrai3/app/modules/Home/views/day10.dart';
import 'package:alrai3/app/modules/Home/views/day15.dart';
import 'package:alrai3/app/modules/Home/views/day20.dart';
import 'package:alrai3/app/modules/Home/views/day25.dart';
import 'package:alrai3/app/modules/Home/views/day5.dart';
import 'package:alrai3/app/modules/Home/views/report_view.dart';
import 'package:alrai3/app/modules/Home/views/setting.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

   HomeView({super.key});

  @override
  Widget build(BuildContext context) {
       DateTime now = DateTime.now();
    return Directionality(
      textDirection: TextDirection.rtl, // جعل الرسالة من اليمين إلى اليسار
      child: Scaffold(
        appBar:AppBar(
     title: const Text('تفاصيل العميل', style: TextStyle(color: Colors.white),),
    centerTitle: true,
    backgroundColor: Colors.blue.shade900,
    actions: [
      // Settings Icon
      IconButton(
        onPressed: () {
          Get.to(() => SettingsPage());
        },
        icon: Icon(Icons.settings, color: Colors.white,),
      ),

      // Dropdown Menu Button
      PopupMenuButton<String>(
        icon: Icon(Icons.calendar_month_sharp, color: Colors.white),
        onSelected: (value) {
          // Navigate to the selected day
          if (value == "يوم 1") {
            Get.off(() => HomeView());
          } else if (value == "يوم 5") {
            Get.off(() => Day5());
          } else if (value == "يوم 10") {
            Get.off(() => Day10());
          } else if (value == "يوم 15") {
            Get.off(() => Day15());
          } else if (value == "يوم 20") {
            Get.off(() => Day20());
          } else if (value == "يوم 25") {
            Get.off(() => Day25());
          }
        },
        itemBuilder: (BuildContext context) {
          return [
            PopupMenuItem<String>(
              value: "يوم 1",
              child: Text("يوم 1", style: TextStyle(color: Colors.black)),
            ),
            PopupMenuItem<String>(
              value: "يوم 5",
              child: Text("يوم 5", style: TextStyle(color: Colors.black)),
            ),
            PopupMenuItem<String>(
              value: "يوم 10",
              child: Text("يوم 10", style: TextStyle(color: Colors.black)),
            ),
            PopupMenuItem<String>(
              value: "يوم 15",
              child: Text("يوم 15", style: TextStyle(color: Colors.black)),
            ),
            PopupMenuItem<String>(
              value: "يوم 20",
              child: Text("يوم 20", style: TextStyle(color: Colors.black)),
            ),
            PopupMenuItem<String>(
              value: "يوم 25",
              child: Text("يوم 25", style: TextStyle(color: Colors.black)),
            ),

          ];
        },
      ),

  
   IconButton(
        onPressed: () {
       Get.to(()=>ReportsPage());
        },
        icon: Icon(Icons.event_available_rounded, color: Colors.white,),
      ),


      
   IconButton(
        onPressed: () {
          controller.logout();
        },
        icon: Icon(Icons.logout, color: Colors.white,),
      ),





    ],),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  ' أدخل تفاصيل عميل يوم 1' ,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: controller.nameController,
                  label: 'الاسم',
                  hint: 'أدخل اسم العميل',
                  onChanged: (value) => controller.nameController.text = value,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller:controller.numberController ,
                  label: 'رقم الهاتف',
                  hint: 'أدخل رقم الهاتف',
                  keyboardType: TextInputType.phone,
                  onChanged: (value) => controller.numberController.text = value,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: controller.advanceController,
                  label: 'القسط الشهري',
                  hint: 'أدخل المبلغ ',
                  keyboardType: TextInputType.number,
                  onChanged: (value) => controller.advanceController.text = value,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: controller.codeController,
                  label: 'الكود',
                  hint: 'أدخل كود العميل',
                  onChanged: (value) => controller.codeController.text = value,
                ),
                const SizedBox(height: 30),
                Obx(() => ElevatedButton(
                      onPressed:(){

 controller.saveCustomer(DateTime(now.year, 1, 1));
                      } ,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade900,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'حفظ البيانات',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}