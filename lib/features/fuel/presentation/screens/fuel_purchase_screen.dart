// lib/features/presentation/screens/fuel_purchase_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wm_jaya/constants/app_colors.dart';
import 'package:wm_jaya/constants/app_strings.dart';
import 'package:wm_jaya/data/local_db/database_helper.dart';
import 'package:wm_jaya/features/fuel/presentation/providers/fuel_provider.dart';
import 'package:wm_jaya/utils/helpers/input_validator.dart';
import 'package:wm_jaya/widgets/common/app_button.dart';
import 'package:wm_jaya/widgets/common/app_textfield.dart';
import 'package:wm_jaya/data/models/report.dart';
import 'package:wm_jaya/data/repositories/report_repository.dart';
import 'package:wm_jaya/features/report/presentation/screens/report_screen.dart';

class FuelPurchaseScreen extends StatefulWidget {
  const FuelPurchaseScreen({super.key});

  @override
  FuelPurchaseScreenState createState() => FuelPurchaseScreenState();
}

class FuelPurchaseScreenState extends State<FuelPurchaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _priceController = TextEditingController();
  final _literController = TextEditingController();
  final _pricePerLiterController = TextEditingController();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey();
  String _calculationType = 'price';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final fuelProvider = Provider.of<FuelProvider>(context, listen: false);
      if (fuelProvider.fuelTypes.isNotEmpty) {
        _typeController.text = fuelProvider.fuelTypes.first;
        _updatePricePerLiter();
      }
    });
  }

  void _updatePricePerLiter() {
    final fuelProvider = Provider.of<FuelProvider>(context, listen: false);
    final price = fuelProvider.getPricePerLiter(_typeController.text);
    _pricePerLiterController.text = price.toStringAsFixed(0);
    _updateTotal();
  }

  void _updateTotal() {
    final pricePerLiter = double.tryParse(_pricePerLiterController.text) ?? 0;
    if (pricePerLiter <= 0) return;

    if (_calculationType == 'price') {
      final price = double.tryParse(_priceController.text) ?? 0;
      _literController.text = (price / pricePerLiter).toStringAsFixed(2);
    } else {
      final liters = double.tryParse(_literController.text) ?? 0;
      _priceController.text = (liters * pricePerLiter).toStringAsFixed(0);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(title: const Text(AppStrings.fuelTitle)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Card(
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildFuelTypeField(),
                    const SizedBox(height: 20),
                    _buildPricePerLiterField(),
                    const SizedBox(height: 20),
                    _buildCalculationToggle(),
                    const SizedBox(height: 20),
                    _buildInputField(),
                    const SizedBox(height: 30),
                    _buildResultSection(),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFuelTypeField() {
    final fuelProvider = Provider.of<FuelProvider>(context);
    return DropdownButtonFormField<String>(
      value: _typeController.text.isNotEmpty ? _typeController.text : null,
      items: fuelProvider.fuelTypes.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type),
        );
      }).toList(),
      decoration: const InputDecoration(
        labelText: AppStrings.fuelTypeLabel,
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.local_gas_station, size: 20),
      ),
      validator: (value) => value?.isEmpty ?? true ? AppStrings.errorEmptyField : null,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _typeController.text = value;
            _updatePricePerLiter();
          });
        }
      },
    );
  }

  Widget _buildPricePerLiterField() {
    return AppTextField(
      controller: _pricePerLiterController,
      labelText: AppStrings.pricePerLiter,
      prefixIcon: const Icon(Icons.monetization_on, size: 20),
      keyboardType: TextInputType.number,
      readOnly: true,
      validator: (value) => InputValidator.validatePrice(value),
    );
  }

  Widget _buildCalculationToggle() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(
          value: 'price',
          label: Text(AppStrings.calculateByPrice),
          icon: Icon(Icons.attach_money),
        ),
        ButtonSegment(
          value: 'liter',
          label: Text(AppStrings.calculateByLiter),
          icon: Icon(Icons.water_drop),
        ),
      ],
      selected: {_calculationType},
      onSelectionChanged: (Set<String> newSelection) {
        setState(() {
          _calculationType = newSelection.first;
          _updateTotal();
        });
      },
    );
  }

  Widget _buildInputField() {
    return _calculationType == 'price'
        ? AppTextField(
            controller: _priceController,
            labelText: AppStrings.totalPrice,
            prefixIcon: const Icon(Icons.currency_exchange, size: 20),
            keyboardType: TextInputType.number,
            validator: (value) => InputValidator.validateCurrency(value),
            onChanged: (_) => _updateTotal(),
          )
        : AppTextField(
            controller: _literController,
            labelText: AppStrings.liters,
            prefixIcon: const Icon(Icons.opacity, size: 20),
            keyboardType: TextInputType.number,
            validator: (value) => InputValidator.validateQuantity(value),
            onChanged: (_) => _updateTotal(),
          );
  }

  Widget _buildResultSection() {
    return Column(
      children: [
        _buildResultRow(AppStrings.pricePerLiter, _pricePerLiterController.text),
        _buildResultRow(AppStrings.totalPrice, _priceController.text),
        _buildResultRow(AppStrings.liters, _literController.text),
      ],
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return AppButton(
      text: AppStrings.save,
      onPressed: _isLoading ? null : _savePurchase,
      backgroundColor: AppColors.primary,
      isLoading: _isLoading,
    );
  }

  Future<void> _savePurchase() async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
      final reportRepo = Provider.of<ReportRepository>(context, listen: false);

      final price = double.parse(_priceController.text);
      final liters = double.parse(_literController.text);

      // Simpan ke fuel_purchases
      final fuelPurchase = {
        'type': _typeController.text,
        'price': price,
        'liters': liters,
        'date': DateTime.now().millisecondsSinceEpoch,
      };
      await dbHelper.insertFuelPurchase(fuelPurchase);

      // Generate report
      final report = Report(
        type: ReportType.daily,
        total: price,
        date: DateTime.now(),
        period: DateTime.now(),
        createdAt: DateTime.now(),
        data: {
          'category': 'fuel',
          'type': _typeController.text,
          'liters': liters,
          'price_per_liter': double.parse(_pricePerLiterController.text),
        },
      );
      await reportRepo.generateReport(report);

      _showSnackBar(AppStrings.fuelSaveSuccess, isError: false, onNavigation: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ReportScreen()),
        );
      });
      _resetForm();
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false, VoidCallback? onNavigation}) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
    if (onNavigation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onNavigation();
      });
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _priceController.clear();
    _literController.clear();
    _updatePricePerLiter();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ReportScreen()),
    );
  }
}