import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/likita_theme.dart';
import '../../core/state/auth_state.dart';
import '../../core/models/likita_user.dart';
import '../../core/widgets/likita_nav_bar.dart';

/// Retourne un message d'erreur lisible pour l'utilisateur.
String _userFriendlyAuthError(Object e) {
  final s = e.toString();
  if (s.contains('user-not-found') || s.contains('USER_NOT_FOUND')) {
    return 'Aucun compte avec cet email.';
  }
  if (s.contains('wrong-password') || s.contains('INVALID_PASSWORD')) {
    return 'Mot de passe incorrect.';
  }
  if (s.contains('email-already-in-use') || s.contains('EMAIL_EXISTS')) {
    return 'Cet email est déjà utilisé.';
  }
  if (s.contains('invalid-email') || s.contains('INVALID_EMAIL')) {
    return 'Adresse email invalide.';
  }
  if (s.contains('network') || s.contains('NetworkError') || s.contains('SocketException')) {
    return 'Erreur réseau. Vérifiez votre connexion.';
  }
  // Message court pour ne pas inonder l'utilisateur
  if (s.length > 120) return 'Erreur de connexion. Réessayez.';
  return s.replaceFirst(RegExp(r'^Exception:?\s*'), '');
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _emailLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthState>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: LikitaNavBar(showNavLinks: true, currentTitle: 'Connexion'),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Connexion',
                  style: textTheme.headlineMedium?.copyWith(color: LikitaColors.primaryBlue),
                ),
                const SizedBox(height: 8),
                Text(
                  'Accédez à votre compte pour gérer vos billets ou votre tableau de bord.',
                  style: textTheme.bodyMedium?.copyWith(color: LikitaColors.textDark),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  autocorrect: false,
                  enableSuggestions: false,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _emailLoading
                      ? null
                      : () async {
                          setState(() => _emailLoading = true);
                          try {
                            await auth.signIn(
                              _emailController.text.trim(),
                              _passwordController.text,
                            );
                            if (context.mounted) context.go('/');
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(_userFriendlyAuthError(e)),
                                  backgroundColor: LikitaColors.accentRed,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _emailLoading = false);
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: LikitaColors.accentRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _emailLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Se connecter'),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => context.push('/register'),
                    style: TextButton.styleFrom(
                      foregroundColor: LikitaColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text("Pas encore de compte ? S'inscrire"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthState>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: LikitaNavBar(showNavLinks: true, currentTitle: "S'inscrire"),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Text(
                  "Créer un compte organisateur",
                  style: textTheme.headlineMedium?.copyWith(color: LikitaColors.primaryBlue),
                ),
                const SizedBox(height: 8),
                Text(
                  "Inscrivez-vous pour créer et gérer vos événements.",
                  style: textTheme.bodyMedium?.copyWith(color: LikitaColors.textDark),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom complet',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  autocorrect: false,
                  enableSuggestions: false,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _loading
                      ? null
                      : () async {
                          setState(() => _loading = true);
                          try {
                            await auth.signUp(
                              email: _emailController.text.trim(),
                              password: _passwordController.text,
                              displayName: _nameController.text.trim(),
                              role: LikitaUserRole.organizer,
                            );
                            if (context.mounted) context.go('/');
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(_userFriendlyAuthError(e)),
                                  backgroundColor: LikitaColors.accentRed,
                                ),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _loading = false);
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: LikitaColors.accentRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text("S'inscrire"),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => context.push('/login'),
                    style: TextButton.styleFrom(
                      foregroundColor: LikitaColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text('Déjà un compte ? Se connecter'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
