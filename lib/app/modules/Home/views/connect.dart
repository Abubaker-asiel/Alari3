import 'package:alrai3/app/modules/Home/views/home_view.dart';
import 'package:alrai3/app/modules/Home/views/log_in.dart';
import 'package:alrai3/app/modules/Home/views/user1_view.dart';
import 'package:alrai3/app/modules/Home/views/user2_view.dart';
import 'package:alrai3/app/modules/Home/views/user3_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as b;

class Connect extends StatelessWidget {
  const Connect({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<b.User?>(
      stream: b.FirebaseAuth.instance.authStateChanges(), // 🔹 متابعة تغييرات تسجيل الدخول والخروج
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // 🔹 عرض لودينغ أثناء تحميل البيانات
        }

        b.User? user = snapshot.data;

        if (user == null) {
          return LoginPage(); // 🔹 إعادة التوجيه إلى تسجيل الدخول إذا لم يكن هناك مستخدم مسجل
        }

        // 🔹 تحديد الصفحة بناءً على `UID`
        switch (user.uid) {
          case 'BZkHIV895Rad9XqitE5YU4QQ7l23':
            return HomeView();
          case 'JjXkhxNHt9fH75TyefV8SAkGJpl1':
            return const User1Page();
          case 'ErimhgkALXNyeO6LprtAEsPapz13':
            return const User2Page();
          case 'lPr8L9UXMnP4HMgFWZa44w8xC2c2':
            return User3Page();
          // case 'k841L600NUhwdw8894gvwjIlgPA3':
          //   return User4Page();
          default:
            return LoginPage(); // 🔹 إذا كان UID غير معروف، يتم إرجاعه إلى تسجيل الدخول
        }
      },
    );
  }
}
