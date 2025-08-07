// lib/pages/home/widgets/alerts/alerts_section.dart

import 'package:association/pages/Home/homepage/widgets/utilis/constants.dart';
import 'package:flutter/material.dart';

class AlertsSection extends StatefulWidget {
  const AlertsSection({Key? key}) : super(key: key);

  @override
  State<AlertsSection> createState() => _AlertsSectionState();
}

class _AlertsSectionState extends State<AlertsSection> {
  // Mock alerts data (same as in your HomePage)
  List<Map<String, dynamic>> _mockAlerts = [
    {
      'title': 'Payment Due Reminder',
      'message': 'Your monthly membership fee is due in 3 days.',
      'time': '2 hours ago',
      'type': 'payment',
      'isRead': false,
    },
    {
      'title': 'New Event Announcement',
      'message': 'Annual General Meeting scheduled for next month.',
      'time': '1 day ago',
      'type': 'event',
      'isRead': false,
    },
    {
      'title': 'System Maintenance',
      'message': 'Scheduled maintenance on Sunday from 2 AM to 4 AM.',
      'time': '2 days ago',
      'type': 'system',
      'isRead': true,
    },
    {
      'title': 'Document Update',
      'message': 'New membership guidelines have been published.',
      'time': '3 days ago',
      'type': 'document',
      'isRead': true,
    },
  ];

