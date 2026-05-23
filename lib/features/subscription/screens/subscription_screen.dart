import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloudwebx_pdftool/core/utils/logger.dart';

/// Subscription Management

enum SubscriptionPlan { free, basic, premium, enterprise }

class SubscriptionDetails {
  final SubscriptionPlan plan;
  final double monthlyPrice;
  final double yearlyPrice;
  final List<String> features;
  final int maxFileSizeMB;
  final int maxStorageGB;
  final bool hasAI;
  final bool hasOCR;
  final bool hasAdvancedTools;
  final bool priority;

  SubscriptionDetails({
    required this.plan,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.features,
    required this.maxFileSizeMB,
    required this.maxStorageGB,
    required this.hasAI,
    required this.hasOCR,
    required this.hasAdvancedTools,
    required this.priority,
  });

  static Map<SubscriptionPlan, SubscriptionDetails> all = {
    SubscriptionPlan.free: SubscriptionDetails(
      plan: SubscriptionPlan.free,
      monthlyPrice: 0,
      yearlyPrice: 0,
      maxFileSizeMB: 50,
      maxStorageGB: 2,
      hasAI: false,
      hasOCR: false,
      hasAdvancedTools: false,
      priority: false,
      features: [
        'PDF Reader & Viewer',
        'Basic PDF Editor',
        'File Manager',
        '2 GB Storage',
        'Limited Conversions',
      ],
    ),
    SubscriptionPlan.basic: SubscriptionDetails(
      plan: SubscriptionPlan.basic,
      monthlyPrice: 9.99,
      yearlyPrice: 99.99,
      maxFileSizeMB: 200,
      maxStorageGB: 50,
      hasAI: false,
      hasOCR: true,
      hasAdvancedTools: true,
      priority: false,
      features: [
        'Everything in Free',
        'Unlimited Conversions',
        'OCR Scanner',
        'E-Signature',
        '50 GB Storage',
        'Advanced PDF Tools',
      ],
    ),
    SubscriptionPlan.premium: SubscriptionDetails(
      plan: SubscriptionPlan.premium,
      monthlyPrice: 19.99,
      yearlyPrice: 199.99,
      maxFileSizeMB: 500,
      maxStorageGB: 200,
      hasAI: true,
      hasOCR: true,
      hasAdvancedTools: true,
      priority: true,
      features: [
        'Everything in Basic',
        'AI PDF Summary',
        'AI Chat with PDF',
        'AI Extract Points',
        'AI Generate MCQs',
        '200 GB Storage',
        'Priority Support',
      ],
    ),
    SubscriptionPlan.enterprise: SubscriptionDetails(
      plan: SubscriptionPlan.enterprise,
      monthlyPrice: 49.99,
      yearlyPrice: 499.99,
      maxFileSizeMB: 1000,
      maxStorageGB: 1000,
      hasAI: true,
      hasOCR: true,
      hasAdvancedTools: true,
      priority: true,
      features: [
        'Everything in Premium',
        'Unlimited Storage',
        'Team Management',
        'Advanced Analytics',
        'API Access',
        'Dedicated Support',
        'Custom Branding',
      ],
    ),
  };
}

/// Subscription State Management
class SubscriptionState {
  final SubscriptionPlan currentPlan;
  final DateTime? renewalDate;
  final bool autoRenew;
  final bool isLoading;

  SubscriptionState({
    required this.currentPlan,
    this.renewalDate,
    this.autoRenew = true,
    this.isLoading = false,
  });

  SubscriptionState copyWith({
    SubscriptionPlan? currentPlan,
    DateTime? renewalDate,
    bool? autoRenew,
    bool? isLoading,
  }) {
    return SubscriptionState(
      currentPlan: currentPlan ?? this.currentPlan,
      renewalDate: renewalDate ?? this.renewalDate,
      autoRenew: autoRenew ?? this.autoRenew,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  return SubscriptionNotifier();
});

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  SubscriptionNotifier()
      : super(SubscriptionState(
          currentPlan: SubscriptionPlan.free,
        ));

