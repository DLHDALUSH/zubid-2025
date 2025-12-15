import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/auction.dart';
import '../../providers/auction_provider.dart';
import '../../theme/app_theme.dart';

class AddAuctionScreen extends StatefulWidget {
  final Auction? auction;
  const AddAuctionScreen({super.key, this.auction});

  @override
  State<AddAuctionScreen> createState() => _AddAuctionScreenState();
}

class _AddAuctionScreenState extends State<AddAuctionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startingPriceController = TextEditingController();
  final _buyNowPriceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _videoUrlController = TextEditingController();
  int? _selectedCategoryId;
  DateTime _endTime = DateTime.now().add(const Duration(days: 7));
  final List<String> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    if (widget.auction != null) {
      _titleController.text = widget.auction!.title;
      _descriptionController.text = widget.auction!.description;
      _startingPriceController.text = widget.auction!.startingPrice.toString();
      _buyNowPriceController.text = widget.auction!.buyNowPrice?.toString() ?? '';
      _selectedCategoryId = widget.auction!.categoryId;
      _endTime = widget.auction!.endTime;
      _imageUrls.addAll(widget.auction!.images);
      if (widget.auction!.imageUrl != null && !_imageUrls.contains(widget.auction!.imageUrl)) {
        _imageUrls.insert(0, widget.auction!.imageUrl!);
      }
    }
    context.read<AuctionProvider>().loadCategories();
  }

  void _addImage() {
    final url = _imageUrlController.text.trim();
    if (url.isNotEmpty) {
      setState(() => _imageUrls.add(url));
      _imageUrlController.clear();
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final startingPrice = double.parse(_startingPriceController.text);
      final buyNowPrice = _buyNowPriceController.text.isNotEmpty
          ? double.parse(_buyNowPriceController.text)
          : null;

      final auctionProvider = context.read<AuctionProvider>();

      final success = await auctionProvider.createAuction(
        itemName: _titleController.text,
        description: _descriptionController.text,
        startingBid: startingPrice,
        endTime: _endTime,
        categoryId: _selectedCategoryId,
        realPrice: buyNowPrice,
        images: _imageUrls.isNotEmpty ? _imageUrls : null,
        videoUrl: _videoUrlController.text.isNotEmpty ? _videoUrlController.text : null,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Auction created successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(auctionProvider.error ?? 'Failed to create auction'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<AuctionProvider>().categories;

    return Scaffold(
      appBar: AppBar(title: Text(widget.auction != null ? 'Edit Auction' : 'Add Auction')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title *'),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description *'),
              maxLines: 4,
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _startingPriceController,
                    decoration: const InputDecoration(labelText: 'Starting Price *', prefixText: '\$ '),
                    keyboardType: TextInputType.number,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _buyNowPriceController,
                    decoration: const InputDecoration(labelText: 'Buy Now Price', prefixText: '\$ '),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _selectedCategoryId,
              decoration: const InputDecoration(labelText: 'Category'),
              items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
              onChanged: (v) => setState(() => _selectedCategoryId = v),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('End Time'),
              subtitle: Text('${_endTime.day}/${_endTime.month}/${_endTime.year} ${_endTime.hour}:${_endTime.minute}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(context: context, initialDate: _endTime, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                if (date != null && mounted && context.mounted) {
                  final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_endTime));
                  if (time != null && mounted && context.mounted) {
                    setState(() => _endTime = DateTime(date.year, date.month, date.day, time.hour, time.minute));
                  }
                }
              },
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text('Images', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: TextField(controller: _imageUrlController, decoration: const InputDecoration(hintText: 'Image URL'))),
                IconButton(onPressed: _addImage, icon: const Icon(Icons.add_circle, color: AppColors.primary)),
              ],
            ),
            if (_imageUrls.isNotEmpty)
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imageUrls.length,
                  itemBuilder: (_, i) => Stack(
                    children: [
                      Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 8, top: 8),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), image: DecorationImage(image: NetworkImage(_imageUrls[i]), fit: BoxFit.cover)),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => setState(() => _imageUrls.removeAt(i)),
                          child: const CircleAvatar(radius: 12, backgroundColor: Colors.red, child: Icon(Icons.close, size: 14, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            TextFormField(controller: _videoUrlController, decoration: const InputDecoration(labelText: 'Video URL (optional)', prefixIcon: Icon(Icons.videocam))),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: Text(widget.auction != null ? 'Update Auction' : 'Create Auction'),
            ),
          ],
        ),
      ),
    );
  }
}

