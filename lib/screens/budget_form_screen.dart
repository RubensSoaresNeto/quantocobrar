import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/budget.dart';
import '../utils/formatters.dart';
import 'budget_result_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class BudgetFormScreen extends StatefulWidget {
  const BudgetFormScreen({super.key});
  @override
  State<BudgetFormScreen> createState() => _BudgetFormScreenState();
}

class _BudgetFormScreenState extends State<BudgetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _client = TextEditingController();
  final _description = TextEditingController();
  final _validity = TextEditingController(text: '7');
  final _numbers = List.generate(6, (_) => TextEditingController());
  bool _roundPrice = false;

  @override
  void initState() {
    super.initState();
    _numbers[4].text = '20';
    _numbers[5].text = '0';
  }

  @override
  void dispose() {
    _client.dispose();
    _description.dispose();
    _validity.dispose();
    for (final controller in _numbers) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _requiredText(String? text) =>
      (text ?? '').trim().isEmpty ? 'Preencha este campo' : null;
  String? _number(String? text) {
    final value = parseDecimal(text ?? '');
    if (value == null) return 'Informe um valor';
    if (value < 0) return 'Use um valor maior ou igual a zero';
    return null;
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    final values = _numbers.map((c) => parseDecimal(c.text)!).toList();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BudgetResultScreen(
          budget: Budget(
            clientName: _client.text.trim(),
            serviceDescription: _description.text.trim(),
            validityDays: int.parse(_validity.text),
            materialCost: values[0],
            hours: values[1],
            hourlyRate: values[2],
            extraExpenses: values[3],
            profitPercentage: values[4],
            discountPercentage: values[5],
            roundPrice: _roundPrice,
            createdAt: DateTime.now(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Quanto Cobrar?'),
      actions: [
        IconButton(
          tooltip: 'Histórico',
          icon: const Icon(Icons.history),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const HistoryScreen()),
          ),
        ),
        IconButton(
          tooltip: 'Configurações',
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
          ),
        ),
      ],
    ),
    body: SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Text(
              'Novo orçamento',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _client,
              validator: _requiredText,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nome do cliente',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _description,
              validator: _requiredText,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Descrição do serviço',
                prefixIcon: Icon(Icons.description_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _validity,
              validator: (text) {
                final value = int.tryParse(text ?? '');
                return value == null || value <= 0
                    ? 'Informe ao menos 1 dia'
                    : null;
              },
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Validade do orçamento',
                suffixText: ' dias',
                prefixIcon: Icon(Icons.event_outlined),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Custos',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _NumberField(
              _numbers[0],
              'Custo dos materiais',
              icon: Icons.handyman_outlined,
              prefix: 'R\$ ',
              validator: _number,
            ),
            const SizedBox(height: 16),
            _NumberField(
              _numbers[1],
              'Horas de trabalho',
              icon: Icons.schedule_outlined,
              suffix: ' h',
              validator: _number,
            ),
            const SizedBox(height: 16),
            _NumberField(
              _numbers[2],
              'Valor da sua hora',
              icon: Icons.payments_outlined,
              prefix: 'R\$ ',
              validator: _number,
            ),
            const SizedBox(height: 16),
            _NumberField(
              _numbers[3],
              'Despesas extras',
              icon: Icons.local_shipping_outlined,
              prefix: 'R\$ ',
              validator: _number,
            ),
            const SizedBox(height: 16),
            _NumberField(
              _numbers[4],
              'Acréscimo desejado',
              icon: Icons.trending_up_outlined,
              suffix: ' %',
              validator: _number,
            ),
            const SizedBox(height: 16),
            _NumberField(
              _numbers[5],
              'Desconto',
              icon: Icons.discount_outlined,
              suffix: ' %',
              validator: _number,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Arredondar valor final'),
              subtitle: const Text('Arredonda para o próximo real inteiro'),
              value: _roundPrice,
              onChanged: (value) => setState(() => _roundPrice = value),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('calculate_button'),
              onPressed: _calculate,
              icon: const Icon(Icons.calculate_outlined),
              label: const Text('Calcular orçamento'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _NumberField extends StatelessWidget {
  const _NumberField(
    this.controller,
    this.label, {
    required this.icon,
    required this.validator,
    this.prefix,
    this.suffix,
  });
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? prefix, suffix;
  final FormFieldValidator<String> validator;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    validator: validator,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))],
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      prefixText: prefix,
      suffixText: suffix,
    ),
  );
}
