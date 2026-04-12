import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/website_screen.dart';
import 'screens/wifi_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/saved_screen.dart';
import 'screens/about_screen.dart';
import 'core/constants/strings.dart';
import 'core/constants/colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: UmbraQRGenApp()));
}

class UmbraQRGenApp extends StatelessWidget {
  const UmbraQRGenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UmbraQRGen',
      debugShowCheckedModeBanner: false,
      home: const MainShell(),
    );
  }
}

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;
  bool _showingMenu = false;
  bool _showingAbout = false;

  final List<String> _tabNames = ['Website', 'WiFi', 'Contact', 'Saved'];

  final List<Widget> _screens = const [
    WebsiteScreen(),
    WifiScreen(),
    ContactScreen(),
    SavedScreen(),
  ];

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => MenuSheet(
        onSelectTab: (index) {
          setState(() => _currentIndex = index);
          Navigator.pop(context);
        },
        onShowAbout: () {
          Navigator.pop(context);
          setState(() => _showingAbout = true);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top bar - App name and menu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Text(
                  'UmbraQRGen',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.dehaze, size: 24),
                  onPressed: _showMenu,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Context bar - Current tab name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  _tabNames[_currentIndex],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          const Divider(height: 1),
          // Content area - Scrollable
          Expanded(
            child: IndexedStack(index: _currentIndex, children: _screens),
          ),
          const Divider(height: 1),
          // Bottom quick actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                _QuickActionButton(
                  icon: Icons.link,
                  label: 'Website',
                  isSelected: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _QuickActionButton(
                  icon: Icons.wifi,
                  label: 'WiFi',
                  isSelected: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _QuickActionButton(
                  icon: Icons.person,
                  label: 'Contact',
                  isSelected: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _QuickActionButton(
                  icon: Icons.save_alt,
                  label: 'Saved',
                  isSelected: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppColors.electricCyan : AppColors.mutedIce,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppColors.electricCyan : AppColors.mutedIce,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuSheet extends StatelessWidget {
  final Function(int) onSelectTab;
  final VoidCallback onShowAbout;

  const MenuSheet({required this.onSelectTab, required this.onShowAbout});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('Website'),
            onTap: () => onSelectTab(0),
          ),
          ListTile(
            leading: const Icon(Icons.wifi),
            title: const Text('WiFi'),
            onTap: () => onSelectTab(1),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Contact'),
            onTap: () => onSelectTab(2),
          ),
          ListTile(
            leading: const Icon(Icons.save_alt),
            title: const Text('Saved'),
            onTap: () => onSelectTab(3),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: onShowAbout,
          ),
        ],
      ),
    );
  }
}
