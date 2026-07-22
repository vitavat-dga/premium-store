import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/gold_button.dart';
import '../../widgets/product_image.dart';

class SellerListingFormScreen extends StatefulWidget {
  final SellerListing? listing;

  const SellerListingFormScreen({super.key, this.listing});

  @override
  State<SellerListingFormScreen> createState() => _SellerListingFormScreenState();
}

class _SellerListingFormScreenState extends State<SellerListingFormScreen> {
  static const List<String> _categories = ['Accessories', 'Clothing', 'Pants', 'Shoes', 'Electronics'];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _stockCtrl;

  String? _selectedCategory;
  late MembershipTier _selectedRequiredTier;
  late ListingStatus _selectedStatus;

  Uint8List? _imageBytes;
  late String _existingImageUrl;
  bool _isPickingImage = false;

  bool get _isEditing => widget.listing != null;

  bool get _hasImage => _imageBytes != null || _existingImageUrl.isNotEmpty;

  @override
  void initState() {
    super.initState();
    final listing = widget.listing;
    _nameCtrl = TextEditingController(text: listing?.name ?? '');
    _descriptionCtrl = TextEditingController(text: listing?.description ?? '');
    _priceCtrl = TextEditingController(text: listing != null ? listing.price.toStringAsFixed(0) : '');
    _stockCtrl = TextEditingController(text: listing != null ? listing.stock.toString() : '');
    _imageBytes = listing?.imageBytes;
    _existingImageUrl = listing?.imageUrl ?? '';
    _selectedCategory = listing?.category;
    _selectedRequiredTier = listing?.requiredTier ?? MembershipTier.normal;
    _selectedStatus = listing?.status ?? ListingStatus.active;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descriptionCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() => _isPickingImage = true);
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('The selected image is empty. Choose another image.'),
              backgroundColor: kDarkSurface,
            ),
          );
        }
        return;
      }
      setState(() => _imageBytes = bytes);
    } on PlatformException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message ?? 'Could not access the photo library.'),
            backgroundColor: kDarkSurface,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  void _removePickedImage() {
    setState(() => _imageBytes = null);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final user = state.currentUser;
    if (user == null) {
      return const Scaffold(
        backgroundColor: kDarkBg,
        body: Center(
          child: Text('Please sign in to manage listings.', style: TextStyle(color: kTextPrimary)),
        ),
      );
    }

    final allowedTiers = MembershipTier.values.where((tier) => user.membershipTier.canAccessTier(tier)).toList();
    if (!allowedTiers.contains(_selectedRequiredTier)) {
      _selectedRequiredTier = allowedTiers.last;
    }
    final statusOptions = _isEditing ? ListingStatus.values : const [ListingStatus.active, ListingStatus.draft];

    return Scaffold(
      backgroundColor: kDarkBg,
      appBar: AppBar(title: Text(_isEditing ? 'Edit Listing' : 'Add Listing')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kDarkCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Listing details',
                      style: TextStyle(color: kTextPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your ${user.membershipTier.label} tier supports ${user.membershipTier.sellRangeLabel.toLowerCase()}.',
                      style: const TextStyle(color: kTextSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'Product Name'),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) return 'Product name is required';
                        if (text.length < 3) {
                          return 'Product name must be at least 3 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category'),
                      dropdownColor: kDarkSurface,
                      items: _categories
                          .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedCategory = value),
                      validator: (value) => value == null ? 'Please select a category' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionCtrl,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(labelText: 'Description'),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) return 'Description is required';
                        if (text.length < 10) {
                          return 'Description must be at least 10 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Price (THB)'),
                      validator: (value) {
                        final price = double.tryParse((value ?? '').trim());
                        if (price == null) return 'Enter a valid price';
                        return AppState.validateSellerPrice(price, user.membershipTier);
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Allowed range: ${user.membershipTier.sellRangeLabel}',
                      style: const TextStyle(color: kGoldLight, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _stockCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Stock Quantity'),
                      validator: (value) {
                        final stock = int.tryParse((value ?? '').trim());
                        if (stock == null) {
                          return 'Enter a valid stock quantity';
                        }
                        if (stock < 0) return 'Stock cannot be negative';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<MembershipTier>(
                      initialValue: _selectedRequiredTier,
                      decoration: const InputDecoration(labelText: 'Required Tier'),
                      dropdownColor: kDarkSurface,
                      items: allowedTiers
                          .map((tier) => DropdownMenuItem(value: tier, child: Text(tier.label)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedRequiredTier = value);
                        }
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please choose a required tier';
                        }
                        if (!allowedTiers.contains(value)) {
                          return 'You can only assign tiers up to your membership';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    FormField<bool>(
                      key: ValueKey(_hasImage),
                      validator: (_) => _hasImage ? null : 'Product image is required',
                      builder: (field) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ImagePickerCard(
                            imageBytes: _imageBytes,
                            existingImageUrl: _existingImageUrl,
                            isLoading: _isPickingImage,
                            onPickTap: _pickImage,
                            onRemoveTap: _removePickedImage,
                          ),
                          if (field.hasError)
                            Padding(
                              padding: const EdgeInsets.only(top: 8, left: 4),
                              child: Text(
                                field.errorText!,
                                style: const TextStyle(color: Color(0xFFCF6679), fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Prototype note: images are stored in-memory only and reset on app restart.',
                        style: const TextStyle(color: kTextMuted, fontSize: 11, height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<ListingStatus>(
                      initialValue: statusOptions.contains(_selectedStatus) ? _selectedStatus : ListingStatus.active,
                      decoration: const InputDecoration(labelText: 'Status'),
                      dropdownColor: kDarkSurface,
                      items: statusOptions
                          .map((status) => DropdownMenuItem(value: status, child: Text(status.label)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedStatus = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              GoldButton(
                label: _isEditing ? 'Save Changes' : 'Publish Listing',
                onPressed: () => _submit(context, state, user),
                icon: _isEditing ? Icons.save_outlined : Icons.check_circle_outline,
              ),
              const SizedBox(height: 12),
              GoldButton(label: 'Cancel', onPressed: () => Navigator.pop(context, false), outlined: true),
            ],
          ),
        ),
      ),
    );
  }

  void _submit(BuildContext context, AppState state, AppUser user) {
    if (!_formKey.currentState!.validate()) return;

    final price = double.parse(_priceCtrl.text.trim());
    final stock = int.parse(_stockCtrl.text.trim());
    final nextStatus = stock == 0 && _selectedStatus == ListingStatus.active
        ? ListingStatus.outOfStock
        : _selectedStatus;
    final effectiveImageUrl = _imageBytes != null ? '' : _existingImageUrl;

    if (_isEditing) {
      state.updateSellerListing(
        widget.listing!.copyWith(
          name: _nameCtrl.text.trim(),
          price: price,
          imageUrl: effectiveImageUrl,
          category: _selectedCategory,
          description: _descriptionCtrl.text.trim(),
          requiredTier: _selectedRequiredTier,
          stock: stock,
          status: nextStatus,
          imageBytes: _imageBytes,
        ),
      );
    } else {
      state.addSellerListing(
        SellerListing(
          id: 'sl_${DateTime.now().millisecondsSinceEpoch}',
          sellerId: user.id,
          name: _nameCtrl.text.trim(),
          price: price,
          imageUrl: effectiveImageUrl,
          imageBytes: _imageBytes,
          category: _selectedCategory!,
          description: _descriptionCtrl.text.trim(),
          requiredTier: _selectedRequiredTier,
          stock: stock,
          status: nextStatus,
          createdAt: DateTime.now(),
        ),
      );
    }

    Navigator.pop(context, true);
  }
}

class _ImagePickerCard extends StatelessWidget {
  final Uint8List? imageBytes;
  final String existingImageUrl;
  final bool isLoading;
  final VoidCallback onPickTap;
  final VoidCallback onRemoveTap;

  const _ImagePickerCard({
    required this.imageBytes,
    required this.existingImageUrl,
    required this.isLoading,
    required this.onPickTap,
    required this.onRemoveTap,
  });

  bool get _hasPickedBytes => imageBytes != null;
  bool get _hasNetworkUrl => existingImageUrl.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPickTap,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: kBlack,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (_hasPickedBytes || _hasNetworkUrl) ? kGold : const Color(0xFF3A3A3A),
            width: (_hasPickedBytes || _hasNetworkUrl) ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: kGold, strokeWidth: 2))
            : _hasPickedBytes
            ? _PreviewWithActions(imageBytes: imageBytes!, onChangeTap: onPickTap, onRemoveTap: onRemoveTap)
            : _hasNetworkUrl
            ? _NetworkPreviewWithChange(imageUrl: existingImageUrl, onChangeTap: onPickTap)
            : _EmptyPlaceholder(onPickTap: onPickTap),
      ),
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  final VoidCallback onPickTap;
  const _EmptyPlaceholder({required this.onPickTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(color: kGold.withAlpha(30), shape: BoxShape.circle),
          child: const Icon(Icons.add_photo_alternate_outlined, color: kGold, size: 28),
        ),
        const SizedBox(height: 12),
        const Text(
          'Tap to add a product photo',
          style: TextStyle(color: kTextPrimary, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        const Text('Choose from your photo library', style: TextStyle(color: kTextSecondary, fontSize: 12)),
      ],
    );
  }
}

class _PreviewWithActions extends StatelessWidget {
  final Uint8List imageBytes;
  final VoidCallback onChangeTap;
  final VoidCallback onRemoveTap;

  const _PreviewWithActions({required this.imageBytes, required this.onChangeTap, required this.onRemoveTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ProductImage(imageBytes: imageBytes, imageUrl: ''),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kBlack.withAlpha(210), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ActionChip(icon: Icons.photo_library_outlined, label: 'Change photo', onTap: onChangeTap),
                ),
                const SizedBox(width: 8),
                _ActionChip(icon: Icons.close, label: 'Remove', onTap: onRemoveTap, isDestructive: true),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NetworkPreviewWithChange extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onChangeTap;

  const _NetworkPreviewWithChange({required this.imageUrl, required this.onChangeTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ProductImage(imageUrl: imageUrl),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kBlack.withAlpha(210), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            child: Row(
              children: [_ActionChip(icon: Icons.photo_library_outlined, label: 'Change photo', onTap: onChangeTap)],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionChip({required this.icon, required this.label, required this.onTap, this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.redAccent : kGold;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: kBlack.withAlpha(200),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(150)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
