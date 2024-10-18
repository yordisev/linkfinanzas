import 'package:encrypt_decrypt_plus/cipher/cipher.dart';

class AESEncryption {
  final Cipher _cipher = Cipher();

  encrypt(clave, texto) async {
    final encryptTxt = _cipher.xorEncode(texto, secretKey: clave);
    return encryptTxt;
  }

  decrypt(clave, text) async {
    final decryptTxt = _cipher.xorDecode(text, secretKey: clave);
    return decryptTxt;
  }

  cifrarclave(texto) async {
    final encryptTxt =
        _cipher.xorEncode(texto, secretKey: "ClaveSecury2023!!#.");
    return encryptTxt;
  }

  decifrarclave(text) async {
    final decryptTxt =
        _cipher.xorDecode(text, secretKey: "ClaveSecury2023!!#.");
    return decryptTxt;
  }
}
