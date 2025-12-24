import 'package:flutter/material.dart';

class SortBottomSheet extends StatefulWidget {
  final String? currentSortBy;
  final String? currentSortOrder;
  final Function(String sortBy, String sortOrder) onSortChanged;

  const SortBottomSheet({
    super.key,
    this.currentSortBy,
    this.currentSortOrder,
    required this.onSortChanged,
  });

  @override
  State<SortBottomSheet> createState() => _SortBottomSheetState();
}

class _SortBottomSheetState extends State<SortBottomSheet> {
  String _selectedSortBy = 'created_at';
  String _selectedSortOrder = 'desc';

  final List<SortOption> _sortOptions = [
    SortOption(
      key: 'created_at',
      title: 'Date Listed',
      subtitle: 'Sort by when auction was created',
      icon: Icons.schedule,
    ),
    SortOption(
      key: 'end_time',
      title: 'Ending Soon',
      subtitle: 'Sort by auction end time',
      icon: Icons.timer,
    ),
    SortOption(
      key: 'current_price',
      title: 'Price',
      subtitle: 'Sort by current bid amount',
      icon: Icons.attach_money,
    ),
    SortOption(
      key: 'bid_count',
      title: 'Most Bids',
      subtitle: 'Sort by number of bids',
      icon: Icons.gavel,
    ),
    SortOption(
      key: 'view_count',
      title: 'Most Popular',
      subtitle: 'Sort by number of views',
      icon: Icons.visibility,
    ),
    SortOption(
      key: 'watch_count',
      title: 'Most Watched',
      subtitle: 'Sort by watchlist count',
      icon: Icons.favorite,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedSortBy = widget.currentSortBy ?? 'created_at';
    _selectedSortOrder = widget.currentSortOrder ?? 'desc';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Sort Auctions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Sort Options
          ..._sortOptions.map((option) => _buildSortOption(option)),
          
          const SizedBox(height: 16),
          
          // Sort Order
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sort Order',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildSortOrderOption(
                          'desc',
                          'Descending',
                          _getSortOrderDescription('desc'),
                          Icons.arrow_downward,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSortOrderOption(
                          'asc',
                          'Ascending',
                          _getSortOrderDescription('asc'),
                          Icons.arrow_upward,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Apply Button
          ElevatedButton(
            onPressed: () {
              widget.onSortChanged(_selectedSortBy, _selectedSortOrder);
              Navigator.of(context).pop();
            },
            child: const Text('Apply Sort'),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSortOption(SortOption option) {
    final theme = Theme.of(context);
    final isSelected = _selectedSortBy == option.key;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: RadioListTile<String>(
        value: option.key,
        groupValue: _selectedSortBy,
        onChanged: (value) {
          setState(() {
            _selectedSortBy = value!;
          });
        },
        title: Row(
          children: [
            Icon(
              option.icon,
              size: 20,
              color: isSelected 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 12),
            Text(
              option.title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? theme.colorScheme.primary : null,
              ),
            ),
          ],
        ),
        subtitle: Text(
          option.subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        activeColor: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildSortOrderOption(
    String value,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final isSelected = _selectedSortOrder == value;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedSortOrder = value;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected 
                ? theme.colorScheme.primary 
                : theme.colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected 
              ? theme.colorScheme.primaryContainer.withOpacity(0.3)
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? theme.colorScheme.primary : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getSortOrderDescription(String order) {
    switch (_selectedSortBy) {
      case 'created_at':
        return order == 'desc' ? 'Newest first' : 'Oldest first';
      case 'end_time':
        return order == 'asc' ? 'Ending soonest' : 'Ending latest';
      case 'current_price':
        return order == 'desc' ? 'Highest first' : 'Lowest first';
      case 'bid_count':
      case 'view_count':
      case 'watch_count':
        return order == 'desc' ? 'Most first' : 'Least first';
      default:
        return order == 'desc' ? 'High to low' : 'Low to high';
    }
  }
}

class SortOption {
  final String key;
  final String title;
  final String subtitle;
  final IconData icon;

  const SortOption({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
