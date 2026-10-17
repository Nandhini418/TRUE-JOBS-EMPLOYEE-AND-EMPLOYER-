import 'dart:io';
import 'package:flutter/material.dart';
import 'package:truejobs/models/resume_data.dart';

class TemplateOne extends StatelessWidget {
  final ResumeData data;
  
  const TemplateOne({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Determine layout parameters
    final double baseFontSize = data.fontSize > 0 ? data.fontSize : 8.0;
    final String fontFamily = data.fontFamily.isNotEmpty ? data.fontFamily : 'Roboto';
    final Color primaryColor = Color(data.primaryColor);
    const Color textColor = Colors.black87;
    const Color subtitleColor = Colors.black54;

    return AspectRatio(
      aspectRatio: 1 / 1.414,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            if (data.hasPhoto && data.profileImagePath != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: FileImage(File(data.profileImagePath!)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildHeaderContent(baseFontSize, fontFamily, primaryColor, textColor, subtitleColor, center: false),
                  ),
                ],
              )
            else
              _buildHeaderContent(baseFontSize, fontFamily, primaryColor, textColor, subtitleColor, center: true),

            const SizedBox(height: 16),

            // Content Sections
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PROFESSIONAL SUMMARY
                    if (data.summary.isNotEmpty) ...[
                      _buildSectionTitle('PROFESSIONAL SUMMARY', fontFamily, primaryColor),
                      Text(
                        data.summary,
                        style: TextStyle(fontSize: baseFontSize, color: textColor, height: 1.4, fontFamily: fontFamily),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // PROFESSIONAL EXPERIENCE
                    if (data.experience.isNotEmpty) ...[
                      _buildSectionTitle('PROFESSIONAL EXPERIENCE', fontFamily, primaryColor),
                      ...data.experience.map((exp) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    exp.jobTitle,
                                    style: TextStyle(fontSize: baseFontSize + 1, fontWeight: FontWeight.bold, color: textColor, fontFamily: fontFamily),
                                  ),
                                ),
                                Text(
                                  exp.duration,
                                  style: TextStyle(fontSize: baseFontSize - 1, color: subtitleColor, fontFamily: fontFamily),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              exp.company,
                              style: TextStyle(fontSize: baseFontSize, fontWeight: FontWeight.bold, color: textColor, fontFamily: fontFamily),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              exp.description,
                              style: TextStyle(fontSize: baseFontSize, color: textColor, height: 1.4, fontFamily: fontFamily),
                            ),
                          ],
                        ),
                      )),
                    ],

                    // PROJECTS
                    if (data.projects.isNotEmpty) ...[
                      _buildSectionTitle('PROJECTS', fontFamily, primaryColor),
                      ...data.projects.map((proj) => Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(fontSize: baseFontSize, color: textColor, fontFamily: fontFamily),
                                      children: [
                                        TextSpan(
                                          text: '${proj.title}, ',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text: proj.technologies,
                                          style: TextStyle(color: subtitleColor, fontFamily: fontFamily),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              proj.description,
                              style: TextStyle(fontSize: baseFontSize, color: textColor, height: 1.4, fontFamily: fontFamily),
                            ),
                          ],
                        ),
                      )),
                    ],

                    // EDUCATION
                    if (data.education.isNotEmpty) ...[
                      _buildSectionTitle('EDUCATION', fontFamily, primaryColor),
                      ...data.education.map((edu) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    edu.degree,
                                    style: TextStyle(fontSize: baseFontSize + 1, fontWeight: FontWeight.bold, color: textColor, fontFamily: fontFamily),
                                  ),
                                ),
                                Text(
                                  edu.year,
                                  style: TextStyle(fontSize: baseFontSize - 1, color: subtitleColor, fontFamily: fontFamily),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              edu.institution,
                              style: TextStyle(fontSize: baseFontSize, color: textColor, fontFamily: fontFamily),
                            ),
                          ],
                        ),
                      )),
                      const SizedBox(height: 4),
                    ],

                    // CERTIFICATIONS
                    if (data.certifications.isNotEmpty) ...[
                      _buildSectionTitle('CERTIFICATIONS', fontFamily, primaryColor),
                      ...data.certifications.map((cert) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(fontSize: baseFontSize, color: textColor, fontFamily: fontFamily),
                                  children: [
                                    TextSpan(text: '${cert.name} ', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    if (cert.organization.isNotEmpty)
                                      TextSpan(text: '| ${cert.organization}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                            Text(
                              cert.year,
                              style: TextStyle(fontSize: baseFontSize - 1, color: subtitleColor, fontFamily: fontFamily),
                            ),
                          ],
                        ),
                      )),
                      const SizedBox(height: 4),
                    ],

                    // SKILLS & LANGUAGES
                    if (data.skills.isNotEmpty || data.languages.isNotEmpty) ...[
                      _buildSectionTitle('SKILLS', fontFamily, primaryColor),
                      if (data.skills.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 80,
                                child: Text('Skills:', style: TextStyle(fontSize: baseFontSize, fontWeight: FontWeight.bold, color: textColor, fontFamily: fontFamily)),
                              ),
                              Expanded(
                                child: Text(
                                  data.skills.join(', '),
                                  style: TextStyle(fontSize: baseFontSize, color: textColor, height: 1.4, fontFamily: fontFamily),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (data.languages.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 80,
                                child: Text('Languages:', style: TextStyle(fontSize: baseFontSize, fontWeight: FontWeight.bold, color: textColor, fontFamily: fontFamily)),
                              ),
                              Expanded(
                                child: Text(
                                  data.languages.map((l) => l['name']).join(', '),
                                  style: TextStyle(fontSize: baseFontSize, color: textColor, height: 1.4, fontFamily: fontFamily),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderContent(double baseFontSize, String fontFamily, Color primaryColor, Color textColor, Color subtitleColor, {required bool center}) {
    return Column(
      crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          data.fullName,
          textAlign: center ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontSize: baseFontSize + 12, // Scaled dynamically with baseFontSize
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          alignment: center ? WrapAlignment.center : WrapAlignment.start,
          spacing: 12,
          runSpacing: 4,
          children: [
            if (data.address.isNotEmpty) _buildContactItem(Icons.location_on, data.address, baseFontSize, subtitleColor, fontFamily),
            if (data.email.isNotEmpty) _buildContactItem(Icons.email, data.email, baseFontSize, subtitleColor, fontFamily),
            if (data.phone.isNotEmpty) _buildContactItem(Icons.phone, data.phone, baseFontSize, subtitleColor, fontFamily),
          ],
        ),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text, double fontSize, Color color, String fontFamily) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: fontSize + 2, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: fontSize, color: color, fontFamily: fontFamily)),
      ],
    );
  }

  Widget _buildSectionTitle(String title, String fontFamily, Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily,
            letterSpacing: 1.2,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          height: 1,
          width: double.infinity,
          color: primaryColor,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
