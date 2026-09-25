import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myexpence/core/theme/app_theme.dart';
import 'package:myexpence/features/auth/presentation/providers/auth_providers.dart';
import 'package:myexpence/features/sms_parser/presentation/providers/sms_whitelist_provider.dart';
import 'package:myexpence/features/sms_parser/presentation/widgets/sms_approval_dialog.dart';
import 'package:myexpence/features/subscription/presentation/providers/subscription_providers.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sub = ref.watch(subscriptionProvider);
    final authUser = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('More & Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Google Profile & Account Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          (authUser.displayName ?? authUser.email ?? 'G')[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authUser.displayName ?? 'Google User',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              authUser.email ?? 'Not logged in',
                              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (authUser.isLoggedIn) ...[
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Sign Out Button
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[800],
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: () async {
                            await ref.read(authProvider.notifier).signOut();
                            if (context.mounted) {
                              context.go('/login');
                            }
                          },
                          icon: const Icon(Icons.logout, size: 16),
                          label: const Text('Sign Out'),
                        ),

                        // Delete Account Button
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[50],
                            foregroundColor: Colors.red[700],
                            elevation: 0,
                            visualDensity: VisualDensity.compact,
                          ),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete Account?'),
                                  ],
                                ),
                                content: const Text(
                                  'Are you sure you want to delete your account? This will permanently remove your stored user session and sign you out of MyExpense.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Delete Account'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await ref.read(authProvider.notifier).deleteAccount();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Account deleted successfully.')),
                                );
                                context.go('/login');
                              }
                            }
                          },
                          icon: const Icon(Icons.delete_forever, size: 16),
                          label: const Text('Delete Account'),
                        ),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('Sign In with Google'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Subscription Status / Upgrade Banner
          Card(
            color: sub.isPremium ? Colors.amber.withOpacity(0.12) : AppTheme.primaryColor.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: sub.isPremium ? Colors.amber : AppTheme.primaryColor),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Icon(
                Icons.workspace_premium,
                size: 36,
                color: sub.isPremium ? Colors.amber : AppTheme.primaryColor,
              ),
              title: Text(
                sub.isPremium ? 'MyExpense Premium Active (${sub.tier.title})' : 'Upgrade to Premium (\$2.99/mo or \$15/yr)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(
                sub.isPremium
                    ? 'Unlimited OCR Scanning, Geofencing & Cloud Sync Active'
                    : 'Monthly (\$2.99/mo) or Yearly (\$15.00/yr) • Unlock Cloud Sync, OCR & Geofencing',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: sub.isPremium ? Colors.amber : AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => context.push('/paywall'),
                child: Text(sub.isPremium ? 'Manage' : 'Upgrade'),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet, color: AppTheme.primaryColor),
                  title: const Text('Monthly & Category Budgets', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Set monthly limits and receive alert warnings'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/budgets'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.calendar_month, color: AppTheme.primaryColor),
                  title: const Text('Expense Calendar', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('View daily spending grid, missing days, and zero-spend log'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/calendar'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.people, color: AppTheme.primaryColor),
                  title: const Text('Family Members & Profiles', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Manage household members and student profiles'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/people'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.category, color: AppTheme.primaryColor),
                  title: const Text('Categories & Subcategories', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('View and configure default spending taxonomy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/categories'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.location_on, color: AppTheme.primaryColor),
                  title: const Text('Location Reminders & Geofencing', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Marts, Petrol Pumps & Hospital post-visit prompts'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/location-notifications'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Bank SMS Whitelist & Auto-Parse Approval Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.sms, color: AppTheme.primaryColor),
                      SizedBox(width: 8),
                      Text('Bank SMS Whitelist & Auto-Parse', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SMS from these whitelisted bank numbers are automatically parsed with user approval:',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 10),

                  // Whitelisted Senders Chips
                  Consumer(
                    builder: (context, ref, _) {
                      final whitelist = ref.watch(smsWhitelistProvider);
                      return Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          ...whitelist.map((sender) {
                            return Chip(
                              avatar: const Icon(Icons.verified, size: 14, color: Colors.green),
                              label: Text(sender, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              backgroundColor: Colors.green.withValues(alpha: 0.1),
                              deleteIcon: const Icon(Icons.cancel, size: 14),
                              onDeleted: () {
                                ref.read(smsWhitelistProvider.notifier).removeSender(sender);
                              },
                              visualDensity: VisualDensity.compact,
                            );
                          }),
                          ActionChip(
                            avatar: const Icon(Icons.add, size: 14, color: AppTheme.primaryColor),
                            label: const Text('Add Sender', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            onPressed: () async {
                              final textController = TextEditingController();
                              final newSender = await showDialog<String>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Add Bank Sender ID'),
                                  content: TextField(
                                    controller: textController,
                                    decoration: const InputDecoration(
                                      labelText: 'Sender ID / Shortcode *',
                                      hintText: 'e.g. MeezanBank, 8257, HBL',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, textController.text.trim()),
                                      child: const Text('Add'),
                                    ),
                                  ],
                                ),
                              );

                              if (newSender != null && newSender.isNotEmpty) {
                                await ref.read(smsWhitelistProvider.notifier).addSender(newSender);
                              }
                            },
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // 1-Tap Trigger Button for SMS Approval
                  Consumer(
                    builder: (context, ref, _) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            const sampleSms = 'Your A/C 4589 debited by Rs 3,500.00 at POS SHELL PETROL PUMP on 24-SEP-26. Avail Bal: Rs 14,200.';
                            await showSmsApprovalDialog(
                              context,
                              ref,
                              rawSms: sampleSms,
                              sender: 'MeezanBank',
                            );
                          },
                          icon: const Icon(Icons.bolt, size: 16),
                          label: const Text('⚡ Receive Whitelisted Bank SMS & Approve to DB', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cloud_sync, color: AppTheme.primaryColor),
                  title: const Text('Encrypted Cloud Sync & Backup', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('🔒 Subscription Required (Premium Only)'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                    child: const Text('PREMIUM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber)),
                  ),
                  onTap: () => context.push('/paywall', extra: 'Cloud Backup & Sync'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.security, color: Colors.blue),
                  title: const Text('Offline-First Security'),
                  subtitle: const Text('All financial records remain local to your device by default'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline, color: Colors.grey),
                  title: const Text('MyExpense Version'),
                  subtitle: const Text('1.3.0 (Freemium Subscription Ready)'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
