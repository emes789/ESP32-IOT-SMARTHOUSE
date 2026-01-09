import 'package:flutter/material.dart';
class AuthErrorScreen extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  const AuthErrorScreen({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.security_outlined,
                color: Colors.red,
                size: 80,
              ),
              const SizedBox(height: 24),
              Text(
                'Authentication Error',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              if (errorMessage.toLowerCase().contains('mongo') ||
                  errorMessage.toLowerCase().contains('database')) ...[
                _buildMongoInstructions(context),
                const SizedBox(height: 24),
              ],
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildMongoInstructions(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How to Fix',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Zweryfikuj poprawność adresu URI MongoDB w konfiguracji aplikacji.\n'
              '2. Upewnij się, że dane logowania (użytkownik/hasło) są aktualne.\n'
              '3. Sprawdź, czy bieżący adres IP jest dodany do listy dozwolonych w MongoDB Atlas.\n'
              '4. Potwierdź, że klaster jest dostępny i nie znajduje się w trybie pauzy.'
            ),
          ],
        ),
      ),
    );
  }
}
