import 'package:flutter/material.dart';
import '../../data/models/auction_search_filters.dart';
import '../../data/models/category_model.dart';

class FilterBottomSheet extends StatefulWidget {
  final AuctionSearchFilters currentFilters;
  final List<CategoryModel> categories;
  final Function(AuctionSearchFilters) onFiltersChanged;

  const FilterBottomSheet({
    super.key,
    required this.currentFilters,
    required this.categories,
    required this.onFiltersChanged,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late AuctionSearchFilters _filters;
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filters = widget.currentFilters;
    _minPriceController.text = _filters.minPrice?.toString() ?? '';
    _maxPriceController.text = _filters.maxPrice?.toString() ?? '';
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Filter Auctions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearAllFilters,
                child: const Text('Clear All'),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Filters Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Category Filter
                  _buildCategoryFilter(),
                  
                  const SizedBox(height: 24),
                  
                  // Price Range Filter
                  _buildPriceRangeFilter(),
                  
                  const SizedBox(height: 24),
                  
                  // Auction Type Filters
                  _buildAuctionTypeFilters(),
                  
                  const SizedBox(height: 24),
                  
                  // Condition Filter
                  _buildConditionFilter(),
                  
                  const SizedBox(height: 24),
                  
                  // Special Filters
                  _buildSpecialFilters(),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Apply Button
          ElevatedButton(
            onPressed: () {
              // Update price filters from text controllers
              final minPrice = double.tryParse(_minPriceController.text);
              final maxPrice = double.tryParse(_maxPriceController.text);
              
              final updatedFilters = _filters.copyWith(
                minPrice: minPrice,
                maxPrice: maxPrice,
              );
              
              widget.onFiltersChanged(updatedFilters);
              Navigator.of(context).pop();
            },
            child: Text('Apply Filters (${_getActiveFilterCount()})'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 12),
            
            DropdownButtonFormField<int?>(
              value: _filters.categoryId,
              decoration: const InputDecoration(
                hintText: 'All Categories',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('All Categories'),
                ),
                ...widget.categories.map((category) => DropdownMenuItem<int?>(
                  value: category.id,
                  child: Text(category.name),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _filters = _filters.copyWith(categoryId: value);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRangeFilter() {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price Range',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Min Price',
                      prefixText: '\$',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _maxPriceController,
                    decoration: const InputDecoration(
                      labelText: 'Max Price',
                      prefixText: '\$',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuctionTypeFilters() {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Auction Type',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 12),
            
            CheckboxListTile(
              title: const Text('Has Buy Now'),
              subtitle: const Text('Auctions with instant purchase option'),
              value: _filters.hasBuyNow ?? false,
              onChanged: (value) {
                setState(() {
                  _filters = _filters.copyWith(hasBuyNow: value);
                });
              },
            ),
            
            CheckboxListTile(
              title: const Text('Has Reserve'),
              subtitle: const Text('Auctions with reserve price'),
              value: _filters.hasReserve ?? false,
              onChanged: (value) {
                setState(() {
                  _filters = _filters.copyWith(hasReserve: value);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionFilter() {
    final theme = Theme.of(context);
    final conditions = ['New', 'Like New', 'Good', 'Fair', 'Poor'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Condition',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 12),
            
            DropdownButtonFormField<String?>(
              value: _filters.condition,
              decoration: const InputDecoration(
                hintText: 'Any Condition',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Any Condition'),
                ),
                ...conditions.map((condition) => DropdownMenuItem<String?>(
                  value: condition,
                  child: Text(condition),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  _filters = _filters.copyWith(condition: value);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialFilters() {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Special Filters',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 12),
            
            CheckboxListTile(
              title: const Text('Ending Soon'),
              subtitle: const Text('Auctions ending within 24 hours'),
              value: _filters.endingSoon ?? false,
              onChanged: (value) {
                setState(() {
                  _filters = _filters.copyWith(endingSoon: value);
                });
              },
            ),
            
            CheckboxListTile(
              title: const Text('Newly Listed'),
              subtitle: const Text('Auctions listed within 24 hours'),
              value: _filters.newlyListed ?? false,
              onChanged: (value) {
                setState(() {
                  _filters = _filters.copyWith(newlyListed: value);
                });
              },
            ),
            
            CheckboxListTile(
              title: const Text('Featured Only'),
              subtitle: const Text('Show only featured auctions'),
              value: _filters.featuredOnly ?? false,
              onChanged: (value) {
                setState(() {
                  _filters = _filters.copyWith(featuredOnly: value);
                });
              },
            ),
            
            CheckboxListTile(
              title: const Text('Watched Only'),
              subtitle: const Text('Show only auctions in your watchlist'),
              value: _filters.watchedOnly ?? false,
              onChanged: (value) {
                setState(() {
                  _filters = _filters.copyWith(watchedOnly: value);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _filters = AuctionSearchFilters.empty;
      _minPriceController.clear();
      _maxPriceController.clear();
    });
  }

  int _getActiveFilterCount() {
    int count = _filters.activeFilterCount;
    
    // Add price filters if they have values
    if (_minPriceController.text.isNotEmpty) count++;
    if (_maxPriceController.text.isNotEmpty) count++;
    
    return count;
  }
}
