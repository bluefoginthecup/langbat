import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:langbat/src/services/auth_service.dart';

class LaunchGate extends StatefulWidget {
  const LaunchGate({
    super.key,
    required this.authService,
    required this.signedInBuilder,
  });

  final AuthService authService;
  final WidgetBuilder signedInBuilder;

  @override
  State<LaunchGate> createState() => _LaunchGateState();
}

class _LaunchGateState extends State<LaunchGate> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _signUpMode = false;
  bool _working = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.authService.userStream,
      initialData: widget.authService.currentUser,
      builder: (context, snapshot) {
        if (snapshot.data != null) {
          return widget.signedInBuilder(context);
        }
        return _buildAuthScreen(context);
      },
    );
  }

  Widget _buildAuthScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _signUpMode ? '계정 만들기' : '계정으로 계속하기',
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _signUpMode
                                ? '처음 사용하는 이메일이면 회원가입으로 계정을 만드세요.'
                                : '이미 만든 이메일 계정으로 로그인하세요.',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: '이메일',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              final email = value?.trim() ?? '';
                              if (!email.contains('@')) {
                                return '이메일을 입력하세요.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: '비밀번호',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if ((value ?? '').length < 6) {
                                return '비밀번호는 6자 이상이어야 합니다.';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) => _submitEmail(),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _working ? null : _submitEmail,
                            child: Text(_signUpMode ? '회원가입' : '로그인'),
                          ),
                          if (!_signUpMode) ...[
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: _working
                                  ? null
                                  : () {
                                      setState(() => _signUpMode = true);
                                    },
                              child: const Text('처음이면 회원가입하기'),
                            ),
                          ],
                          TextButton(
                            onPressed: _working
                                ? null
                                : () {
                                    setState(() => _signUpMode = !_signUpMode);
                                  },
                            child: Text(
                              _signUpMode ? '이미 계정이 있으면 로그인' : '계정이 없으면 회원가입',
                            ),
                          ),
                          TextButton(
                            onPressed: _working ? null : _sendPasswordReset,
                            child: const Text('비밀번호 재설정 메일 보내기'),
                          ),
                          if (widget.authService.supportsGoogleSignIn) ...[
                            const Divider(height: 32),
                            OutlinedButton(
                              onPressed: _working ? null : _signInWithGoogle,
                              child: const Text('Google 로그인'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _submitEmail() async {
    if (_working) return;
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() => _working = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (_signUpMode) {
        await widget.authService.createUserWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        await widget.authService.signInWithEmail(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(_authErrorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _sendPasswordReset() async {
    if (_working) return;
    final email = _emailController.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    if (!email.contains('@')) {
      messenger.showSnackBar(
        const SnackBar(content: Text('이메일을 먼저 입력하세요.')),
      );
      return;
    }

    setState(() => _working = true);
    try {
      await widget.authService.sendPasswordResetEmail(email);
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('비밀번호 재설정 메일을 보냈습니다.')),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(_authErrorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_working) return;
    setState(() => _working = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await widget.authService.signInWithGoogle();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(_authErrorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  String _authErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'operation-not-allowed':
          return 'Firebase 콘솔에서 이메일/비밀번호 로그인을 먼저 켜야 합니다.';
        case 'user-not-found':
        case 'invalid-credential':
          return '가입된 계정을 찾지 못했습니다. 처음이면 회원가입을 눌러주세요.';
        case 'wrong-password':
          return '비밀번호가 맞지 않습니다.';
        case 'email-already-in-use':
          return '이미 가입된 이메일입니다. 로그인으로 전환해 주세요.';
        case 'invalid-email':
          return '이메일 형식이 올바르지 않습니다.';
        case 'weak-password':
          return '비밀번호는 6자 이상으로 입력하세요.';
        case 'network-request-failed':
          return '네트워크 연결을 확인한 뒤 다시 시도하세요.';
        case 'too-many-requests':
          return '시도가 너무 많습니다. 잠시 후 다시 시도하세요.';
      }
      return error.message ?? 'Firebase 인증 실패: ${error.code}';
    }
    return '인증 실패: $error';
  }
}
