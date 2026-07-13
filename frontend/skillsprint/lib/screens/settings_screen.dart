import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';
import '../widgets/floating_nav_dock.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _darkMode = true;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070707),
      appBar: AppBar(
        title: const Text('SETTINGS'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 90),
          children: [
            const SizedBox(height: 10),

            // 1. Account Settings Card Group
            const Text(
              "ACCOUNT PROFILE",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white30),
            ),
            const SizedBox(height: 10),
            GlassCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildNavigationRow("Edit Profile Info", Icons.edit),
                  const Divider(color: Colors.white10),
                  _buildNavigationRow("Manage Account Subscriptions", Icons.payment),
                  const Divider(color: Colors.white10),
                  _buildNavigationRow("Reset Password Security", Icons.lock_outline),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 2. Preferences Card Group
            const Text(
              "APP PREFERENCES",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white30),
            ),
            const SizedBox(height: 10),
            GlassCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Dark Mode forced to toggle true
                  _buildToggleRow(
                    "Forced Dark Mode",
                    "Maintain One Piece black theme background.",
                    _darkMode,
                    (val) => setState(() => _darkMode = val),
                  ),
                  const Divider(color: Colors.white10),
                  _buildToggleRow(
                    "Vibe Sound Effects",
                    "Interactive tactile 3D node clicking audios.",
                    _soundEnabled,
                    (val) => setState(() => _soundEnabled = val),
                  ),
                  const Divider(color: Colors.white10),
                  _buildToggleRow(
                    "Sailing Push Alerts",
                    "Get reminders when daily streak is closing.",
                    _notificationsEnabled,
                    (val) => setState(() => _notificationsEnabled = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3. Language settings Selection
            const Text(
              "LOCALIZATION",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white30),
            ),
            const SizedBox(height: 10),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Interface Language", style: TextStyle(fontSize: 14)),
                  DropdownButton<String>(
                    dropdownColor: const Color(0xFF161616),
                    value: _selectedLanguage,
                    underline: const SizedBox(),
                    items: ['English', 'Spanish', 'French', 'Japanese'].map((String lang) {
                      return DropdownMenuItem<String>(
                        value: lang,
                        child: Text(
                          lang,
                          style: const TextStyle(color: Colors.orangeAccent, fontSize: 13),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newVal) {
                      if (newVal != null) {
                        setState(() {
                          _selectedLanguage = newVal;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.orangeAccent,
                            content: Text(
                              "Language updated to $newVal! 🌐",
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Version Label
            const Center(
              child: Text(
                "SkillSprint App • Version 1.0.0 (Build 432)\nPowered by Antigravity AI Engine",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: Colors.white24, height: 1.5),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const FloatingNavDock(activeIndex: 4),
    );
  }

  Widget _buildNavigationRow(String title, IconData icon) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Icon(icon, color: Colors.orangeAccent, size: 18),
      title: Text(title, style: const TextStyle(fontSize: 13, color: Colors.white)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 12),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "$title settings coming soon! ⚙️",
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Widget _buildToggleRow(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.white38)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.orangeAccent,
            activeTrackColor: Colors.orangeAccent.withOpacity(0.3),
            inactiveThumbColor: Colors.white38,
            inactiveTrackColor: Colors.white12,
          ),
        ],
      ),
    );
  }
}
