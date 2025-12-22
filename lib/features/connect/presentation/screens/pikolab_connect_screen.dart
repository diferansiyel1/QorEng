import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/core/services/analytics_service.dart';

/// Pikolab Connect screen for business intelligence and lead generation.
///
/// Features:
/// - Ask an Expert (WhatsApp)
/// - Request Quote (RFQ form)
/// - Pro Community (LinkedIn gate)
class PikolabConnectScreen extends ConsumerStatefulWidget {
  const PikolabConnectScreen({super.key});

  @override
  ConsumerState<PikolabConnectScreen> createState() =>
      _PikolabConnectScreenState();
}

class _PikolabConnectScreenState extends ConsumerState<PikolabConnectScreen> {
  // TODO: Replace with actual Pikolab contact info
  static const String _whatsappNumber = '+905436639797';
  static const String _rfqEmail = 'sales@pikolab.com';
  static const String _linkedInUrl =
      'https://www.linkedin.com/company/pikolab-engineering';
  static const String _websiteUrl = 'https://www.pikolab.com';

  String? _selectedCategory;
  final _messageController = TextEditingController();
  bool _isProUser = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pikolab Connect'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimens.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(theme, isDark),

            const SizedBox(height: Dimens.spacingXl),

            // Ask an Expert - WhatsApp
            _buildAskExpertCard(theme, isDark),

            const SizedBox(height: Dimens.spacingLg),

            // Request Quote - RFQ
            _buildRfqCard(theme, isDark),

            const SizedBox(height: Dimens.spacingLg),

            // Pro Community - LinkedIn
            _buildProCommunityCard(theme, isDark),

            const SizedBox(height: Dimens.spacingXl),

