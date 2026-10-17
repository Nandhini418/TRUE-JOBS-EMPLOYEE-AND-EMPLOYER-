import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:geolocator/geolocator.dart';
import 'package:truejobs/constants/app_colors.dart';
import 'package:truejobs/services/api/api_config.dart';
import 'package:truejobs/services/api/login_api.dart';
import 'package:truejobs/services/login_api_service.dart';
import 'package:truejobs/utils/smooth_page_route.dart';
import 'package:truejobs/utils/uppercase_text_formatter.dart';
import 'package:truejobs/job_seeker_module/Login%20Sections/otp_screen.dart'
    as js_otp;
import 'package:truejobs/recruiter_module_screens/login_sections/otp_screen.dart'
    as r_otp;

class LoginScreen extends StatefulWidget {
  final bool isRecruiter;

  const LoginScreen({super.key, required this.isRecruiter});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const String _fontFamily = 'Poppins';

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _referralController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  final List<TextEditingController> _referralControllers = List.generate(
    5,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _referralFocusNodes = List.generate(
    5,
    (_) => FocusNode(),
  );
  bool _isLoading = false;
  bool? _isRegistered;
  bool _isCheckingRegistration = false;
  int _selectedSType = 1; // 1 = SMS, 2 = WhatsApp

  Future<void> _checkRegistrationStatus(String mobile) async {
    setState(() {
      _isCheckingRegistration = true;
    });

    try {
      String deviceId = await ApiConfig.getDeviceId();
      double latitude = 11.0;
      double longitude = 11.0;

      final response = await LoginApi.checkRegistration(
        mobile: mobile,
        latitude: latitude,
        longitude: longitude,
        deviceId: deviceId,
      );

      if (mounted && _phoneController.text == mobile) {
        setState(() {
          _isCheckingRegistration = false;
          if (response['status'] == 'success') {
            _isRegistered = response['registered'] ?? false;
            if (_isRegistered == false) {
              String defaultCode = widget.isRecruiter ? 'SMART' : 'APPLY';
              _referralController.text = defaultCode;
              for (int i = 0; i < 5; i++) {
                _referralControllers[i].text = defaultCode[i];
              }
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingRegistration = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _phoneFocusNode.addListener(() {
      setState(() {});
    });
    for (int i = 0; i < 5; i++) {
      _referralFocusNodes[i].addListener(() {
        setState(() {});
      });
      _referralFocusNodes[i].onKeyEvent = (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace) {
          if (_referralControllers[i].text.isEmpty && i > 0) {
            _referralFocusNodes[i - 1].requestFocus();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      };
    }
  }

  @override
  void dispose() {
    _phoneFocusNode.dispose();
    for (var node in _referralFocusNodes) {
      node.dispose();
    }
    for (var controller in _referralControllers) {
      controller.dispose();
    }
    _phoneController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  void _onSendOtpPressed() async {
    if (_phoneController.text.length != 10) return;

    setState(() {
      _isLoading = true;
    });

    if (widget.isRecruiter) {
      // Recruiter Login
      String appSignature = '';
      try {
        appSignature = await SmsAutoFill().getAppSignature;
      } catch (e) {
        debugPrint('Error getting app signature: $e');
        appSignature = 'itufuifyfufu'; // Fallback
      }

      final response = await LoginApiService.login(
        mobile: _phoneController.text.trim(),
        referrerCode: _referralController.text.trim(),
        appSignature: appSignature,
        sType: _selectedSType,
      );

      setState(() {
        _isLoading = false;
      });

      if (response != null && response['error'] == false) {
        final String token = response['f_token'] ?? '';
        final String otp = response['otp'] ?? '';

        if (mounted) {
          Navigator.push(
            context,
            SmoothPageRoute(
              child: r_otp.OtpScreen(
                phone: _phoneController.text.trim(),
                isRegistration:
                    false, // Defaulting, you may need logic to determine registration
                token: token,
                otpFromServer: otp,
                sType: _selectedSType,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response?['error_msg'] ?? 'Login failed')),
          );
        }
      }
    } else {
      // Job Seeker (Employee) Login
      double latitude = 11.0;
      double longitude = 11.0;

      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }

          if (permission != LocationPermission.denied &&
              permission != LocationPermission.deniedForever) {
            Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
            );
            latitude = position.latitude;
            longitude = position.longitude;
          }
        }
      } catch (e) {
        debugPrint('Failed to get location during login: $e');
      }

      String appSignature = '';
      try {
        appSignature = await SmsAutoFill().getAppSignature;
      } catch (e) {
        debugPrint('Error getting app signature: $e');
        appSignature = 'itufuifyfufu'; // Fallback
      }

      var deviceId = await ApiConfig.getDeviceId();

      var response = await LoginApi.loginWithPhone(
        mobile: _phoneController.text.trim(),
        appSignature: appSignature,
        latitude: latitude,
        longitude: longitude,
        deviceId: deviceId,
        referrerCode: _referralController.text.trim(),
        sType: _selectedSType,
      );

      setState(() => _isLoading = false);

      if (response['error'] == false) {
        final String token = response['f_token'] ?? '';
        final String otp = response['otp'] ?? '';

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('mobile', _phoneController.text.trim());
        await prefs.setDouble('latitude', latitude);
        await prefs.setDouble('longitude', longitude);
        await prefs.setString('device_id', deviceId);
        final parsedUserId = int.tryParse(
          response['user_id']?.toString() ?? '',
        );

        if (parsedUserId == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Invalid user profile from server. Please try again.',
                ),
              ),
            );
          }
          return;
        }

        if (mounted) {
          Navigator.push(
            context,
            SmoothPageRoute(
              child: js_otp.OtpScreen(
                phoneNumber: _phoneController.text.trim(),
                token: token,
                otpFromServer: otp,
                sType: _selectedSType,
              ),
            ),
          );
        }
      } else {
        final String errorMsg =
            response['error_msg'] ?? 'Failed to request OTP';
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(errorMsg)));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPhoneComplete = _phoneController.text.length == 10;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 15.h),
              Text(
                "Login With OTP",
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5.h),
              Text(
                widget.isRecruiter
                    ? "Find the Right Candidates Faster"
                    : "Get your dream jobs with us",
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 14.sp,
                  color: Color(0x551B1B1B),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),

              // Mobile Number Input
              TextField(
                focusNode: _phoneFocusNode,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: TextStyle(
                  fontFamily: _fontFamily,
                  fontSize: 16.sp,
                  color: Colors.black,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  labelText: 'Mobile number',
                  labelStyle: TextStyle(
                    fontFamily: _fontFamily,
                    color: _phoneFocusNode.hasFocus
                        ? AppColors.primary
                        : Color(0x44000000),
                    fontSize: 14.sp,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.r),
                    borderSide: BorderSide(color: Color(0xFFD0D0D0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.r),
                    borderSide: BorderSide(color: Color(0xFFD0D0D0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6.r),
                    borderSide: BorderSide(color: AppColors.primary),
                  ),
                ),
                onChanged: (val) {
                  setState(() {});
                  if (val.length == 10) {
                    _checkRegistrationStatus(val);
                  } else {
                    _isRegistered = null;
                  }
                },
              ),
              SizedBox(height: 10.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _selectedSType == 2
                      ? "You will receive an OTP via WhatsApp on this number"
                      : "You will receive an OTP via SMS on this number",
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 12.sp,
                    color: Color(0x551B1B1B),
                  ),
                ),
              ),
              SizedBox(height: 18.h),

