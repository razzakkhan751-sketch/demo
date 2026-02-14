import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../services/certificate_service.dart';

class CertificateScreen extends StatelessWidget {
  final String studentName;
  final String courseName;

  const CertificateScreen({
    super.key,
    required this.studentName,
    required this.courseName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Certificate")),
      body: PdfPreview(
        build: (format) => CertificateService().generateCertificate(
          studentName: studentName,
          courseName: courseName,
          date: DateTime.now(),
        ),
        canDebug: false,
        allowPrinting: true,
        allowSharing: true,
      ),
    );
  }
}
