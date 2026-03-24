import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../theme/app_theme.dart';

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late TextEditingController _authorController;
  late TextEditingController _locationController;
  NewsSortOrder? _selectedSort;

  @override
  void initState() {
    super.initState();
    final provider = context.read<NewsProvider>();

    _authorController = TextEditingController(text: provider.filterAuthor);
    _locationController = TextEditingController(text: provider.filterLocation);
    _selectedSort = provider.sortOrder;
  }

  @override
  void dispose() {
    _authorController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    context.read<NewsProvider>().applyFilters(
          author: _authorController.text.trim(),
          location: _locationController.text.trim(),
          sort: _selectedSort,
        );
    Navigator.pop(context);
  }

  void _clearAll() {
    _authorController.clear();
    _locationController.clear();
    setState(() => _selectedSort = null);
    context.read<NewsProvider>().clearFilters();
    Navigator.pop(context);
  }

  Widget _inputField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final sw = size.width;
    final sh = size.height;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.all(sw * 0.05),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: sw * 0.1,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: sh * 0.02),
            Text(
              'Filter Articles',
              style: TextStyle(
                fontSize: sw * 0.055,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: sh * 0.025),
            Text(
              'Sort by Date',
              style: TextStyle(
                fontSize: sw * 0.045,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            SizedBox(height: sh * 0.015),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Newest First')),
                    selected: _selectedSort == NewsSortOrder.newest,
                    onSelected: (val) => setState(
                      () => _selectedSort =
                          val ? NewsSortOrder.newest : null,
                    ),
                  ),
                ),
                SizedBox(width: sw * 0.03),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(child: Text('Oldest First')),
                    selected: _selectedSort == NewsSortOrder.oldest,
                    onSelected: (val) => setState(
                      () => _selectedSort =
                          val ? NewsSortOrder.oldest : null,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: sh * 0.025),
            _inputField(
              _authorController,
              'Author',
              'e.g. Paul Krugman, Maggie Haberman...',
              Icons.person_outline_rounded,
            ),
            SizedBox(height: sh * 0.018),
            _inputField(
              _locationController,
              'Location',
              'e.g. India, New York...',
              Icons.location_on_rounded,
            ),
            SizedBox(height: sh * 0.03),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clearAll,
                    child: const Text('Clear All'),
                  ),
                ),
                SizedBox(width: sw * 0.04),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: AppTheme.primaryButtonStyle(
                        context, sw, sh),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}