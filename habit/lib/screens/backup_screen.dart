import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/backup_helper.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _isLoading = false;
  bool _isGoogleSignedIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yedekler')),
      body: Stack(
        children: [
          ListView(
            children: [
              const SizedBox(height: 16),
              
              // YEREL YEDEK section
              _buildSectionHeader('YEREL YEDEK'),
              _buildActionTile(
                icon: Icons.backup,
                title: 'Yerel Yedek Oluştur',
                subtitle: 'Yedekleme dosyasını cihaza kaydet',
                onTap: _createLocalBackup,
              ),
              _buildActionTile(
                icon: Icons.restore,
                title: 'Yedek Dosyası İçe Aktar',
                subtitle: 'Yerel yedekten geri yükle',
                onTap: _importLocalBackup,
              ),
              
              const Divider(height: 32),
              
              // BULUT YEDEGI section
              _buildSectionHeader('BULUT YEDEGI'),
              _buildInfoTile(
                icon: Icons.help_outline,
                title: 'Nasıl çalışıyor',
                onTap: _showHowItWorks,
              ),
              
              const Divider(height: 32),
              
              // GOOGLE DRIVE section
              _buildSectionHeader('GOOGLE DRIVE'),
              _buildActionTile(
                icon: Icons.login,
                title: 'Google Hesabına Giriş Yap',
                subtitle: 'Yedekleri senkronize ve geri yüklemek için giriş yapın',
                onTap: _signInToGoogle,
              ),
              _buildActionTile(
                icon: Icons.cloud_upload,
                title: 'Otomatik Yedekleme',
                subtitle: 'Otomatik yedeklemeyi etkinleştirmek için Pro\'ya yükseltin',
                onTap: _showPremiumRequired,
                isPremium: true,
              ),
              
              const SizedBox(height: 24),
              
              // Action buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isGoogleSignedIn ? _syncToDrive : _signInToGoogle,
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text('Google Drive\'a Senkronize Et'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isGoogleSignedIn ? _restoreFromDrive : _signInToGoogle,
                        icon: const Icon(Icons.cloud_download),
                        label: const Text('Google Drive\'dan Geri Yükle'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2196F3),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
            ],
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isPremium = false,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isPremium ? Colors.orange.withOpacity(0.1) : const Color(0xFF2196F3).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isPremium ? Colors.orange : const Color(0xFF2196F3)),
      ),
      title: Text(title),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      trailing: isPremium
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Pro', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
            )
          : const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.grey[600]),
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Future<void> _createLocalBackup() async {
    setState(() => _isLoading = true);
    try {
      final path = await BackupHelper.createLocalBackup();
      setState(() => _isLoading = false);
      _showSuccessSnackbar('Yedek oluşturuldu: $path');
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('Yedek oluşturulamadı');
    }
  }

  Future<void> _importLocalBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        setState(() => _isLoading = true);
        await BackupHelper.restoreFromLocal(result.files.single.path!);
        setState(() => _isLoading = false);
        _showSuccessSnackbar('Yedek başarıyla geri yüklendi');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('Yedek geri yüklenemedi');
    }
  }

  Future<void> _signInToGoogle() async {
    setState(() => _isLoading = true);
    try {
      final success = await BackupHelper.signInToGoogle();
      setState(() {
        _isGoogleSignedIn = success;
        _isLoading = false;
      });
      if (success) {
        _showSuccessSnackbar('Google hesabına giriş yapıldı');
      } else {
        _showErrorSnackbar('Google girişi başarısız');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('Google giriş hatası');
    }
  }

  Future<void> _syncToDrive() async {
    setState(() => _isLoading = true);
    try {
      await BackupHelper.syncToGoogleDrive();
      setState(() => _isLoading = false);
      _showSuccessSnackbar('Google Drive\'a senkronize edildi');
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('Senkronizasyon başarısız');
    }
  }

  Future<void> _restoreFromDrive() async {
    setState(() => _isLoading = true);
    try {
      await BackupHelper.restoreFromGoogleDrive();
      setState(() => _isLoading = false);
      _showSuccessSnackbar('Google Drive\'dan geri yüklendi');
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('Geri yükleme başarısız');
    }
  }

  void _showHowItWorks() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nasıl çalışıyor'),
        content: const Text(
          'Yedekleme özelliği, tüm alışkanlıklarınızı, giderlerinizi ve duygu durumlarınızı güvenli bir şekilde saklar.\n\n'
          '- Yerel yedek: Cihazınıza .db dosyası olarak kaydeder\n'
          '- Google Drive: Bulutta saklar, cihaz değiştirseniz bile verileriniz güvende olur\n'
          '- Otomatik yedekleme: Pro özelliği ile her gün otomatik yedek alır',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Kapat')),
        ],
      ),
    );
  }

  void _showPremiumRequired() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pro Özellik'),
        content: const Text('Otomatik yedekleme özelliğini kullanmak için Pro sürüme yükseltin.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Daha Sonra')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/premium');
            },
            child: const Text('Yükselt'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}