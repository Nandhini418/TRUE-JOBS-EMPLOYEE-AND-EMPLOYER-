import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/models/resume_data.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:truejobs/utils/smooth_page_route.dart';
import 'package:truejobs/resume_sections/fresher_candidates/skills_screen.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  final List<EducationEntry> _educationEntries = [EducationEntry()];

  @override
  void dispose() {
    for (var entry in _educationEntries) {
      entry.dispose();
    }
    super.dispose();
  }

  void _addEducation() {
    setState(() {
      _educationEntries.add(EducationEntry());
    });
  }

  void _removeEducation(int index) {
    if (_educationEntries.length > 1) {
      setState(() {
        _educationEntries[index].dispose();
        _educationEntries.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one education detail is required')),
      );
    }
  }

  bool _validate() {
    if (_educationEntries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one education detail')),
      );
      return false;
    }

    for (int i = 0; i < _educationEntries.length; i++) {
      final entry = _educationEntries[i];
      final prefix = _educationEntries.length > 1 ? 'Education ${i + 1}: ' : '';

      if (entry.courseCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${prefix}Course / Degree is required')),
        );
        return false;
      }

      if (entry.schoolCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${prefix}School / University is required')),
        );
        return false;
      }

      if (entry.gradeCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${prefix}Grade / Score is required')),
        );
        return false;
      }

      final yearText = entry.yearCtrl.text.trim();
      if (yearText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${prefix}Year of passing is required')),
        );
        return false;
      }

      final yearVal = int.tryParse(yearText);
      final currentYear = DateTime.now().year;
      if (yearVal == null || yearText.length != 4 || yearVal < 1950 || yearVal > currentYear + 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${prefix}Please enter a valid 4-digit Year (e.g. 2024)')),
        );
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
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
                padding: EdgeInsets.only(
                  left: 24.w,
                  right: 24.w,
                  top: 1.h,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top Image
                    Center(
                      child: Image.asset(
                        'assets/resume_images/experience/education.gif',
                        height: 60.h,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.school_outlined, size: 48.sp, color: AppColors.primary),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      "Add Education",
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Add your Educational Details",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF353535),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),
                    
                    ...List.generate(_educationEntries.length, (index) {
                      return _buildEducationCard(index);
                    }),

                    SizedBox(height: 16.h),
                    GestureDetector(
                      onTap: _addEducation,
                      child: DottedBorder(
                        options: RoundedRectDottedBorderOptions(
                          color: const Color(0xFF255EC7), // Dark blue border
                          strokeWidth: 1.w,
                          dashPattern: const <double>[2, 2],
                          radius: Radius.circular(24.r),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add,
                                color: const Color(0xFF0F99DE),
                                size: 18.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                "Add Another Education",
                                style: TextStyle(
                                  color: const Color(0xFF0F99DE),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationCard(int index) {
    final entry = _educationEntries[index];
    
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2563EB), Color(0xFF153885)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(11.r),
                topRight: Radius.circular(11.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Education ${index + 1}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_educationEntries.length > 1)
                  GestureDetector(
                    onTap: () => _removeEducation(index),
                    child: Icon(Icons.delete, color: Colors.white, size: 20.sp),
                  ),
              ],
            ),
          ),
          
          // Form Fields
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField("Course / Degree *", "e.g. B.Tech Computer Science", controller: entry.courseCtrl),
                _buildTextField("School / University *", "e.g. Oxford University", controller: entry.schoolCtrl),
                _buildTextField("Grade / Score *", "e.g. 8.5 CGPA or 85%", controller: entry.gradeCtrl),
                _buildTextField("Year of passing *", "YYYY (e.g. 2024)", controller: entry.yearCtrl, keyboardType: TextInputType.number, maxLength: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint, {
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label.replaceAll('*', '').trim(),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              children: [
                if (label.contains('*'))
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLength: maxLength,
            style: TextStyle(color: Colors.black87, fontSize: 13.sp),
            decoration: InputDecoration(
              counterText: "",
              hintText: hint,
              hintStyle: TextStyle(color: const Color(0xFF9E9E9E), fontSize: 13.sp),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.r),
                borderSide: BorderSide(color: const Color(0xFFE0E0E0), width: 1.w),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6.r),
                borderSide: BorderSide(color: AppColors.primary, width: 1.w),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                side: const BorderSide(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
              child: Text(
                'Back',
                style: TextStyle(
                  color: const Color(0xFF272727),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (!_validate()) return;

                List<Education> eduList = _educationEntries.map((entry) {
                  final grade = entry.gradeCtrl.text.trim();
                  final degreeWithGrade = grade.isNotEmpty
                      ? "${entry.courseCtrl.text.trim()} ($grade)"
                      : entry.courseCtrl.text.trim();
                  return Education(
                    degree: degreeWithGrade,
                    institution: entry.schoolCtrl.text.trim(),
                    year: entry.yearCtrl.text.trim(),
                  );
                }).toList();
                
                ResumeData.globalData = ResumeData.globalData.copyWith(
                  education: eduList,
                );

                Navigator.push(
                  context,
                  SmoothPageRoute(
                    child: const SkillsScreen(),
                    durationMs: 0,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
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

class EducationEntry {
  final TextEditingController courseCtrl = TextEditingController();
  final TextEditingController schoolCtrl = TextEditingController();
  final TextEditingController gradeCtrl = TextEditingController();
  final TextEditingController yearCtrl = TextEditingController();

  void dispose() {
    courseCtrl.dispose();
    schoolCtrl.dispose();
    gradeCtrl.dispose();
    yearCtrl.dispose();
  }
}
