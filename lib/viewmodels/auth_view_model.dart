import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  User? _user;
  bool _loading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get loading => _loading;
  String? get errorMessage => _errorMessage;

  final AuthService _authService = AuthService();

  Future<void> login(String email, String password) async {
    _setLoading(true);
    _setErrorMessage(null);

    final response = await _authService.login(email, password);
    if (response['success']) {
      _user = User.fromJson(response['data']);
      await _authService.saveUser(_user!);  // Guardar el token JWT
      print('Login exitoso: ${_user!.name}');  // Mensaje de éxito en consola de Flutter
    } else {
      _setErrorMessage(response['message']);
      print('Error en Flutter (login): ${response['message']}');  // Mensaje de error en consola de Flutter
    }

    _setLoading(false);
  }

  Future<void> register(String name, String email, String password) async {
    _setLoading(true);
    _setErrorMessage(null);

    final response = await _authService.register(name, email, password);
    if (response['success']) {
      _user = User.fromJson(response['data']);
      await _authService.saveUser(_user!);  // Guardar el token JWT
      print('Registro exitoso: ${_user!.name}');  // Mensaje de éxito en consola de Flutter
    } else {
      _setErrorMessage(response['message']);
      print('Error en Flutter (register): ${response['message']}');  // Mensaje de error en consola de Flutter
    }

    _setLoading(false);
  }

  Future<void> checkSession() async {
    _loading=true;
    notifyListeners();
    final User? user = await _authService.getUser();
    if (user != null) {
      _user = user;
    }
    _loading=false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.removeUser();
    _user = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
}
