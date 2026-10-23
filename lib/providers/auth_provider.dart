// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class AuthProvider extends ChangeNotifier {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Standard konstruktor o'rniga oddiy konstruktor ishlatiladi
//   final GoogleSignIn _googleSignIn = GoogleSignIn();

//   User? get currentUser => _auth.currentUser;
//   String? role;
//   String? studentId;
//   bool isLoading = false;

  
//  // Hisobni o'chirish metodi
//   Future<void> deleteAccount() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         await user.delete();
//         notifyListeners();
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }
// // Bitta telefon raqam uchun 5 ta akkaunt limitini tekshirib ro'yxatdan o'tkazish
//   Future<String?> registerWithPhoneLimit({
//     required String email,
//     required String password,
//     required String phone,
//     required String name,
//     required String role,
//   }) async {
//     try {
//       // 1. Shu telefon raqamiga ulangan akkauntlar sonini Firestore'dan tekshiramiz
//       final querySnapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .where('phone', isEqualTo: phone)
//           .get();

//       if (querySnapshot.docs.length >= 5) {
//         return "Bu telefon raqamiga allaqachon 5 ta akkaunt ochilgan. Limit tugagan!";
//       }

//       // 2. Firebase Auth orqali yangi foydalanuvchi yaratish
//       UserCredential credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       // 3. Foydalanuvchi ma'lumotlarini Firestore'ga saqlash
//       await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
//         'uid': credential.user!.uid,
//         'name': name,
//         'email': email,
//         'phone': phone,
//         'role': role,
//         'createdAt': FieldValue.serverTimestamp(),
//       });

//       notifyListeners();
//       return null; // Xatolik yo'q
//     } on FirebaseAuthException catch (e) {
//       return e.message;
//     } catch (e) {
//       return "Xatolik yuz berdi: $e";
//     }
//   }

//   // 1. Email va Parol orqali kirish (signInWithEmail)
//   Future<UserCredential?> signInWithEmail(String email, String password) async {
//     isLoading = true;
//     notifyListeners();

//     try {
//       final creds = await _auth.signInWithEmailAndPassword(
//         email: email.trim(),
//         password: password.trim(),
//       );
//       await fetchUserData(creds.user!.uid);
//       isLoading = false;
//       notifyListeners();
//       return creds;
//     } catch (e) {
//       isLoading = false;
//       notifyListeners();
//       rethrow;
//     }
//   }

//   // 2. Email va Parol orqali ro'yxatdan o'tish (signUpWithEmail)
//   Future<UserCredential?> signUpWithEmail({
//     required String email,
//     required String password,
//     required String name,
//     required String role,
//   }) async {
//     isLoading = true;
//     notifyListeners();

//     try {
//       final creds = await _auth.createUserWithEmailAndPassword(
//         email: email.trim(),
//         password: password.trim(),
//       );

//       if (creds.user != null) {
//         await creds.user!.updateDisplayName(name.trim());
//         await setUserRoleAndGenerateId(
//           role,
//           uid: creds.user!.uid,
//           email: email,
//           name: name,
//         );
//       }

//       isLoading = false;
//       notifyListeners();
//       return creds;
//     } catch (e) {
//       isLoading = false;
//       notifyListeners();
//       rethrow;
//     }
//   }

//   // 3. Google hisobini almashtirish (switchGoogleAccount)
//   Future<UserCredential?> switchGoogleAccount() async {
//     await _googleSignIn.signOut();
//     return await signInWithGoogle();
//   }

//   // 4. Google bilan kirish (signInWithGoogle)
//   Future<UserCredential?> signInWithGoogle({String? role}) async {
//     isLoading = true;
//     notifyListeners();

