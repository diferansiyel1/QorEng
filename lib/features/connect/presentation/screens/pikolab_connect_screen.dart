import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/core/services/analytics_service.dart';
import 'package:engicore/core/services/auth_service.dart';
import 'package:engicore/shared/widgets/app_button.dart';

/// Engineering Hub - High-Conversion Business Intelligence Screen.
///
/// Features:
/// - Collapsible SliverAppBar with gradient
/// - Quick Actions Grid (WhatsApp, Meeting, Website, LinkedIn)
/// - Smart Project Inquiry Form with auth auto-fill
/// - Priority toggle for urgent requests
class PikolabConnectScreen extends ConsumerStatefulWidget {
  const PikolabConnectScreen({super.key});

  @override
  ConsumerState<PikolabConnectScreen> createState() =>
      _PikolabConnectScreenState();
}

class _PikolabConnectScreenState extends ConsumerState<PikolabConnectScreen> {
  static const String _whatsappNumber = '+905436639797';
  static const String _contactEmail = 'info@pikolab.com';
  static const String _linkedInUrl =
      'https://www.linkedin.com/company/pikolab-engineering';
  static const String _websiteUrl = 'https://www.pikolab.com';
  static const String _calendlyUrl =
      'https://calendly.com/fehmiozel/30min';

  // Form Controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _companyController = TextEditingController();
  final _messageController = TextEditingController();

