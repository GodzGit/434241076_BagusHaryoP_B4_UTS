class LoginScreen extends StatefulWidget { ... }

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _handleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success) {
      Navigator.pushReplacementNamed(context, AppConstants.routeDashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        child: Column(
          children: [
            CustomTextField(
              label: 'Email',
              controller: _emailController,
            ),
            CustomTextField(
              label: 'Password',
              controller: _passwordController,
              obscureText: true,
            ),
            CustomButton(
              text: 'Login',
              onPressed: _handleLogin,
            ),
          ],
        ),
      ),
    );
  }
}