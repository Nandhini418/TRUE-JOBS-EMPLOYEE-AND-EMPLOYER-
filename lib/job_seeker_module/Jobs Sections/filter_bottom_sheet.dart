import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/api/location_dropdown_api.dart';
import '../../services/api/work_mode_api.dart';
import '../../services/api/job_type_api.dart';

class FilterBottomSheet extends StatefulWidget {
  final Map<String, List<Map<String, dynamic>>>? initialFilters;

  const FilterBottomSheet({super.key, this.initialFilters});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  int _selectedCategoryIndex = 0;

  final List<String> _categories = [
    'Freshness',
    'Work mode',
    'Location',
    'Salary',
    'Experience',
    'Walk-in',
    'Job Type',
  ];

  // Map of categories and their options with selection state
  final Map<String, List<Map<String, dynamic>>> _optionsMap = {
    'Freshness': [
      {'label': 'Last 1 day', 'checked': false},
      {'label': 'Last 3 day', 'checked': false},
      {'label': 'Last 7 day', 'checked': false},
      {'label': 'Last 15 day', 'checked': false},
      {'label': 'Last 30 day', 'checked': false},
    ],
    'Work mode': [],
    'Location': [],
    'Salary': [
      {'label': '0-3 Lacs', 'checked': false},
      {'label': '3-6 Lacs', 'checked': false},
      {'label': '6-10 Lacs', 'checked': false},
    ],
    'Experience': [
      {'label': 'Freshers', 'checked': false},
      {'label': '0-2 Yrs', 'checked': false},
      {'label': '2-3 Yrs', 'checked': false},
      {'label': '3+ Yrs', 'checked': false},
      {'label': '5+ Yrs', 'checked': false},
    ],
    'Walk-in': [
      {'label': 'Yes', 'checked': false},
      {'label': 'No', 'checked': false},
    ],
    'Job Type': [],
  };

  @override
  void initState() {
    super.initState();
    _fetchLocations();
    _fetchWorkModes();
    _fetchJobTypes();
    if (widget.initialFilters != null) {
      _optionsMap.forEach((key, list) {
        if (key != 'Location' && widget.initialFilters!.containsKey(key)) {
          for (int i = 0; i < list.length; i++) {
            if (i < widget.initialFilters![key]!.length) {
              list[i]['checked'] = widget.initialFilters![key]![i]['checked'];
            }
          }
        }
      });
    }
  }

  Future<void> _fetchLocations() async {
    final response = await LocationDropdownApi.fetchLocations();
    if (response['status'] == 'success' || response['error'] == false) {
      final List<dynamic>? locList = (response['data'] ?? response['dropdown']) as List<dynamic>?;
      if (locList != null && mounted) {
        setState(() {
          _optionsMap['Location'] = locList.map((item) {
            return {
              'label': item['name'] ?? item['label'] ?? '',
              'value': item['id'] ?? item['value'] ?? '',
              'checked': false,
            };
          }).toList();
          
          if (widget.initialFilters != null && widget.initialFilters!.containsKey('Location')) {
             final initialLocs = widget.initialFilters!['Location']!;
             for (var i = 0; i < _optionsMap['Location']!.length; i++) {
                final locOption = _optionsMap['Location']![i];
                final match = initialLocs.firstWhere((element) => element['label'] == locOption['label'], orElse: () => {'checked': false});
                if (match['checked'] == true) {
                   locOption['checked'] = true;
                }
             }
          }
        });
      }
    }
  }

  Future<void> _fetchWorkModes() async {
    final response = await WorkModeApi.fetchWorkModes();
    if (response['status'] == 'success' || response['error'] == false || response['data'] != null) {
      final List<dynamic>? list = (response['data'] ?? response['dropdown']) as List<dynamic>?;
      if (list != null && mounted) {
        setState(() {
          _optionsMap['Work mode'] = list.map((item) {
            return {
              'label': item['name'] ?? item['label'] ?? '',
              'value': item['id'] ?? item['value'] ?? '',
              'checked': false,
            };
          }).toList();
          
          if (widget.initialFilters != null && widget.initialFilters!.containsKey('Work mode')) {
             final initialList = widget.initialFilters!['Work mode']!;
             for (var i = 0; i < _optionsMap['Work mode']!.length; i++) {
                final opt = _optionsMap['Work mode']![i];
                final match = initialList.firstWhere((element) => element['label'] == opt['label'], orElse: () => {'checked': false});
                if (match['checked'] == true) opt['checked'] = true;
             }
          }
        });
      }
    }
  }