  // Filter states
  String _selectedFilter = 'all';
  bool _showOnlyUnread = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterSection(),
        Expanded(
          child: _buildAlertsList(),
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.cardBackground.withOpacity(0.8),
            AppConstants.cardBackgroundSecondary.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppConstants.primaryPurple.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.filter_list,
                color: AppConstants.primaryPurple,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Filter Alerts',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _buildUnreadCountBadge(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFilterChip('all', 'All', Icons.notifications),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip('payment', 'Payment', Icons.payment),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip('event', 'Event', Icons.event),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildFilterChip('system', 'System', Icons.settings),
              ),
              const SizedBox(width: 8),
              Expanded(
                child:
                    _buildFilterChip('document', 'Document', Icons.description),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildUnreadToggle(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterType, String label, IconData icon) {
    final isSelected = _selectedFilter == filterType;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filterType;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    AppConstants.primaryPurple,
                    AppConstants.secondaryPurple
                  ],
                )
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppConstants.primaryPurple
                : Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppConstants.primaryPurple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.white70,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnreadToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showOnlyUnread = !_showOnlyUnread;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          gradient: _showOnlyUnread
              ? const LinearGradient(
                  colors: [
                    AppConstants.primaryPurple,
                    AppConstants.secondaryPurple
                  ],
                )
              : null,
          color: _showOnlyUnread ? null : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _showOnlyUnread
                ? AppConstants.primaryPurple
                : Colors.white.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: _showOnlyUnread
              ? [
                  BoxShadow(
                    color: AppConstants.primaryPurple.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mark_email_unread,
              size: 16,
              color: _showOnlyUnread ? Colors.white : Colors.white70,
            ),
            const SizedBox(width: 6),
            Text(
              'Unread',
              style: TextStyle(
                color: _showOnlyUnread ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight:
                    _showOnlyUnread ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnreadCountBadge() {
    final unreadCount = _mockAlerts.where((alert) => !alert['isRead']).length;

    if (unreadCount == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.red, Colors.redAccent],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        unreadCount.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAlertsList() {
    final filteredAlerts = _getFilteredAlerts();

    if (filteredAlerts.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      physics: const BouncingScrollPhysics(),
      itemCount: filteredAlerts.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: AlertCard(
            alert: filteredAlerts[index],
            onToggleRead: () {
              setState(() {
                final alertIndex = _mockAlerts.indexWhere(
                  (alert) => alert == filteredAlerts[index],
                );
                if (alertIndex != -1) {
                  _mockAlerts[alertIndex]['isRead'] =
                      !_mockAlerts[alertIndex]['isRead'];
                }
              });
            },
            onDelete: () {
              setState(() {
                _mockAlerts.remove(filteredAlerts[index]);
              });
              _showSnackBar('Alert deleted');
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppConstants.primaryPurple.withOpacity(0.2),
                  AppConstants.secondaryPurple.withOpacity(0.2),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppConstants.primaryPurple.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 40,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _getEmptyStateTitle(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _getEmptyStateMessage(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _selectedFilter = 'all';
                _showOnlyUnread = false;
              });
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Reset Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shadowColor: AppConstants.primaryPurple.withOpacity(0.5),
              elevation: 8,
            ),
          ),
        ],
      ),
    );
  }

  String _getEmptyStateTitle() {
    if (_showOnlyUnread) {
      return 'No Unread Alerts';
    }
    if (_selectedFilter != 'all') {
      return 'No ${_selectedFilter.substring(0, 1).toUpperCase()}${_selectedFilter.substring(1)} Alerts';
    }
    return 'No Alerts';
  }

  String _getEmptyStateMessage() {
    if (_showOnlyUnread) {
      return 'Great! You\'ve read all your alerts.\nStay tuned for new updates.';
    }
    if (_selectedFilter != 'all') {
      return 'No alerts found for this category.\nTry selecting a different filter.';
    }
    return 'You\'re all caught up!\nNew alerts will appear here when available.';
  }

  List<Map<String, dynamic>> _getFilteredAlerts() {
    var filtered = List<Map<String, dynamic>>.from(_mockAlerts);

    // Filter by type
    if (_selectedFilter != 'all') {
      filtered =
          filtered.where((alert) => alert['type'] == _selectedFilter).toList();
    }

    // Filter by read status
    if (_showOnlyUnread) {
      filtered = filtered.where((alert) => !alert['isRead']).toList();
    }

    return filtered;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: AppConstants.primaryPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class AlertCard extends StatelessWidget {
  final Map<String, dynamic> alert;
  final VoidCallback onToggleRead;
  final VoidCallback onDelete;

  const AlertCard({
    Key? key,
    required this.alert,
    required this.onToggleRead,
    required this.onDelete,
  }) : super(key: key);

  List<Color> _getAlertColors(String type) {
    switch (type) {
      case 'payment':
        return [Color(0xFFE74C3C), Color(0xFFFF6B6B)];
      case 'event':
        return [AppConstants.primaryPurple, AppConstants.secondaryPurple];
      case 'system':
        return [Color(0xFF17A2B8), Color(0xFF20C997)];
      case 'document':
        return [Color(0xFF28A745), Color(0xFF40E0D0)];
      default:
        return [AppConstants.primaryPurple, AppConstants.secondaryPurple];
    }
  }

  IconData _getAlertIcon(String type) {
    switch (type) {
      case 'payment':
        return Icons.payment;
      case 'event':
        return Icons.event;
      case 'system':
        return Icons.settings;
      case 'document':
        return Icons.description;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isRead = alert['isRead'] ?? false;
    final colors = _getAlertColors(alert['type']);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.cardBackground.withOpacity(0.7),
            AppConstants.cardBackgroundSecondary.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead
              ? Colors.transparent
              : AppConstants.primaryPurple.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Alert Icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(21),
                    boxShadow: [
                      BoxShadow(
                        color: colors[0].withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getAlertIcon(alert['type']),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),

                // Alert Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              alert['title'] ?? 'No Title',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight:
                                    isRead ? FontWeight.w600 : FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppConstants.primaryPurple,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        alert['message'] ?? 'No message',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            alert['time'] ?? '',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(
                              isRead
                                  ? Icons.mark_email_unread
                                  : Icons.mark_email_read,
                              color: Colors.white70,
                              size: 20,
                            ),
                            onPressed: onToggleRead,
                            tooltip: isRead ? 'Mark as Unread' : 'Mark as Read',
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.white70,
                              size: 20,
                            ),
                            onPressed: onDelete,
                            tooltip: 'Delete Alert',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
