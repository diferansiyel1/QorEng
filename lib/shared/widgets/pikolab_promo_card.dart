import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:engicore/core/constants/app_colors.dart';
import 'package:engicore/core/constants/dimens.dart';
import 'package:engicore/core/services/analytics_service.dart';

/// Module type for contextual marketing.
enum PromoModuleType {
  electrical,
  mechanical,
  chemical,
  bioprocess,
}

/// Promo data for each module.
class _PromoData {
  const _PromoData({
    required this.headline,
    required this.cta,
    required this.icon,
    required this.color,
    required this.category,
  });

  final String headline;
  final String cta;
  final IconData icon;
  final Color color;
  final String category;
}

/// Contextual marketing promo card.
///
/// Shows module-specific promotions at the bottom of calculator results.
/// Designed to be helpful, not intrusive.
class PikolabPromoCard extends ConsumerWidget {
  const PikolabPromoCard({
    super.key,
    required this.moduleType,
    this.compact = false,
  });

  final PromoModuleType moduleType;
  final bool compact;

  static const Map<PromoModuleType, _PromoData> _promoMap = {
    PromoModuleType.electrical: _PromoData(
      headline: 'Automation & Control Systems',
      cta: 'Explore Solutions',
      icon: Icons.electrical_services_rounded,
      color: AppColors.electricalAccent,
      category: 'Automation & Control',
    ),
    PromoModuleType.mechanical: _PromoData(
      headline: 'Industrial Pump & Flow Solutions',
      cta: 'Get Quote',
      icon: Icons.precision_manufacturing_rounded,
      color: AppColors.mechanicalAccent,
      category: 'Industrial Equipment',
    ),
    PromoModuleType.chemical: _PromoData(
      headline: 'Process Analytics & Lab Equipment',
      cta: 'Learn More',
      icon: Icons.science_rounded,
      color: AppColors.chemicalAccent,
      category: 'Process Analytics',
    ),
    PromoModuleType.bioprocess: _PromoData(
      headline: 'Need Bioreactor Sensors?',
      cta: 'Get a Quote',
      icon: Icons.biotech_rounded,
      color: AppColors.bioprocessAccent,
      category: 'Bioprocess Equipment',
    ),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final promo = _promoMap[moduleType]!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (compact) {
      return _buildCompactCard(context, ref, promo, theme, isDark);
    }

    return _buildFullCard(context, ref, promo, theme, isDark);
  }

  Widget _buildCompactCard(
    BuildContext context,
    WidgetRef ref,
    _PromoData promo,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: Dimens.spacingMd),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimens.spacingMd,
        vertical: Dimens.spacingSm,
      ),
      decoration: BoxDecoration(
        color: promo.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Dimens.radiusMd),
        border: Border.all(
          color: promo.color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            promo.icon,
            size: 18,
            color: promo.color,
          ),
          const SizedBox(width: Dimens.spacingSm),
          Expanded(
            child: Text(
              promo.headline,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: () => _onPromoTap(context, ref, promo),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimens.spacingSm,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              promo.cta,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: promo.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullCard(
    BuildContext context,
    WidgetRef ref,
    _PromoData promo,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: Dimens.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            promo.color.withValues(alpha: 0.12),
            promo.color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(Dimens.radiusLg),
        border: Border.all(
          color: promo.color.withValues(alpha: 0.25),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onPromoTap(context, ref, promo),
          borderRadius: BorderRadius.circular(Dimens.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(Dimens.spacingMd),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(Dimens.spacingSm),
                  decoration: BoxDecoration(
                    color: promo.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(Dimens.radiusMd),
                  ),
                  child: Icon(
                    promo.icon,
                    color: promo.color,
                    size: Dimens.iconMd,
                  ),
                ),
                const SizedBox(width: Dimens.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimens.spacingXs,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: promo.color.withValues(alpha: 0.2),
                              borderRadius:
                                  BorderRadius.circular(Dimens.radiusSm),
                            ),
                            child: Text(
                              'PIKOLAB',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: promo.color,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        promo.headline,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimens.spacingMd,
                    vertical: Dimens.spacingSm,
                  ),
                  decoration: BoxDecoration(
                    color: promo.color,
                    borderRadius: BorderRadius.circular(Dimens.radiusFull),
                  ),
                  child: Text(
                    promo.cta,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onPromoTap(
    BuildContext context,
    WidgetRef ref,
    _PromoData promo,
  ) async {
    // Log analytics
    final analytics = ref.read(analyticsServiceProvider);
    await analytics.logPromoClick(
      promoType: 'contextual_promo',
      context: moduleType.name,
      moduleType: moduleType.name,
    );

    // Open WhatsApp with pre-filled message
    const whatsappNumber = '+905551234567'; // TODO: Replace
    final message = Uri.encodeComponent(
      'Hello Pikolab, I am interested in ${promo.category}. '
      'I found you through the QorEng app.',
    );
    final url = Uri.parse('https://wa.me/$whatsappNumber?text=$message');

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }
  }
}
