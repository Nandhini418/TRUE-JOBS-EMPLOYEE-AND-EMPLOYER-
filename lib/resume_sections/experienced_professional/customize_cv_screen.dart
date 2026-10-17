import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/models/resume_data.dart';
import 'package:truejobs/resume_sections/experienced_professional/cv_preview_screen.dart';
import 'package:truejobs/resume_sections/templates/template_one.dart';
import 'package:truejobs/utils/smooth_page_route.dart';

class CustomizeCvScreen extends StatefulWidget {
  const CustomizeCvScreen({super.key});

  @override
  State<CustomizeCvScreen> createState() => _CustomizeCvScreenState();
}

class _CustomizeCvScreenState extends State<CustomizeCvScreen> {
  // Available options
  final List<String> _fonts = [
    'Poppins',
    'Times New Roman',
    'Calibri',
    'Arial',
    'Roboto',
  ];

  // Constant font size
  static const double _constantFontSize = 8.0;

  // Color options matching the UI screenshot
  final List<Color> _colors = [
    const Color(0xFF444444), // Black (default)
    const Color(0xFF2563EB), // Blue
    const Color(0xFF005F65), // Dark Blue
    const Color(0xFFD27B3F), // Orange
    const Color(0xFFF14A39), // Red
    const Color(0xFFBF4D86), // Pink
    const Color(0xFF742B88), // Purple
  ];

  late String _selectedFont;
  late Color _selectedColor;
  late bool _showPhoto;

  @override
  void initState() {
    super.initState();
    final data = ResumeData.globalData;

    // Initialize from globalData
    _selectedFont = _fonts.contains(data.fontFamily)
        ? data.fontFamily
        : 'Poppins';

    _selectedColor = Color(data.primaryColor);
    if (!_colors.contains(_selectedColor)) {
      _selectedColor = _colors.first;
    }

    _showPhoto = data.hasPhoto;

    _updateGlobalData();
  }

  void _updateGlobalData() {
    ResumeData.globalData = ResumeData.globalData.copyWith(
      fontFamily: _selectedFont,
      fontSize: _constantFontSize,
      primaryColor: _selectedColor.value,
      hasPhoto: _showPhoto,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 16.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 10.h),
                    // Top Icon
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.palette_outlined,
                        color: AppColors.primary,
                        size: 32.sp,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      "Customize your Cv",
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Make changes to style and format",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF757575),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32.h),

                    // Template Section
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Template",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: const Color(0xFF757575),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Modern Professional",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              Container(
                                width: 60.w,
                                height: 85.h,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4.r),
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: SizedBox(
                                      width: 400,
                                      height: 400 * 1.414,
                                      child: TemplateOne(
                                        data: ResumeData.globalData,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Font Selection
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Font",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedFont,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              items: _fonts.map((String font) {
                                return DropdownMenuItem<String>(
                                  value: font,
                                  child: Text(
                                    font,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontFamily: font,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedFont = newValue;
                                    _updateGlobalData();
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),


                    // Primary Color Selection
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Primary Color",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _colors.map((color) {
                                bool isSelected = _selectedColor == color;
                                return Padding(
                                  padding: EdgeInsets.only(right: 10.w),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedColor = color;
                                        _updateGlobalData();
                                      });
                                    },
                                    child: AnimatedScale(
                                      scale: isSelected ? 1.0 : 0.95,
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      curve: Curves.easeOutBack,
                                      child: Container(
                                        decoration: isSelected
                                            ? BoxDecoration(
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: color.withOpacity(
                                                      0.2,
                                                    ),
                                                    blurRadius: 1,
                                                  ),
                                                ],
                                              )
                                            : null,
                                        child: Icon(
                                          Icons.circle,
                                          color: color,
                                          size: 35.w,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Show Photo Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Show Photo",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        Switch(
                          value: _showPhoto,
                          activeColor: AppColors.primary,
                          onChanged: (value) {
                            setState(() {
                              _showPhoto = value;
                              _updateGlobalData();
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),

            // Bottom Buttons
            _buildBottomButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                // To preview the CV, navigate to the CvPreviewScreen
                Navigator.pushReplacement(
                  context,
                  SmoothPageRoute(
                    child: const CvPreviewScreen(),
                    durationMs: 0,
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                side: const BorderSide(color: Colors.black87),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
              child: Text(
                'Preview',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // In future: navigate to the final screen, save, etc.
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
              child: Text(
                'Next',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
