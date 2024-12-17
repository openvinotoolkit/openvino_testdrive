// Copyright 2024 Intel Corporation.
// SPDX-License-Identifier: Apache-2.0

import 'package:fluent_ui/fluent_ui.dart';

class DropdownMultipleSelect extends StatefulWidget {
  final List<String> items;
  final List<String> selectedItems;
  final ValueChanged<List<String>> onChanged;
  final String placeholder;
  final bool showSelectedItemsInTitle;

  const DropdownMultipleSelect({
    super.key,
    required this.items,
    required this.selectedItems,
    required this.onChanged,
    this.placeholder = 'Select items',
    this.showSelectedItemsInTitle = false,
  });

  @override
  _DropdownMultipleSelectState createState() => _DropdownMultipleSelectState();
}

class _DropdownMultipleSelectState extends State<DropdownMultipleSelect> {
  late List<String> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = widget.selectedItems;
  }

  void _onItemTapped(String item) {
    setState(() {
      if (_selectedItems.contains(item)) {
        _selectedItems.remove(item);
      } else {
        _selectedItems.add(item);
      }
      widget.onChanged(_selectedItems);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropDownButton(
      items: widget.items.map((item) {
        return MenuFlyoutItem(
          text: Text(item),
          onPressed: () => _onItemTapped(item),
          leading: _selectedItems.contains(item)
              ? const Icon(FluentIcons.check_mark)
              : null,
        );
      }).toList(),
      title: Text(
        widget.showSelectedItemsInTitle && _selectedItems.isNotEmpty
            ? _selectedItems.join(', ')
            : widget.placeholder,
      ),
    );
  }
}