              // SMS & WhatsApp Selection Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildChannelButton(
                      title: 'SMS',
                      type: 1,
                      icon: Icons.sms_outlined,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildChannelButton(
                      title: 'WhatsApp',
                      type: 2,
                      assetImage: 'assets/images/whatsapp.png',
                    ),
                  ),
                ],
              ),

              if (_isRegistered == false) ...[
                SizedBox(height: 24.h),

                // Referral Code Input
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Referral Code',
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 14.sp,
                      color: Color(0xFF1B1B1B),
                    ),
                  ),
                ),
                SizedBox(height: 15.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: SizedBox(
                        width: 45.w,
                        height: 45.w,
                        child: TextField(
                          controller: _referralControllers[index],
                          focusNode: _referralFocusNodes[index],
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: TextStyle(
                            fontFamily: _fontFamily,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9]'),
                            ),
                            UpperCaseTextFormatter(),
                          ],
                          decoration: InputDecoration(
                            counterText: '',
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(color: Color(0x66B4B4B4)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(color: Color(0x66B4B4B4)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(color: AppColors.primary),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              if (index < 4) {
                                _referralFocusNodes[index + 1].requestFocus();
                              } else {
                                _referralFocusNodes[index].unfocus();
                              }
                            } else {
                              if (index > 0) {
                                _referralFocusNodes[index - 1].requestFocus();
                              }
                            }
                            _referralController.text = _referralControllers
                                .map((c) => c.text)
                                .join();
                          },
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 12.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "If you have a different referral code, you can enter it here.",
                    style: TextStyle(
                      fontFamily: _fontFamily,
                      fontSize: 12.sp,
                      color: Color(0x551B1B1B),
                    ),
                  ),
                ),
              ],

              const Spacer(),
              ElevatedButton(
                onPressed:
                    (!isPhoneComplete || _isLoading || _isCheckingRegistration)
                    ? null
                    : _onSendOtpPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.5),
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20.w,
                        width: 20.w,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _selectedSType == 2
                            ? 'Send OTP via WhatsApp'
                            : 'Send OTP via SMS',
                        style: TextStyle(
                          fontFamily: _fontFamily,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              SizedBox(height: 50.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChannelButton({
    required String title,
    required int type,
    IconData? icon,
    String? assetImage,
  }) {
    final bool isSelected = _selectedSType == type;
    final Color activeColor =
        type == 2 ? const Color(0xFF25D366) : AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedSType = type;
          });
        },
        borderRadius: BorderRadius.circular(10.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
          decoration: BoxDecoration(
            color: isSelected
                ? (type == 2
                    ? const Color(0xFF25D366).withValues(alpha: 0.08)
                    : AppColors.primary.withValues(alpha: 0.08))
                : const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isSelected ? activeColor : const Color(0xFFE2E2E2),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              if (assetImage != null)
                Image.asset(
                  assetImage,
                  width: 18.w,
                  height: 18.w,
                  fit: BoxFit.contain,
                )
              else if (icon != null)
                Icon(
                  icon,
                  size: 18.sp,
                  color: isSelected ? activeColor : const Color(0xFF6E6E6E),
                ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 13.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? activeColor : const Color(0xFF444444),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                size: 16.sp,
                color: isSelected ? activeColor : const Color(0xFFCCCCCC),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