  Future<void> upgradePlan(SubscriptionPlan plan, {bool isYearly = false}) async {
    state = state.copyWith(isLoading: true);

    try {
      // TODO: Integrate with Google Play Billing
      AppLogger.info('Upgrading to ${plan.name} plan');

      final renewalDate =
          DateTime.now().add(Duration(days: isYearly ? 365 : 30));

      state = state.copyWith(
        currentPlan: plan,
        renewalDate: renewalDate,
        isLoading: false,
      );

      AppLogger.info('Plan upgraded successfully');
    } catch (e) {
      AppLogger.error('Failed to upgrade plan', e);
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> cancelSubscription() async {
    state = state.copyWith(isLoading: true);

    try {
      AppLogger.info('Cancelling subscription');

      state = state.copyWith(
        currentPlan: SubscriptionPlan.free,
        autoRenew: false,
        isLoading: false,
      );

      AppLogger.info('Subscription cancelled');
    } catch (e) {
      AppLogger.error('Failed to cancel subscription', e);
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> toggleAutoRenew() async {
    try {
      final newAutoRenew = !state.autoRenew;
      state = state.copyWith(autoRenew: newAutoRenew);

      // TODO: Update in Firebase
      AppLogger.info('Auto-renew toggled: $newAutoRenew');
    } catch (e) {
      AppLogger.error('Failed to toggle auto-renew', e);
      rethrow;
    }
  }
}

/// Subscription Screen
class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  bool _isYearly = false;

  @override
  Widget build(BuildContext context) {
    final subscription = ref.watch(subscriptionProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('Upgrade Plan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Billing Toggle
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildToggleButton('Monthly', !_isYearly, () {
                      setState(() => _isYearly = false);
                    }),
                    _buildToggleButton('Yearly', _isYearly, () {
                      setState(() => _isYearly = true);
                    }),
                  ],
                ),
              ),
            ),
            if (_isYearly)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B894).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF00B894)),
                    ),
                    child: const Text(
                      'Save 20% with yearly plan',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF00B894),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 32),
            // Plans
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: SubscriptionPlan.values.map((plan) {
                final details = SubscriptionDetails.all[plan]!;
                final isCurrent = subscription.currentPlan == plan;

                return _buildPlanCard(
                  context,
                  details,
                  _isYearly,
                  isCurrent,
                  isDark,
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            // Current Subscription Info
            if (subscription.currentPlan != SubscriptionPlan.free) ...[
              Text(
                'Current Subscription',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[850] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Plan: ${subscription.currentPlan.name.toUpperCase()}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Chip(
                          label: const Text('Active'),
                          backgroundColor: const Color(0xFF00B894),
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (subscription.renewalDate != null)
                      Text(
                        'Renews on ${subscription.renewalDate!.toString().split(' ')[0]}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      value: subscription.autoRenew,
                      onChanged: (_) {
                        ref
                            .read(subscriptionProvider.notifier)
                            .toggleAutoRenew();
                      },
                      title: const Text('Auto-renew'),
                      dense: true,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? const Color(0xFF6C5CE7) : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    SubscriptionDetails details,
    bool isYearly,
    bool isCurrent,
    bool isDark,
  ) {
    final price = isYearly ? details.yearlyPrice : details.monthlyPrice;

    return GestureDetector(
      onTap: isCurrent
          ? null
          : () {
              ref.read(subscriptionProvider.notifier).upgradePlan(
                    details.plan,
                    isYearly: isYearly,
                  );
            },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCurrent
              ? const Color(0xFF6C5CE7).withOpacity(0.1)
              : isDark
                  ? Colors.grey[850]
                  : Colors.grey[100],
          border: Border.all(
            color: isCurrent ? const Color(0xFF6C5CE7) : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  details.plan.name.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  price == 0
                      ? 'Free'
                      : '\$${price.toStringAsFixed(0)}${isYearly ? '/yr' : '/mo'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            if (isCurrent)
              Chip(
                label: const Text('Current'),
                backgroundColor: const Color(0xFF6C5CE7),
                labelStyle: const TextStyle(color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}
