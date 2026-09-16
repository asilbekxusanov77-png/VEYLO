import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Standard konstruktor o'rniga oddiy konstruktor ishlatiladi
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  String? role;
  String? studentId;
  bool isLoading = false;

  // 1. Email va Parol orqali kirish (signInWithEmail)
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      final creds = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      await fetchUserData(creds.user!.uid);
      isLoading = false;
      notifyListeners();
      return creds;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // 2. Email va Parol orqali ro'yxatdan o'tish (signUpWithEmail)
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final creds = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (creds.user != null) {
        await creds.user!.updateDisplayName(name.trim());
        await setUserRoleAndGenerateId(
          role,
          uid: creds.user!.uid,
          email: email,
          name: name,
        );
      }

      isLoading = false;
      notifyListeners();
      return creds;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // 3. Google hisobini almashtirish (switchGoogleAccount)
  Future<UserCredential?> switchGoogleAccount() async {
    await _googleSignIn.signOut();
    return await signInWithGoogle();
  }

  // 4. Google bilan kirish (signInWithGoogle)
  Future<UserCredential?> signInWithGoogle({String? role}) async {
    isLoading = true;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isLoading = false;
        notifyListeners();
        return null;
      }

      // unnecessary_nullable_for_final_variable_declarations tuzatildi
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      if (role != null) {
        await setUserRoleAndGenerateId(role, uid: userCredential.user!.uid);
      } else {
        await fetchUserData(userCredential.user!.uid);
      }

      isLoading = false;
      notifyListeners();
      return userCredential;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Firestore ma'lumotlarini yuklash va lokal holatda saqlash
  Future<void> fetchUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      role = doc.data()?['role'];
      studentId = doc.data()?['studentId'];
      notifyListeners();
    }
  }

  // Rol va Student ID'ni Firestore'ga doimiy saqlash
  Future<void> setUserRoleAndGenerateId(
    String roleType, {
    String? uid,
    String? email,
    String? name,
  }) async {
    final userId = uid ?? _auth.currentUser?.uid;
    if (userId == null) return;

    role = roleType;
    if (roleType == 'student') {
      studentId = (100000 + Random().nextInt(900000)).toString();
    } else {
      studentId = null;
    }

    // Ma'lumotlar Cloud Firestore ma'lumotlar bazasida doimiy saqlanadi
    await _firestore.collection('users').doc(userId).set({
      'uid': userId,
      'name': name ?? _auth.currentUser?.displayName ?? 'Foydalanuvchi',
      'email': email ?? _auth.currentUser?.email,
      'role': roleType,
      'studentId': studentId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    notifyListeners();
  }

  // Tizimdan chiqish (signOut)
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    role = null;
    studentId = null;
    notifyListeners();
  }
}