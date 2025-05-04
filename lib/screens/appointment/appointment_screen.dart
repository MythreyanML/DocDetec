import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:doctor_finder_flutter/models/doctor_model.dart';
import 'package:doctor_finder_flutter/models/appointment_model.dart';
import 'package:doctor_finder_flutter/providers/auth_provider.dart';
import 'package:doctor_finder_flutter/services/firestore_service.dart';
import 'package:doctor_finder_flutter/widgets/common/custom_text_field.dart';
import 'package:doctor_finder_flutter/widgets/common/custom_button.dart';
import 'package:doctor_finder_flutter/widgets/common/loading_indicator.dart';

class AppointmentScreen extends StatefulWidget {
  final String doctorId;

  const AppointmentScreen({Key? key, required this.doctorId}) : super(key: key);

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  DoctorModel? _doctor;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();
  final _insuranceProviderController = TextEditingController();
  final _insuranceNumberController = TextEditingController();
  bool _useInsurance = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDoctor();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    _insuranceProviderController.dispose();
    _insuranceNumberController.dispose();
    super.dispose();
  }

  void _loadDoctor() async {
    final doctor = await FirestoreService.getDoctor(widget.doctorId);
    if (mounted) {
      setState(() {
        _doctor = doctor;
        _useInsurance = doctor?.acceptsInsurance ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_doctor == null) {
      return const Scaffold(
        body: Center(child: LoadingIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            _buildDoctorInfo(),
            const SizedBox(height: 20),
            _buildAppointmentDetails(),
            const SizedBox(height: 20),
            if (_doctor!.acceptsInsurance) _buildInsuranceSection(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildDoctorInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            const Icon(Icons.person, size: 36, color: Colors.blue),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _doctor!.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _doctor!.specialty ?? 'General Practitioner',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Appointment Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.blue),
              title: Text(DateFormat('dd MMMM yyyy').format(_selectedDate)),
              subtitle: const Text('Date'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _selectDate,
            ),
            ListTile(
              leading: const Icon(Icons.access_time, color: Colors.blue),
              title: Text(_selectedTime.format(context)),
              subtitle: const Text('Time'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _selectTime,
            ),
            CustomTextField(
              controller: _reasonController,
              label: 'Reason for Visit*',
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter a reason for your visit';
                }
                return null;
              },
            ),
            CustomTextField(
              controller: _notesController,
              label: 'Additional Notes',
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsuranceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Insurance Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                const Text('Use Insurance?'),
                const Spacer(),
                Switch(
                  value: _useInsurance,
                  onChanged: (value) => setState(() => _useInsurance = value),
                ),
              ],
            ),
            if (_useInsurance) ...[
              CustomTextField(
                controller: _insuranceProviderController,
                label: 'Insurance Provider',
              ),
              CustomTextField(
                controller: _insuranceNumberController,
                label: 'Insurance Number/Policy ID',
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  'ℹ️ This doctor accepts medical insurance in Botswana. Please check with your provider to confirm coverage details.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '* By booking an appointment, you agree to our cancellation policy. Please cancel at least 24 hours in advance if you cannot make it.',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 15),
          CustomButton(
            text: 'Book Appointment',
            onPressed: _bookAppointment,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  void _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  void _bookAppointment() async {
    if (_reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a reason for your visit')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      final appointmentDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      if (appointmentDateTime.isBefore(DateTime.now())) {
        throw 'Please select a future date and time';
      }

      final appointment = AppointmentModel(
        id: '',
        doctorId: _doctor!.id,
        doctorName: _doctor!.name,
        doctorSpecialty: _doctor!.specialty,
        patientId: user?.id ?? 'guest',
        patientName: user?.name ?? user?.email ?? 'Guest User',
        appointmentDateTime: appointmentDateTime,
        reason: _reasonController.text,
        notes: _notesController.text,
        status: AppointmentStatus.pending,
        useInsurance: _useInsurance,
        insuranceProvider: _useInsurance ? _insuranceProviderController.text : null,
        insuranceNumber: _useInsurance ? _insuranceNumberController.text : null,
        createdAt: DateTime.now(),
      );

      await FirestoreService.addAppointment(appointment);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Appointment Request Sent'),
            content: Text(
              'Your appointment request with ${_doctor!.name} for ${DateFormat('dd MMMM yyyy').format(_selectedDate)} at ${_selectedTime.format(context)} has been sent. You will be notified once the doctor confirms your appointment.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  context.pop(); // Close dialog
                  context.pop(); // Go back to previous screen
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}