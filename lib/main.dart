import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

/// Hospital Management System with OPD Consultation Slip Printing
///
/// This application is designed to work with 80mm thermal receipt printers
/// such as the Black Copper BC-85AC. The PDF layout is optimized for
/// thermal paper width and provides pixel-perfect printing output.

void main() {
  runApp(const HospitalApp());
}

class HospitalApp extends StatelessWidget {
  const HospitalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'M.A.Q.M Hospital Management System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        cardColor: const Color(0xFF2D2D2D),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D47A1),
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1976D2),
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF3A3A3A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: Color(0xFF555555)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: Color(0xFF555555)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: Color(0xFF1976D2), width: 2),
          ),
          labelStyle: TextStyle(color: Color(0xFFBBBBBB)),
        ),
      ),
      home: const HospitalMainScreen(),
    );
  }
}

class HospitalMainScreen extends StatefulWidget {
  const HospitalMainScreen({super.key});

  @override
  State<HospitalMainScreen> createState() => _HospitalMainScreenState();
}

class _HospitalMainScreenState extends State<HospitalMainScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final _patientNameController = TextEditingController();
  final _soController = TextEditingController();
  final _ageController = TextEditingController();
  final _regNumberController = TextEditingController();
  final _sessionNumberController = TextEditingController();
  final _consultationNumberController = TextEditingController();
  final _doctorNameController = TextEditingController();
  final _tokenNumberController = TextEditingController();

  String _selectedGender = 'Male';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedFields();
  }

  Future<void> _loadSavedFields() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _regNumberController.text = prefs.getString('reg_number') ?? '3570';
      _sessionNumberController.text = prefs.getString('session_number') ?? '45';
      _consultationNumberController.text =
          prefs.getString('consultation_number') ?? '3456';
      _tokenNumberController.text = prefs.getString('token_number') ?? '5';
      // Optionally load other fields if needed
      _doctorNameController.text = 'Gen. Physician-MFH';
      _patientNameController.text = 'usman';
      _ageController.text = '45';
    });
  }

  Future<void> _saveField(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _soController.dispose();
    _ageController.dispose();
    _regNumberController.dispose();
    _sessionNumberController.dispose();
    _consultationNumberController.dispose();
    _doctorNameController.dispose();
    _tokenNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'M.A.Q.M Hospital Management System',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Hospital Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Text(
                    'WELCOME TO',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 2,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'M.A.Q.M HOSPITAL',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'OPD CONSULTATION SYSTEM',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Form Card
            Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Patient Information',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Row 1: Patient Name and S/O
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildTextField(
                              controller: _patientNameController,
                              label: 'Patient Name',
                              isRequired: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _soController,
                              label: 'S/O (Son/Daughter of)',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Row 2: Age and Gender
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _ageController,
                              label: 'Age',
                              isRequired: true,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: _buildGenderDropdown()),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Row 3: Registration Number and Session Number
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _regNumberController,
                              label: 'Registration Number (Reg #)',
                              isRequired: true,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _sessionNumberController,
                              label: 'Session #',
                              isRequired: true,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Row 4: Consultation Number and Token Number
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _consultationNumberController,
                              label: 'Consultation Number (Con #)',
                              isRequired: true,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: _tokenNumberController,
                              label: 'Token Number',
                              isRequired: true,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Doctor Name
                      _buildTextField(
                        controller: _doctorNameController,
                        label: 'Doctor Name',
                        isRequired: true,
                      ),
                      const SizedBox(height: 32),

                      // Print and Preview Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Preview Button

                          // Print Button
                          SizedBox(
                            width: 180,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _printOPDSlip,
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.print, size: 24),
                              label: Text(
                                _isLoading ? 'Printing...' : 'Print',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E7D32),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Printer Info and Reset
                      Center(
                        child: TextButton.icon(
                          onPressed: _resetDefaultPrinter,
                          icon: const Icon(Icons.settings, size: 16),
                          label: const Text(
                            'Reset Default Printer',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        labelStyle: TextStyle(
          color: isRequired ? Colors.redAccent : const Color(0xFFBBBBBB),
        ),
      ),
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label is required';
              }
              return null;
            }
          : null,
      onChanged: (value) {
        // Save to SharedPreferences if this is a tracked field
        if (controller == _regNumberController) {
          _saveField('reg_number', value);
        } else if (controller == _sessionNumberController) {
          _saveField('session_number', value);
        } else if (controller == _consultationNumberController) {
          _saveField('consultation_number', value);
        } else if (controller == _tokenNumberController) {
          _saveField('token_number', value);
        }
      },
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: const InputDecoration(
        labelText: 'Gender *',
        labelStyle: TextStyle(color: Colors.redAccent),
      ),
      dropdownColor: const Color(0xFF3A3A3A),
      items: ['Male', 'Female', 'Other'].map((String value) {
        return DropdownMenuItem<String>(value: value, child: Text(value));
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedGender = newValue!;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Gender is required';
        }
        return null;
      },
    );
  }

  Future<void> _printOPDSlip() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Save tracked fields before printing
      await _saveField('reg_number', _regNumberController.text);
      await _saveField('session_number', _sessionNumberController.text);
      await _saveField(
        'consultation_number',
        _consultationNumberController.text,
      );
      await _saveField('token_number', _tokenNumberController.text);

      final pdf = await _generateOPDSlipPDF();

      // Check for default printer
      final prefs = await SharedPreferences.getInstance();
      final defaultPrinter = prefs.getString('default_printer');

      bool printSuccess = false;

      if (defaultPrinter == null) {
        // First time - show printer selection dialog
        final printer = await Printing.pickPrinter(context: context);
        if (printer != null) {
          // Save selected printer as default
          await prefs.setString('default_printer', printer.name);

          // Print to selected printer
          await Printing.directPrintPdf(
            printer: printer,
            onLayout: (PdfPageFormat format) async => pdf.save(),
          );
          printSuccess = true;

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Printer "${printer.name}" set as default and slip printed successfully!',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          // User cancelled printer selection, show preview instead
          await Printing.layoutPdf(
            onLayout: (PdfPageFormat format) async => pdf.save(),
            name: 'OPD_Consultation_Slip_${_tokenNumberController.text}',
          );
        }
      } else {
        // Use saved default printer
        try {
          await Printing.directPrintPdf(
            printer: Printer(name: defaultPrinter, url: ''),
            onLayout: (PdfPageFormat format) async => pdf.save(),
          );
          printSuccess = true;

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'OPD slip printed successfully to default printer!',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          // If default printer fails, show printer selection again
          final printer = await Printing.pickPrinter(context: context);
          if (printer != null) {
            await prefs.setString('default_printer', printer.name);
            await Printing.directPrintPdf(
              printer: printer,
              onLayout: (PdfPageFormat format) async => pdf.save(),
            );
            printSuccess = true;

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'New printer "${printer.name}" set as default and slip printed!',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        }
      }

      // Increment numbers only if print was successful
      if (printSuccess) {
        int reg = int.tryParse(_regNumberController.text) ?? 0;
        int session = int.tryParse(_sessionNumberController.text) ?? 0;
        int consult = int.tryParse(_consultationNumberController.text) ?? 0;
        int token = int.tryParse(_tokenNumberController.text) ?? 0;

        reg += 3;
        session =
            session; // No increment for session as per your last request, but if needed, change here
        consult += 2;
        token += 1;

        setState(() {
          _regNumberController.text = reg.toString();
          _sessionNumberController.text = session.toString();
          _consultationNumberController.text = consult.toString();
          _tokenNumberController.text = token.toString();
        });

        await _saveField('reg_number', reg.toString());
        await _saveField('session_number', session.toString());
        await _saveField('consultation_number', consult.toString());
        await _saveField('token_number', token.toString());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error printing slip: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetDefaultPrinter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('default_printer');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Default printer reset. You will be asked to select a printer on next print.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resetting printer: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<pw.Document> _generateOPDSlipPDF() async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateFormat = DateFormat('dd-MM-yyyy HH:mm');

    // Create custom page format for 80mm thermal printer
    // Using roll80 format which is perfect for thermal receipt printers
    // This ensures the layout matches exactly with the thermal paper width
    // and provides optimal printing quality for receipt-style documents

    final customFormat = PdfPageFormat.roll80.copyWith(
      marginLeft: 15,
      marginRight: 15,
      marginTop: 15,
      marginBottom: 15,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: customFormat,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Hospital Header - Centered and underlined
              pw.Container(
                width: double.infinity,
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Mirza Abdul Qayyum Memorial Hospital',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Container(
                      width: double.infinity,
                      height: 1,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(bottom: pw.BorderSide(width: 1)),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 4),

              // Address
              pw.Text(
                '213-C, Sec. C/3 Allama Iqbal Road Mirpur A.K',
                style: const pw.TextStyle(fontSize: 8.5),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 2),

              // Phone
              pw.Text(
                'Phone: 05827-444 050',
                style: const pw.TextStyle(fontSize: 8.5),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 12),

              // OPD Consultation Slip Header - Centered and underlined
              pw.Container(
                width: double.infinity,
                child: pw.Column(
                  children: [
                    pw.Text(
                      'OPD. CONSULTATION SLIP',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                    pw.Container(
                      width: double.infinity,
                      height: 1,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(bottom: pw.BorderSide(width: 1)),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),

              // Token Number in Circle - Centered
              pw.Center(
                child: pw.Container(
                  width: 35,
                  height: 35,
                  decoration: pw.BoxDecoration(
                    shape: pw.BoxShape.circle,
                    border: pw.Border.all(width: 2),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      _tokenNumberController.text,
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              pw.SizedBox(height: 12),

              // Doctor Information - Left aligned
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Physician: ${_doctorNameController.text}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),

                    pw.Container(
                      width: double.infinity,
                      height: 1,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(bottom: pw.BorderSide(width: 1)),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'General Physician',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),

              // Patient Information - Two column layout
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left Column
                  pw.SizedBox(
                    width: 100,
                    child: pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Date: ${dateFormat.format(now)}',
                                style: pw.TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(height: 1),
                              pw.Container(
                                width: double.infinity,
                                height: 0.5,
                                color: PdfColor.fromInt(0xFF000000),
                              ),
                            ],
                          ),

                          pw.SizedBox(height: 6),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Patient: ${_patientNameController.text}',
                                style: pw.TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(height: 1),

                              pw.Container(
                                width: double.infinity,
                                height: 0.5,
                                color: PdfColor.fromInt(0xFF000000),
                              ),
                            ],
                          ),

                          pw.SizedBox(height: 6),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'S/O: ${_soController.text.isEmpty ? "----" : _soController.text}',
                                style: pw.TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(height: 1),

                              pw.Container(
                                width: double.infinity,
                                height: 0.5,
                                color: PdfColor.fromInt(0xFF000000),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 6),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Age: ${_ageController.text}/${_selectedGender == 'Male'
                                    ? 'M'
                                    : _selectedGender == 'Female'
                                    ? 'F'
                                    : 'O'}',
                                style: pw.TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(height: 1),

                              pw.Container(
                                width: double.infinity,
                                height: 0.5,
                                color: PdfColor.fromInt(0xFF000000),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 15),

                  // Right Column
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Row(
                              children: [
                                pw.Expanded(
                                  child: pw.Text(
                                    'Reg. #:',
                                    style: pw.TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                ),
                                pw.Text(
                                  _regNumberController.text,
                                  style: pw.TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            pw.SizedBox(height: 1),

                            pw.Container(
                              width: double.infinity,
                              height: 0.5,
                              color: PdfColor.fromInt(0xFF000000),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 6),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Row(
                              children: [
                                pw.Expanded(
                                  child: pw.Text(
                                    'Session#:',
                                    style: pw.TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                ),
                                pw.Text(
                                  _sessionNumberController.text,
                                  style: pw.TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 1),

                            pw.Container(
                              width: double.infinity,
                              height: 0.5,
                              color: PdfColor.fromInt(0xFF000000),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 6),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Row(
                              children: [
                                pw.Expanded(
                                  child: pw.Text(
                                    'Con. #:',
                                    style: pw.TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                ),
                                pw.Text(
                                  _consultationNumberController.text,
                                  style: pw.TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            pw.SizedBox(height: 1),

                            pw.Container(
                              width: double.infinity,
                              height: 0.5,
                              color: PdfColor.fromInt(0xFF000000),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),

              // Separator Line
              pw.Container(
                width: double.infinity,
                height: 1,
                decoration: const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(width: 1)),
                ),
              ),
              pw.SizedBox(height: 8),

              // Total Amount - Bold and right aligned
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  children: [
                    pw.Container(
                      width: 80,
                      height: 1,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(bottom: pw.BorderSide(width: 1)),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Total Rs: 500',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Container(
                      width: 80,
                      height: 1,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(bottom: pw.BorderSide(width: 1)),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 32),
              // Operator
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text(
                  'Operator: Usman Arif',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
              pw.SizedBox(height: 4),

              // Separator Line
              pw.Container(
                width: double.infinity,
                height: 1,
                decoration: const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(width: 1)),
                ),
              ),
              pw.SizedBox(height: 4),

              // Powered by
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'Powered by: www.goldensoftpk.com',
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }
}
