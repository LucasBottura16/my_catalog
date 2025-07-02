import 'dart:math';

class RandomKeys {
  generateRandomString() {
    final random = Random();
    const letters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    const chars = letters + numbers;

    String result = '';
    for (int i = 0; i < 20; i++) {
      result += chars[random.nextInt(chars.length)];
    }

    return result;
  }
}
