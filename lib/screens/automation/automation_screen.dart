import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/automation_provider.dart';
import '../../models/automation.dart';

class AutomationScreen extends StatelessWidget {
  const AutomationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Automation & Scenes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to create automation screen
            },
          ),
        ],
      ),
      body: Consumer<AutomationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Leave Home Quick Action
              _QuickActionCard(
                title: 'Leave Home',
                icon: Icons.exit_to_app,
                color: Colors.orange,
                onTap: () {
                  provider.executeAutomation('leave-home');
                },
              ),

              const SizedBox(height: 16),

              // Arrive Home Quick Action
              _QuickActionCard(
                title: 'Arrive Home',
                icon: Icons.home,
                color: Colors.green,
                onTap: () {
                  provider.executeAutomation('arrive-home');
                },
              ),

              const SizedBox(height: 32),

              // Energy Save Mode
              _ModeCard(
                title: 'Energy Save Mode',
                icon: Icons.eco,
                color: Colors.teal,
                description: 'Reduce energy consumption',
                isActive: false,
                onToggle: (value) {
                  // Toggle energy save mode
                },
              ),

              const SizedBox(height: 24),

              // Scheduled Automations
              _SectionHeader(title: 'Scheduled Routines'),
              ...provider.getAutomationsByType(AutomationType.schedule)
                  .map((automation) => _AutomationCard(automation: automation)),

              const SizedBox(height: 24),

              // Custom Scenes
              _SectionHeader(title: 'Custom Scenes'),
              ...provider.getAutomationsByType(AutomationType.scene)
                  .map((automation) => _AutomationCard(automation: automation)),
            ],
          );
        },
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String description;
  final bool isActive;
  final ValueChanged<bool> onToggle;

  const _ModeCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
    required this.isActive,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Switch(
              value: isActive,
              onChanged: onToggle,
              activeColor: color,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class _AutomationCard extends StatelessWidget {
  final Automation automation;

  const _AutomationCard({required this.automation});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(
                color: automation.isEnabled ? Colors.green : Colors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    automation.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (automation.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      automation.description!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            
            // Action buttons
            IconButton(
              icon: Icon(
                automation.isEnabled ? Icons.pause : Icons.play_arrow,
                color: automation.isEnabled ? Colors.orange : Colors.green,
              ),
              onPressed: () {
                Provider.of<AutomationProvider>(context, listen: false)
                    .toggleAutomation(automation.id);
              },
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Show options menu
              },
            ),
          ],
        ),
      ),
    );
  }
}