  Future<void> _fetchJobTypes() async {
    final response = await JobTypeApi.fetchJobTypes();
    if (response['status'] == 'success' || response['error'] == false || response['data'] != null) {
      final List<dynamic>? list = (response['data'] ?? response['dropdown']) as List<dynamic>?;
      if (list != null && mounted) {
        setState(() {
          _optionsMap['Job Type'] = list.map((item) {
            return {
              'label': item['name'] ?? item['label'] ?? '',
              'value': item['id'] ?? item['value'] ?? '',
              'checked': false,
            };
          }).toList();
          
          if (widget.initialFilters != null && widget.initialFilters!.containsKey('Job Type')) {
             final initialList = widget.initialFilters!['Job Type']!;
             for (var i = 0; i < _optionsMap['Job Type']!.length; i++) {
                final opt = _optionsMap['Job Type']![i];
                final match = initialList.firstWhere((element) => element['label'] == opt['label'], orElse: () => {'checked': false});
                if (match['checked'] == true) opt['checked'] = true;
             }
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double sw = screenSize.width;
    final double sh = screenSize.height;

    final currentCategory = _categories[_selectedCategoryIndex];
    final currentOptions = _optionsMap[currentCategory] ?? [];

    final Color bgColor = AppColors.dynamicBg;
    final Color textColor = AppColors.dynamicText;
    final Color borderColor = AppColors.dynamicBorder;

    return Container(
      height: sh * 0.8,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle and Title
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              width: sw * 0.15,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: sw * 0.04),
            child: Text(
              'Filter',
              style: TextStyle(
                fontSize: sw * 0.06,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          Divider(height: 1, color: borderColor),

          // Content Area (Split Left/Right)
          Expanded(
            child: Row(
              children: [
                // Left Panel - Category list
                Container(
                  width: sw * 0.3,
                  color: bgColor,
                  child: ListView.builder(
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final isSelected = index == _selectedCategoryIndex;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategoryIndex = index;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? bgColor : Colors.grey.shade50,
                            border: isSelected
                                ? const Border(
                              bottom: BorderSide(color: AppColors.primary, width: 3),
                            )
                                : null,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.03,
                            vertical: sw * 0.045,
                          ),
                          child: Text(
                            _categories[index],
                            style: TextStyle(
                              fontSize: sw * 0.038,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Divider
                Container(width: 1, color: borderColor),
                // Right Panel - Options checklist
                Expanded(
                  child: Container(
                    color: bgColor,
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.02),
                      itemCount: currentOptions.length,
                      itemBuilder: (context, index) {
                        final option = currentOptions[index];
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            option['label'],
                            style: TextStyle(
                              fontSize: sw * 0.04,
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          value: option['checked'],
                          activeColor: AppColors.primary,
                          checkboxShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2),
                          ),
                          side: BorderSide(color: textColor, width: 1),
                          onChanged: (val) {
                            setState(() {
                              option['checked'] = val;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: borderColor),

          // Bottom Action Bar
          Padding(
            padding: EdgeInsets.fromLTRB(sw * 0.05, sw * 0.04, sw * 0.05, sw * 0.06),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(sw * 0.01),
                      ),
                      padding: EdgeInsets.symmetric(vertical: sw * 0.035),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: textColor,
                        fontSize: sw * 0.04,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: sw * 0.04),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, _optionsMap);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(sw * 0.01),
                      ),
                      padding: EdgeInsets.symmetric(vertical: sw * 0.035),
                    ),
                    child: Text(
                      'Apply',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: sw * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
