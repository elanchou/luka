import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/master_key_service.dart';
import '../providers/vault_provider.dart';
import 'set_master_password_screen.dart';

class SetMasterPasswordWrapper extends StatelessWidget {
  const SetMasterPasswordWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return SetMasterPasswordScreen(
      isChangingPassword: false,
      onPasswordSet: () async {
        // After password is set, we need to initialize the vault
        // But we can't access the password here directly
        // So we'll navigate to password input screen
        Navigator.of(context).pushReplacementNamed('/master-password-input');
      },
    );
  }
}
