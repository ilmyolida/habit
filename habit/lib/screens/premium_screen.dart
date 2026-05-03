import 'package:flutter/material.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium\'a Yükselt')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF7C4DFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tek Uygulamada\n5 Güçlü Araç',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Neden 5 ayrı uygulama için ödeme yapasınız?',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _buildFeatureChip('Alışkanlıklar'),
                      const SizedBox(width: 8),
                      _buildFeatureChip('Duygular'),
                      const SizedBox(width: 8),
                      _buildFeatureChip('Harcamalar'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildFeatureChip('Günlük'),
                      const SizedBox(width: 8),
                      _buildFeatureChip('Odaklanma'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Saving badge
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Ayrı uygulamalara kıyasla %80\'e kadar tasarruf edin',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Pricing cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildPricingCard(
                    title: 'Aylık',
                    price: '\$1.49',
                    period: '/ay',
                    description: 'En esnek. Denemek için ideal.',
                    isPopular: false,
                  ),
                  const SizedBox(height: 16),
                  _buildPricingCard(
                    title: 'Yıllık',
                    price: '\$11.99',
                    period: '/yıl',
                    description: 'Bu sadece \$1/ay',
                    isPopular: true,
                    savings: '%80 tasarruf',
                  ),
                  const SizedBox(height: 16),
                  _buildPricingCard(
                    title: 'Ömür boyu',
                    price: '\$29.99',
                    period: 'tek ödeme',
                    description: 'Bir kez satın alın, sonsuza kadar kullanın!',
                    isPopular: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Features list
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ne alırsınız',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem('Otomatik Bulut Yedeklemeleri'),
                  _buildFeatureItem('Sınırsız alışkanlık / periyodik görev takip edin'),
                  _buildFeatureItem('Alt öğeler / kontrol listeleriyle alışkanlık oluşturun'),
                  _buildFeatureItem('Zamanlayıcı ve kronometre ile alışkanlıklar oluşturun'),
                  _buildFeatureItem('Ruh hali istatistikleri (Hafta, Ay, Yıl, Tüm zamanlar)'),
                  _buildFeatureItem('Günlük istatistikleri'),
                  _buildFeatureItem('Tüm alışkanlıkların istatistikleri'),
                  _buildFeatureItem('Odak Zamanlayıcı İstatistikleri'),
                  _buildFeatureItem('Gelir ve harcamalar için detaylı istatistikler'),
                  _buildFeatureItem('Sınırsız hesap oluşturun'),
                  _buildFeatureItem('Sınırsız bütçe oluşturun'),
                  _buildFeatureItem('Widget\'lar'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Legal text
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Satın alma onaylandığında ödeme Google Play hesabınızdan tahsil edilecektir. Abonelik, mevcut dönemin bitiminden en az 24 saat önce otomatik yenileme kapatılmadığı sürece otomatik olarak yenilenir.',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 16),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _startFreeTrial(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('3 Gün Ücretsiz Denemeyi Başlat'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text('Kullanım Koşulları'),
                      ),
                      const Text('•'),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Gizlilik Politikası'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }

  Widget _buildPricingCard({
    required String title,
    required String price,
    required String period,
    required String description,
    required bool isPopular,
    String? savings,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isPopular ? const Color(0xFF2196F3).withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isPopular
            ? Border.all(color: const Color(0xFF2196F3), width: 2)
            : Border.all(color: Colors.grey[200]!),
      ),
      child: Stack(
        children: [
          if (isPopular)
            Positioned(
              top: -12,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'En Popüler',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    if (savings != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(savings, style: const TextStyle(color: Colors.green, fontSize: 12)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: price,
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      TextSpan(
                        text: period,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  void _startFreeTrial(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ücretsiz Deneme'),
        content: const Text('3 günlük ücretsiz denemeyi başlatmak istediğinize emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ücretsiz deneme başlatıldı!')),
              );
            },
            child: const Text('Başlat'),
          ),
        ],
      ),
    );
  }
}