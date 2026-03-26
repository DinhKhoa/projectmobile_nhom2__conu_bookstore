import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/core.dart';
import '../widgets/widgets.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  String? _selectedReportType;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.textWhite,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text = _dateFormat.format(picked);
    }
  }

  void _handleSearch() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tìm kiếm: ${_startDateController.text} - ${_endDateController.text}, '
          'Loại: ${_selectedReportType ?? "Chưa chọn"}',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppConstants.reportTitle,
            style: AppTextStyles.heading,
          ),
          const SizedBox(height: 24),
          _buildDateField(
            label: AppConstants.reportStartDate,
            controller: _startDateController,
          ),
          const SizedBox(height: 16),
          _buildDateField(
            label: AppConstants.reportEndDate,
            controller: _endDateController,
          ),
          const SizedBox(height: 16),
          _buildReportTypeDropdown(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _handleSearch,
            child: const Text(AppConstants.searchButton, style: AppTextStyles.button),
          ),
          const SizedBox(height: 40),
          const Center(
            child: AppLogo(
              iconSize: 80,
              titleFontSize: 40,
              subtitleFontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: AppTextStyles.body),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => _selectDate(controller),
            child: AbsorbPointer(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: AppColors.inputBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: AppColors.inputBorder),
                  ),
                ),
                style: AppTextStyles.body,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReportTypeDropdown() {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(AppConstants.reportType, style: AppTextStyles.body),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.inputBorder),
              borderRadius: BorderRadius.circular(4),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedReportType,
                hint: const Text(
                  AppConstants.reportTypePlaceholder,
                  style: AppTextStyles.hint,
                ),
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                items: AppConstants.reportTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type, style: AppTextStyles.body),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedReportType = value);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