//     try {
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) {
//         isLoading = false;
//         notifyListeners();
//         return null;
//       }

//       // unnecessary_nullable_for_final_variable_declarations tuzatildi
//       final GoogleSignInAuthentication googleAuth =
//           await googleUser.authentication;

//       final OAuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       final UserCredential userCredential = await _auth.signInWithCredential(
//         credential,
//       );

//       if (role != null) {
//         await setUserRoleAndGenerateId(role, uid: userCredential.user!.uid);
//       } else {
//         await fetchUserData(userCredential.user!.uid);
//       }

//       isLoading = false;
//       notifyListeners();
//       return userCredential;
//     } catch (e) {
//       isLoading = false;
//       notifyListeners();
//       rethrow;
//     }
//   }

//   // Firestore ma'lumotlarini yuklash va lokal holatda saqlash
//   Future<void> fetchUserData(String uid) async {
//     final doc = await _firestore.collection('users').doc(uid).get();
//     if (doc.exists) {
//       role = doc.data()?['role'];
//       studentId = doc.data()?['studentId'];
//       notifyListeners();
//     }
//   }

//   // Rol va Student ID'ni Firestore'ga doimiy saqlash
//   Future<void> setUserRoleAndGenerateId(
//     String roleType, {
//     String? uid,
//     String? email,
//     String? name,
//   }) async {
//     final userId = uid ?? _auth.currentUser?.uid;
//     if (userId == null) return;

//     role = roleType;
//     if (roleType == 'student') {
//       studentId = (100000 + Random().nextInt(900000)).toString();
//     } else {
//       studentId = null;
//     }

//     // Ma'lumotlar Cloud Firestore ma'lumotlar bazasida doimiy saqlanadi
//     await _firestore.collection('users').doc(userId).set({
//       'uid': userId,
//       'name': name ?? _auth.currentUser?.displayName ?? 'Foydalanuvchi',
//       'email': email ?? _auth.currentUser?.email,
//       'role': roleType,
//       'studentId': studentId,
//       'updatedAt': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));

//     notifyListeners();
//   }

//   // Foydalanuvchi ma'lumotlarini saqlash yoki olish paytida unique ID yaratish:
//   String generateUserCode() {
//     final random = Random();
//     return 'V-${100000 + random.nextInt(900000)}'; // Masalan: V-485920
//   }

//   // Tizimdan chiqish (signOut)
//   Future<void> signOut() async {
//     await _googleSignIn.signOut();
//     await _auth.signOut();
//     role = null;
//     studentId = null;
//     notifyListeners();
//   }
// }



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser = FirebaseAuth.instance.currentUser;
  String? _role;
  String? _studentId;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  String? get role => _role;
  String? get studentId => _studentId;
  bool get isLoading => _isLoading;

  AuthProvider() {
    // Foydalanuvchi holatini kuzatib borish
    FirebaseAuth.instance.authStateChanges().listen((user) {
      _currentUser = user;
      if (user != null) {
        fetchUserData(user.uid);
      } else {
        _role = null;
        _studentId = null;
        notifyListeners();
      }
    });
  }

  // 1. Foydalanuvchi ma'lumotlarini Firestore'dan yuklash
  Future<void> fetchUserData(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        _role = data?['role'];
        _studentId = data?['studentId'] ?? uid.substring(0, 6).toUpperCase();
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print("Foydalanuvchi ma'lumotlarini olishda xatolik: $e");
    }
  }

  // 2. Rolni o'rnatish va ID generatsiya qilish
  Future<void> setUserRoleAndGenerateId(String selectedRole) async {
    if (_currentUser == null) return;
    try {
      _role = selectedRole;
      _studentId = _currentUser!.uid.substring(0, 6).toUpperCase();

      await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).set({
        'role': _role,
        'studentId': _studentId,
        'email': _currentUser!.email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("Rolni saqlashda xatolik: $e");
    }
  }

  // 3. Telefon raqami va 5 talik limit bilan ro'yxatdan o'tish
  Future<String?> registerWithPhoneLimit({
    required String email,
    required String password,
    required String phone,
    required String name,
    required String role,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phone)
          .get();

      if (querySnapshot.docs.length >= 5) {
        _isLoading = false;
        notifyListeners();
        return "Bu telefon raqamiga allaqachon 5 ta akkaunt ochilgan!";
      }

      UserCredential credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _currentUser = credential.user;
      _role = role;
      _studentId = _currentUser!.uid.substring(0, 6).toUpperCase();

      await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).set({
        'uid': _currentUser!.uid,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'studentId': _studentId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return "Xatolik: $e";
    }
  }

  // 4. Email va Parol bilan kirish
  Future<void> signInWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      UserCredential credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _currentUser = credential.user;
      if (_currentUser != null) {
        await fetchUserData(_currentUser!.uid);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 5. Google orqali kirish (Simulyatsiya yoki asosiy funksiya)
  Future<void> signInWithGoogle() async {
    // Agar Google Sign-In ishlatilsa shu yerga yoziladi
    notifyListeners();
  }

  // 6. Hisobdan chiqish (Sign Out)
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    _currentUser = null;
    _role = null;
    _studentId = null;
    notifyListeners();
  }

  // 7. Hisobni o'chirish (Delete Account)
  Future<void> deleteAccount() async {
    try {
      if (_currentUser != null) {
        await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).delete();
        await _currentUser!.delete();
        _currentUser = null;
        _role = null;
        _studentId = null;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  // 8. Telefon raqami bo'yicha mavjud akkauntlarni olish
  Future<List<Map<String, dynamic>>> getAccountsByPhone(String phone) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phone)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      return [];
    }
  }
}