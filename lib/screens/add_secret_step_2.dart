import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/vault_provider.dart';
import '../models/secret_model.dart';
import '../widgets/gradient_background.dart';
import '../widgets/vault_button.dart';
import '../widgets/vault_app_bar.dart';

class AddSecretStep2 extends StatefulWidget {
  const AddSecretStep2({super.key});

  @override
  State<AddSecretStep2> createState() => _AddSecretStep2State();
}

class _AddSecretStep2State extends State<AddSecretStep2> {
  late String _secretName;
  late String _network;

  final List<TextEditingController> _controllers = List.generate(
    12,
    (index) => TextEditingController(),
  );

  final List<FocusNode> _focusNodes = List.generate(
    12,
    (index) => FocusNode(),
  );

  int _currentIndex = 0;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _secretName = args['name'] ?? 'Unknown';
        _network = args['network'] ?? 'Unknown';
      }
      _initialized = true;
    }
  }

  @override
  void initState() {
    super.initState();
    // Simulate some pre-filled values for demo
    // _controllers[0].text = 'witch';
    // _controllers[1].text = 'wagon';
    // _controllers[2].text = 'fizzle';
    // _controllers[3].text = 'plump';

    // Set focus listeners
    for (int i = 0; i < 12; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus) {
          setState(() {
            _currentIndex = i;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _verifyPhrase() async {
    // Collect all words
    final words = _controllers.map((c) => c.text.trim()).toList();

    // Basic validation
    if (words.any((w) => w.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all 12 words')),
      );
      return;
    }

    // Create Secret
    final secretContent = words.join(' ');
    final secret = Secret.create(
      name: _secretName,
      network: _network,
      content: secretContent,
      type: SecretType.seedPhrase,
      typeLabel: 'SEED PHRASE • 12 WORDS',
    );

    // Save using Provider
    await Provider.of<VaultProvider>(context, listen: false).addSecret(secret);

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF13b6ec);
    const backgroundDark = Color(0xFF101d22);

    return Scaffold(
      backgroundColor: backgroundDark,
      extendBodyBehindAppBar: true,
      appBar: VaultAppBar(
        title: 'New Vault',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Step 2/3',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF9db2b9),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    children: [
                      // Headline
                      Text(
                        'Secure your phrase',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your 12-word recovery phrase in the correct order to verify your backup.',
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          color: Colors.grey[400],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Grid of Input Cells
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.4, // Matches approx h-[72px] width ratio
                        ),
                        itemCount: 12,
                        itemBuilder: (context, index) {
                          final isFocused = _currentIndex == index;
                          // Need to check mounted to avoid error if accessed during build but it's fine here
                          final isFilled = _controllers[index].text.isNotEmpty;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isFocused
                                  ? primaryColor.withOpacity(0.03)
                                  : (isFilled ? Colors.white.withOpacity(0.05) : Colors.transparent),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isFocused
                                    ? primaryColor
                                    : Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                              boxShadow: isFocused ? [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.1),
                                  blurRadius: 15,
                                  spreadRadius: -3,
                                )
                              ] : [],
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 10,
                                  top: 8,
                                  child: Text(
                                    (index + 1).toString().padLeft(2, '0'),
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isFocused ? primaryColor : Colors.white.withOpacity(0.3),
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8.0, left: 4, right: 4),
                                    child: TextField(
                                      controller: _controllers[index],
                                      focusNode: _focusNodes[index],
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.spaceMono( // Using a monospaced font if available, or fallback
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                        isDense: true,
                                        hintText: isFocused ? 'Type...' : '',
                                        hintStyle: TextStyle(
                                          color: Colors.white.withOpacity(0.1),
                                          fontSize: 13,
                                        ),
                                      ),
                                      textInputAction: index < 11
                                          ? TextInputAction.next
                                          : TextInputAction.done,
                                      onChanged: (value) {
                                        setState(() {}); // Rebuild to update cell style
                                      },
                                      onSubmitted: (_) {
                                        if (index < 11) {
                                          FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Security Note
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 16,
                            color: Colors.white.withOpacity(0.4)
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'End-to-end encrypted locally',
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),

                      // Bottom padding to avoid FAB overlap if any, or just spacing
                      const SizedBox(height: 100),
                    ],
                  ),
                ),

                // Fixed Bottom Button
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: VaultButton(
                    text: 'Save Secret',
                    icon: Icons.check,
                    onTap: _verifyPhrase,
                    backgroundColor: primaryColor,
                    textColor: backgroundDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
