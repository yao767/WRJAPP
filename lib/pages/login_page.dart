import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userController = TextEditingController();
  final _pwdController = TextEditingController();
  bool _isLoginMode = true;
  bool _loading = false;

  @override
  void dispose() {
    _userController.dispose();
    _pwdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _userController.text.trim();
    final password = _pwdController.text.trim();
    if (username.isEmpty || password.length < 4) {
      _show('请输入用户名，密码至少4位');
      return;
    }

    setState(() => _loading = true);
    final appState = context.read<AppState>();
    if (_isLoginMode) {
      final ok = await appState.login(username, password);
      if (!mounted) return;
      _show(ok ? '登录成功' : '用户名或密码错误');
    } else {
      final registered = await appState.register(username, password);
      if (!mounted) return;
      if (!registered) {
        _show('该用户名已存在');
      } else {
        final ok = await appState.login(username, password);
        if (!mounted) return;
        _show(ok ? '注册并登录成功' : '注册成功，请重试登录');
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.agriculture, size: 56),
                  const SizedBox(height: 12),
                  const Text('护花使者', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _userController,
                    decoration: const InputDecoration(labelText: '用户名'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _pwdController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: '密码'),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: Text(_isLoginMode ? '登录' : '注册'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _loading ? null : () => setState(() => _isLoginMode = !_isLoginMode),
                    child: Text(_isLoginMode ? '没有账号？去注册' : '已有账号？去登录'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
