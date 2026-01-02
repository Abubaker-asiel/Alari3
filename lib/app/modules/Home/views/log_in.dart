// ignore_for_file: deprecated_member_use

import 'package:alrai3/app/modules/Home/controllers/home_controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

   LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.orange, Colors.purple],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // App Logo
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Icon(
                        Icons.account_circle,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
                    // Email TextField
                    _buildTextField(
                      controller: controller.emailController.value,
                      hintText: "ادخل الايميل",
                      icon: Icons.email,
                      obscureText: false,
                    ),
                    SizedBox(height: 20),
                    // Password TextField
                    _buildTextField(
                      controller: controller.passwordController.value,
                      hintText: "ادخل كلمة السر",
                      icon: Icons.lock,
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                    // Login Button
                    Obx(() {
                      return controller.isLoading.value
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: controller.login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purpleAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 80,
                                  vertical: 15,
                                ),
                              ),
                              child: Text(
                                "دخول",
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            );
                    }),
                  
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required bool obscureText,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white70),
        prefixIcon: Icon(
          icon,
          color: Colors.white,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      ),
    );
  }
}