  // Form State
  String _selectedSubject = 'Proses Tasarımı';
  bool _isUrgent = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _prefillUserData();
  }

  /// Pre-fill form with authenticated user data.
  void _prefillUserData() {
    final authService = ref.read(authServiceProvider);
    final user = authService.currentUser;

    if (user != null && !user.isGuest) {
      _nameController.text = user.displayName ?? '';
      _emailController.text = user.email;
      _companyController.text = user.company ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Watch auth state for auto-fill updates
    ref.listen(currentUserProvider, (previous, next) {
      next.whenData((user) {
        if (user != null && !user.isGuest) {
          if (_nameController.text.isEmpty) {
            _nameController.text = user.displayName ?? '';
          }
          if (_emailController.text.isEmpty) {
            _emailController.text = user.email;
          }
          if (_companyController.text.isEmpty) {
            _companyController.text = user.company ?? '';
          }
        }
      });
    });

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // SLIVER APP BAR with gradient
          _buildSliverAppBar(theme),

          // QUICK ACTIONS SECTION
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Dimens.spacingLg,
                Dimens.spacingLg,
                Dimens.spacingLg,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hızlı Erişim',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: Dimens.spacingMd),
                ],
              ),
            ),
          ),

          // QUICK ACTIONS GRID
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimens.spacingLg),
              child: _buildQuickActionsGrid(theme, isDark),
            ),
          ),

          // PROJECT INQUIRY SECTION
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(Dimens.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Dimens.spacingMd),
                  Row(
                    children: [
                      Icon(
                        Icons.rocket_launch_rounded,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: Dimens.spacingSm),
                      Text(
                        'Proje Başlat',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimens.spacingMd),
                  _buildProjectInquiryForm(theme, isDark),
                ],
              ),
            ),
          ),

          // BOTTOM PADDING
          const SliverToBoxAdapter(
            child: SizedBox(height: Dimens.spacingXl),
          ),
        ],
      ),
    );
  }

  /// Builds the collapsible SliverAppBar with gradient.
  Widget _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 160.0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Mühendislik Merkezi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black45,
                blurRadius: 4,
              ),
            ],
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.accentDark,
                AppColors.accent,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Subtle pattern overlay
              Positioned.fill(
                child: Opacity(
                  opacity: 0.08,
                  child: CustomPaint(
                    painter: _GridPatternPainter(),
                  ),
                ),
              ),
              // Icon decorations
              Positioned(
                right: -20,
                bottom: -20,
                child: Opacity(
                  opacity: 0.15,
                  child: Icon(
                    Icons.engineering_rounded,
                    size: 160,
                    color: Colors.white,
                  ),
                ),
              ),
              // Tagline
              Positioned(
                left: Dimens.spacingLg,
                bottom: 60,
                child: Text(
                  'Proses Mühendisliği Ortağınız',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the Quick Actions layout with WhatsApp spanning full width.
  Widget _buildQuickActionsGrid(ThemeData theme, bool isDark) {
    return Column(
      children: [
        // WhatsApp - Full width
        _QuickActionCard(
          icon: Icons.chat_rounded,
          label: 'WhatsApp Destek',
          color: const Color(0xFF25D366),
          onTap: _openWhatsApp,
          aspectRatio: 2.6,
        ),
        const SizedBox(height: Dimens.spacingMd),
        // Web and LinkedIn in a row
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.public_rounded,
                label: 'Web Sitesi',
                color: const Color(0xFF2196F3),
                onTap: _openWebsite,
              ),
            ),
            const SizedBox(width: Dimens.spacingMd),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.people_rounded,
                label: 'LinkedIn Topluluk',
                color: const Color(0xFF0A66C2),
                onTap: _openLinkedIn,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the Smart Project Inquiry form.
  Widget _buildProjectInquiryForm(ThemeData theme, bool isDark) {
    final subjects = [
      'Proses Tasarımı',
      'Ekipman',
      'Otomasyon',
      'Diğer',
    ];

    return Card(
      elevation: Dimens.elevationMd,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimens.spacingLg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name & Company Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'İsim',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen isminizi girin';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: Dimens.spacingMd),
                  Expanded(
                    child: TextFormField(
                      controller: _companyController,
                      decoration: const InputDecoration(
                        labelText: 'Şirket',
                        prefixIcon: Icon(Icons.business_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimens.spacingMd),

              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-posta',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen e-posta adresinizi girin';
                  }
                  if (!value.contains('@')) {
                    return 'Lütfen geçerli bir e-posta girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: Dimens.spacingMd),

              // Subject Dropdown
              DropdownButtonFormField<String>(
                value: _selectedSubject,
                decoration: const InputDecoration(
                  labelText: 'Konu',
                  prefixIcon: Icon(Icons.topic_outlined),
                  border: OutlineInputBorder(),
                ),
                items: subjects.map((subject) {
                  return DropdownMenuItem(
                    value: subject,
                    child: Text(subject),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedSubject = value!);
                },
              ),
              const SizedBox(height: Dimens.spacingMd),

              // Priority Toggle
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _isUrgent
                        ? AppColors.error
                        : (isDark
                            ? Colors.white24
                            : Colors.black26),
                    width: _isUrgent ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(Dimens.radiusMd),
                  color: _isUrgent
                      ? AppColors.error.withValues(alpha: 0.1)
                      : null,
                ),
                child: SwitchListTile(
                  secondary: Icon(
                    _isUrgent
                        ? Icons.warning_amber_rounded
                        : Icons.schedule_rounded,
                    color: _isUrgent ? AppColors.error : null,
                  ),
                  title: Text(
                    _isUrgent ? 'Acil (Üretim Durdu)' : 'Standart Öncelik',
                    style: TextStyle(
                      color: _isUrgent ? AppColors.error : null,
                      fontWeight:
                          _isUrgent ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                  value: _isUrgent,
                  activeColor: AppColors.error,
                  onChanged: (value) {
                    setState(() => _isUrgent = value);
                  },
                ),
              ),
              const SizedBox(height: Dimens.spacingMd),

              // Message
              TextFormField(
                controller: _messageController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Projenizi Tanımlayın',
                  hintText:
                      'örn. Biyoreaktörümüz için pH izleme gerekiyor...',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.description_outlined),
                  ),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen projenizi tanımlayın';
                  }
                  return null;
                },
              ),
              const SizedBox(height: Dimens.spacingLg),

              // Submit Button
              AppButton(
                label: 'Talep Gönder',
                icon: Icons.send_rounded,
                isLoading: _isSubmitting,
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Action Methods
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _openWhatsApp() async {
    final analytics = ref.read(analyticsServiceProvider);
    await analytics.logPromoClick(
      promoType: 'whatsapp',
      context: 'engineering_hub',
    );

    // Use urgent prefix if priority is set
    final urgentPrefix = _isUrgent ? 'ACİL DESTEK GEREKLİ: ' : '';
    final message = Uri.encodeComponent(
      '${urgentPrefix}Merhaba Pikolab, QorEng kullanıyorum ve ... '
      'konusunda desteğe ihtiyacım var.',
    );
    final url = Uri.parse('https://wa.me/$_whatsappNumber?text=$message');

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      developer.log('Failed to open WhatsApp: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('WhatsApp açılamadı')),
        );
      }
    }
  }

  Future<void> _openCalendly() async {
    final analytics = ref.read(analyticsServiceProvider);
    await analytics.logPromoClick(
      promoType: 'calendly',
      context: 'engineering_hub',
    );

    final url = Uri.parse(_calendlyUrl);
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      developer.log('Failed to open Calendly: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Randevu sayfası açılamadı')),
        );
      }
    }
  }

  Future<void> _openWebsite() async {
    final url = Uri.parse(_websiteUrl);
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      developer.log('Failed to open website: $e');
    }
  }

  Future<void> _openLinkedIn() async {
    final analytics = ref.read(analyticsServiceProvider);
    await analytics.logPromoClick(
      promoType: 'linkedin',
      context: 'engineering_hub',
    );

    final url = Uri.parse(_linkedInUrl);
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      developer.log('Failed to open LinkedIn: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('LinkedIn açılamadı')),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final analytics = ref.read(analyticsServiceProvider);
    await analytics.logPromoClick(
      promoType: 'project_inquiry',
      context: 'engineering_hub',
      moduleType: _selectedSubject,
    );

    // Build email subject with priority indicator
    final subject = _isUrgent
        ? '[ACİL TALEP] QorEng - $_selectedSubject'
        : '[Normal Talep] QorEng - $_selectedSubject';

    // Build email body with form data
    final body = '''
Yeni Proje Talebi - QorEng Uygulaması
======================================

Gönderen: ${_nameController.text}
E-posta: ${_emailController.text}
Şirket: ${_companyController.text.isEmpty ? 'Belirtilmedi' : _companyController.text}
Konu: $_selectedSubject
Öncelik: ${_isUrgent ? 'ACİL (Üretim Durdu)' : 'Standart'}

Mesaj:
${_messageController.text}

--------------------------------------
Bu talep QorEng mobil uygulaması üzerinden gönderilmiştir.
''';

    // Create mailto URI
    final mailtoUri = Uri(
      scheme: 'mailto',
      path: _contactEmail,
      query: _encodeQueryParameters({
        'subject': subject,
        'body': body,
      }),
    );

    try {
      final canLaunch = await canLaunchUrl(mailtoUri);
      if (canLaunch) {
        final launched = await launchUrl(mailtoUri);
        if (mounted) {
          setState(() => _isSubmitting = false);
          if (launched) {
            _showSuccessDialog();
          } else {
            _showEmailErrorSnackbar('Mail uygulaması açılamadı');
          }
        }
      } else {
        developer.log('Cannot launch mailto: URL');
        if (mounted) {
          setState(() => _isSubmitting = false);
          _showEmailErrorSnackbar(
            'Mail uygulaması bulunamadı. Lütfen $_contactEmail adresine manuel olarak ulaşın.',
          );
        }
      }
    } catch (e, s) {
      developer.log(
        'Failed to send email',
        error: e,
        stackTrace: s,
      );
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showEmailErrorSnackbar('Mail gönderilemedi: $e');
      }
    }
  }

  /// Helper to encode mailto query parameters.
  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  /// Show error snackbar for email failures.
  void _showEmailErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'WhatsApp',
          textColor: Colors.white,
          onPressed: _openWhatsApp,
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: Container(
            padding: const EdgeInsets.all(Dimens.spacingMd),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 48,
            ),
          ),
          title: const Text('Talep Gönderildi!'),
          content: Text(
            _isUrgent
                ? 'Acil talebiniz alındı. Ekibimiz mesai saatleri içinde '
                    '1 saat içinde sizinle iletişime geçecek.'
                : 'Talebiniz için teşekkürler! Mühendislik ekibimiz '
                    'isteğinizi inceleyip 24 saat içinde size '
                    'dönüş yapacak.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Clear form
                _messageController.clear();
                setState(() {
                  _selectedSubject = 'Proses Tasarımı';
                  _isUrgent = false;
                });
              },
              child: const Text('Tamam'),
            ),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Quick Action Card Widget
// ═══════════════════════════════════════════════════════════════════════════

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.aspectRatio,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final double? aspectRatio;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final card = Material(
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      borderRadius: BorderRadius.circular(Dimens.radiusLg),
      elevation: Dimens.elevationSm,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimens.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(Dimens.spacingMd),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimens.radiusLg),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(Dimens.spacingSm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(Dimens.radiusMd),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(height: Dimens.spacingSm),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (aspectRatio != null) {
      return AspectRatio(
        aspectRatio: aspectRatio!,
        child: card,
      );
    }

    return AspectRatio(
      aspectRatio: 1.3,
      child: card,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Grid Pattern Painter
// ═══════════════════════════════════════════════════════════════════════════

class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1;

    const spacing = 24.0;

    for (var x = 0.0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    for (var y = 0.0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