            // Website Footer
            _buildWebsiteFooter(theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(Dimens.spacingMd),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(Dimens.radiusMd),
              ),
              child: const Icon(
                Icons.handshake_rounded,
                color: AppColors.accent,
                size: 32,
              ),
            ),
            const SizedBox(width: Dimens.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pikolab Engineering',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Your Process Engineering Partner',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: Dimens.spacingMd),
        Text(
          'Get expert support, request quotes, and join our professional community.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildAskExpertCard(ThemeData theme, bool isDark) {
    return _ConnectCard(
      icon: Icons.chat_rounded,
      iconColor: const Color(0xFF25D366), // WhatsApp green
      title: 'Ask an Expert',
      subtitle: 'Get instant support via WhatsApp',
      child: Column(
        children: [
          Text(
            'Have a technical question about your process? '
            'Our engineers are ready to help.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: Dimens.spacingMd),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openWhatsApp,
              icon: const Icon(Icons.chat_bubble_rounded),
              label: const Text('Chat on WhatsApp'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: Dimens.spacingMd,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRfqCard(ThemeData theme, bool isDark) {
    final categories = [
      'Process Analytics',
      'Automation & Control',
      'Industrial Chemicals',
      'Bioprocess Equipment',
      'Other',
    ];

    return _ConnectCard(
      icon: Icons.request_quote_rounded,
      iconColor: AppColors.electricalAccent,
      title: 'Request Quote',
      subtitle: 'Get pricing for equipment & services',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select a category and describe your needs:',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: Dimens.spacingMd),
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: categories.map((cat) {
              return DropdownMenuItem(value: cat, child: Text(cat));
            }).toList(),
            onChanged: (value) => setState(() => _selectedCategory = value),
          ),
          const SizedBox(height: Dimens.spacingMd),
          TextField(
            controller: _messageController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Describe your requirements',
              hintText: 'e.g., pH sensors for bioreactor monitoring...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: Dimens.spacingMd),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  _selectedCategory != null ? _sendRfqEmail : null,
              icon: const Icon(Icons.send_rounded),
              label: const Text('Send Request'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: Dimens.spacingMd,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProCommunityCard(ThemeData theme, bool isDark) {
    return _ConnectCard(
      icon: _isProUser ? Icons.verified_rounded : Icons.workspace_premium,
      iconColor: _isProUser ? Colors.green : const Color(0xFF0A66C2),
      title: _isProUser ? 'Pro Member' : 'Pro Community',
      subtitle: _isProUser
          ? 'You have unlocked pro features!'
          : 'Unlock exclusive insights & features',
      child: Column(
        children: [
          if (_isProUser) ...[
            Container(
              padding: const EdgeInsets.all(Dimens.spacingMd),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Dimens.radiusMd),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: Dimens.spacingSm),
                  Expanded(
                    child: Text(
                      'Thank you for following Pikolab! '
                      'Enjoy exclusive industry insights.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Text(
              'Follow Pikolab on LinkedIn to unlock:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: Dimens.spacingSm),
            _buildProBenefit('Industry insights & best practices'),
            _buildProBenefit('Early access to new calculators'),
            _buildProBenefit('Exclusive webinar invitations'),
            const SizedBox(height: Dimens.spacingMd),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _followOnLinkedIn,
                icon: const Icon(Icons.link),
                label: const Text('Follow on LinkedIn'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A66C2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: Dimens.spacingMd,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimens.spacingXs),
      child: Row(
        children: [
          const Icon(Icons.star, size: 16, color: AppColors.accent),
          const SizedBox(width: Dimens.spacingSm),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildWebsiteFooter(ThemeData theme, bool isDark) {
    return Center(
      child: TextButton.icon(
        onPressed: _openWebsite,
        icon: const Icon(Icons.public),
        label: const Text('Visit pikolab.com'),
      ),
    );
  }

  Future<void> _openWhatsApp() async {
    final analytics = ref.read(analyticsServiceProvider);
    await analytics.logPromoClick(
      promoType: 'whatsapp',
      context: 'pikolab_connect',
    );

    final message = Uri.encodeComponent(
      'Hello Pikolab, I am using QorEng and need support regarding...',
    );
    final url = Uri.parse('https://wa.me/$_whatsappNumber?text=$message');

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      developer.log('Failed to open WhatsApp: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }
  }

  Future<void> _sendRfqEmail() async {
    final analytics = ref.read(analyticsServiceProvider);
    await analytics.logPromoClick(
      promoType: 'rfq',
      context: 'pikolab_connect',
      moduleType: _selectedCategory,
    );

    final subject = Uri.encodeComponent(
      'QorEng Quote Request - $_selectedCategory',
    );
    final body = Uri.encodeComponent(
      'Category: $_selectedCategory\n\n'
      'Requirements:\n${_messageController.text}\n\n'
      '---\nSent from QorEng App',
    );
    final url = Uri.parse('mailto:$_rfqEmail?subject=$subject&body=$body');

    try {
      await launchUrl(url);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening email client...')),
        );
        _messageController.clear();
        setState(() => _selectedCategory = null);
      }
    } catch (e) {
      developer.log('Failed to open email: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email client')),
        );
      }
    }
  }

  Future<void> _followOnLinkedIn() async {
    final analytics = ref.read(analyticsServiceProvider);
    await analytics.logPromoClick(
      promoType: 'linkedin',
      context: 'pikolab_connect',
    );

    final url = Uri.parse(_linkedInUrl);

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);

      // Honor system: Set pro user after returning from LinkedIn
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _isProUser = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Pro features unlocked! Thank you for following.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      developer.log('Failed to open LinkedIn: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open LinkedIn')),
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
}

/// Styled card for connect features.
class _ConnectCard extends StatelessWidget {
  const _ConnectCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: Dimens.elevationMd,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimens.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Dimens.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(Dimens.spacingSm),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(Dimens.radiusMd),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: Dimens.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimens.spacingMd),
            const Divider(),
            const SizedBox(height: Dimens.spacingMd),
            child,
          ],
        ),
      ),
    );
  }
}
