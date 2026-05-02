import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings_bloc.dart';
import '../models/user_settings.dart';
import 'categories_screen.dart';
import 'habit_order_screen.dart';
import 'mood_customize_screen.dart';
import 'mood_tags_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoaded) {
            return ListView(
              children: [
                const PremiumBannerSection(),
                _buildSectionHeader('GÖRÜNÜM'),
                _buildSwitchTile(
                  context,
                  'Karanlık mod',
                  state.settings.darkMode,
                  (value) => context.read<SettingsBloc>().add(ToggleDarkMode(value)),
                ),
                _buildNavigationTile(
                  context,
                  'Tema Rengi',
                  () => _showThemeColorPicker(context, state),
                ),
                
                _buildSectionHeader('GENEL'),
                _buildSwitchTile(
                  context,
                  'Şifre kilidi',
                  state.settings.passwordLock,
                  (value) => context.read<SettingsBloc>().add(TogglePasswordLock(value)),
                ),
                _buildNavigationTile(
                  context,
                  'Dil',
                  subtile: 'Türkçe',
                  onTap: () => _showLanguagePicker(context, state),
                ),
                _buildNavigationTile(
                  context,
                  'Haftanın ilk günü',
                  subtile: state.settings.firstDayOfWeek == 0 ? 'Pazar' : 'Pazartesi',
                  onTap: () => _showFirstDayPicker(context, state),
                ),
                _buildSwitchTile(
                  context,
                  '24 Saatlik Format',
                  state.settings.use24HourFormat,
                  (value) => context.read<SettingsBloc>().add(Toggle24HourFormat(value)),
                ),
                
                _buildSectionHeader('SESLER VE DOKUNSAL'),
                _buildSwitchTile(
                  context,
                  'Dokunmada titresim',
                  state.settings.vibrateOnTap,
                  (value) => context.read<SettingsBloc>().add(ToggleVibration(value)),
                ),
                _buildSwitchTile(
                  context,
                  'Tamamlama sesi',
                  state.settings.completionSound,
                  (value) => context.read<SettingsBloc>().add(ToggleCompletionSound(value)),
                ),
                _buildSwitchTile(
                  context,
                  'Hedef ve Başarı Sesi',
                  state.settings.goalAchievedSound,
                  (value) => context.read<SettingsBloc>().add(ToggleGoalAchievedSound(value)),
                ),
                _buildNavigationTile(
                  context,
                  'Alarm sesi',
                  subtile: state.settings.alarmTone,
                  onTap: () => _showAlarmTonePicker(context, state),
                ),
                
                _buildSectionHeader('ALIŞKANLIKLAR VE GÖREVLER'),
                _buildSwitchTile(
                  context,
                  'Tamamlanan Aktiviteleri Gizle',
                  state.settings.hideCompletedActivities,
                  (value) => context.read<SettingsBloc>().add(ToggleHideCompleted(value)),
                ),
                _buildNavigationTile(
                  context,
                  'Kategoriler',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen())),
                ),
                _buildNavigationTile(
                  context,
                  'Alışkanlıkları Sırala',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HabitOrderScreen())),
                ),
                _buildNavigationTile(
                  context,
                  'Varsayılan Ekran',
                  subtile: state.settings.defaultScreen,
                  onTap: () => _showDefaultScreenPicker(context, state),
                ),
                
                _buildSectionHeader('DUYGULAR'),
                _buildNavigationTile(
                  context,
                  'Ruh hallerini özelleştir',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodCustomizeScreen())),
                ),
                _buildNavigationTile(
                  context,
                  'Etiketler',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MoodTagsScreen())),
                ),
                
                _buildSectionHeader('HARCAMALAR'),
                _buildNavigationTile(
                  context,
                  'Kategoriler',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen())),
                ),
                _buildNavigationTile(
                  context,
                  'Para Birimi Simgesi',
                  subtile: state.settings.currencySymbol,
                  onTap: () => _showCurrencyPicker(context, state),
                ),
                _buildNavigationTile(
                  context,
                  'Döviz kurları',
                  subtile: '1 USD = ${state.settings.usdToUzs.toStringAsFixed(2)} so\'m',
                  onTap: () => _showExchangeRateDialog(context, state),
                ),
                _buildNavigationTile(
                  context,
                  'CSV Dışa Aktar',
                  onTap: () => _exportCSV(context),
                ),
                
                _buildSectionHeader('VERİ VE YEDEKLEME'),
                _buildNavigationTile(
                  context,
                  'Yedekler',
                  onTap: () => Navigator.pushNamed(context, '/backup'),
                ),
                _buildNavigationTile(
                  context,
                  'Verileri Yönet',
                  onTap: () => _showDataManagementDialog(context),
                ),
                _buildNavigationTile(
                  context,
                  'Kayıp verileri kurtar',
                  subtile: '3.2.0 güncellemesi sonrası kaybolan verileri kurtar',
                  onTap: () => _recoverLostData(context),
                ),
                _buildNavigationTile(
                  context,
                  'Hızlı İşlemleri Özelleştir',
                  onTap: () => Navigator.pushNamed(context, '/quick-actions'),
                ),
                
                _buildSectionHeader('BİLDİRİMLER'),
                _buildNavigationTile(
                  context,
                  'Bildirim Ayarları',
                  onTap: () => _showNotificationSettings(context),
                ),
                
                _buildSectionHeader('HAKKINDA'),
                _buildNavigationTile(context, 'Otomatik başlatma', onTap: () {}),
                _buildNavigationTile(
                  context,
                  'Play Store\'da değerlendir',
                  onTap: () {},
                ),
                _buildNavigationTile(context, 'Öneriler', onTap: () {}),
                _buildNavigationTile(
                  context,
                  'Uygulamayı paylaş',
                  onTap: () {},
                ),
                
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'HabitGenius v3.2.4',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(BuildContext context, String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildNavigationTile(BuildContext context, String title, {String? subtile, VoidCallback? onTap}) {
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (subtile != null) Text(subtile, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
      onTap: onTap,
    );
  }

  void _showThemeColorPicker(BuildContext context, SettingsLoaded state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tema Rengi'),
        content: const ColorPicker(initialColor: Color(0xFF2196F3)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          TextButton(
            onPressed: () {
              // context.read<SettingsBloc>().add(ChangeThemeColor(selectedColor.value));
              Navigator.pop(context);
            },
            child: const Text('Seç'),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, SettingsLoaded state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dil Seçimi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: const Text('Türkçe'), onTap: () => _changeLanguage(context, 'tr')),
            ListTile(title: const Text('Uzbek'), onTap: () => _changeLanguage(context, 'uz')),
            ListTile(title: const Text('Русский'), onTap: () => _changeLanguage(context, 'ru')),
            ListTile(title: const Text('English'), onTap: () => _changeLanguage(context, 'en')),
          ],
        ),
      ),
    );
  }

  void _changeLanguage(BuildContext context, String lang) {
    context.read<SettingsBloc>().add(ChangeLanguage(lang));
    Navigator.pop(context);
  }

  void _showFirstDayPicker(BuildContext context, SettingsLoaded state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Haftanın İlk Günü'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Pazar'),
              onTap: () {
                context.read<SettingsBloc>().add(ChangeFirstDay(0));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Pazartesi'),
              onTap: () {
                context.read<SettingsBloc>().add(ChangeFirstDay(1));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAlarmTonePicker(BuildContext context, SettingsLoaded state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alarm Sesi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Sabah kuşu'),
              onTap: () {
                context.read<SettingsBloc>().add(ChangeAlarmTone('Sabah kuşu'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDefaultScreenPicker(BuildContext context, SettingsLoaded state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Varsayılan Ekran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Bugün'),
              onTap: () {
                context.read<SettingsBloc>().add(ChangeDefaultScreen('Bugün'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Genel Bakış'),
              onTap: () {
                context.read<SettingsBloc>().add(ChangeDefaultScreen('Genel Bakış'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, SettingsLoaded state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Para Birimi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('so\'m (UZS)'),
              onTap: () {
                context.read<SettingsBloc>().add(ChangeCurrencySymbol('so\'m'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('USD (\$)'),
              onTap: () {
                context.read<SettingsBloc>().add(ChangeCurrencySymbol('\$'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('EUR (€)'),
              onTap: () {
                context.read<SettingsBloc>().add(ChangeCurrencySymbol('€'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showExchangeRateDialog(BuildContext context, SettingsLoaded state) {
    final controller = TextEditingController(text: state.settings.usdToUzs.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Döviz Kuru'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '1 USD = ? so\'m'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          TextButton(
            onPressed: () {
              final rate = double.tryParse(controller.text);
              if (rate != null) {
                context.read<SettingsBloc>().add(ChangeUsdToUzs(rate));
              }
              Navigator.pop(context);
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _exportCSV(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CSV dışa aktarılıyor...')),
    );
  }

  void _showDataManagementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verileri Yönet'),
        content: const Text('Tüm verileri sıfırlamak ister misiniz? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          TextButton(
            onPressed: () {
              // Clear all data
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Veriler silindi')),
              );
            },
            child: const Text('Sıfırla', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _recoverLostData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kayıp veriler kurtarılıyor...')),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bildirim ayarları açılıyor...')),
    );
  }
}

class PremiumBannerSection extends StatelessWidget {
  const PremiumBannerSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF7C4DFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Premium'a Yükselt",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(
                'Tüm özellikleri aç',
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Yükselt', style: TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}