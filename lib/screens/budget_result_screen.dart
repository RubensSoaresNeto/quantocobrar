import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../models/budget.dart';
import '../models/professional_profile.dart';
import '../services/local_storage.dart';
import '../utils/formatters.dart';

class BudgetResultScreen extends StatefulWidget {
  const BudgetResultScreen({
    super.key,
    required this.budget,
    this.saveToHistory = true,
  });
  final Budget budget;
  final bool saveToHistory;
  @override
  State<BudgetResultScreen> createState() => _BudgetResultScreenState();
}

class _BudgetResultScreenState extends State<BudgetResultScreen> {
  ProfessionalProfile _profile = const ProfessionalProfile();
  Budget get budget => widget.budget;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.saveToHistory) await LocalStorage().saveBudget(budget);
    final profile = await LocalStorage().loadProfile();
    if (mounted) setState(() => _profile = profile);
  }

  String get _text {
    final professional = _profile.name.isEmpty
        ? ''
        : '${_profile.name}${_profile.profession.isEmpty ? '' : ' • ${_profile.profession}'}\n';
    final contact = _profile.phone.isEmpty
        ? ''
        : 'Contato: ${_profile.phone}\n';
    final pix = _profile.pixKey.isEmpty ? '' : 'Pix: ${_profile.pixKey}\n';
    return '''*ORÇAMENTO DE SERVIÇO*

$professional$contact
Cliente: ${budget.clientName}
Serviço: ${budget.serviceDescription}

Materiais: ${formatCurrency(budget.materialCost)}
Mão de obra (${budget.hours.toStringAsFixed(1)} h): ${formatCurrency(budget.laborCost)}
Despesas extras: ${formatCurrency(budget.extraExpenses)}
Acréscimo (${budget.profitPercentage.toStringAsFixed(1)}%): ${formatCurrency(budget.profitAmount)}
Desconto (${budget.discountPercentage.toStringAsFixed(1)}%): -${formatCurrency(budget.discountAmount)}

*TOTAL: ${formatCurrency(budget.suggestedPrice)}*

Validade: ${budget.validityDays} dias.
$pix''';
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _text));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Orçamento copiado')));
    }
  }

  Future<void> _share() async => SharePlus.instance.share(
    ShareParams(text: _text, subject: 'Orçamento de serviço'),
  );

  Future<Uint8List> _buildPdf(PdfPageFormat format) async {
    final document = pw.Document();
    document.addPage(
      pw.Page(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(42),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'ORÇAMENTO DE SERVIÇO',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 12),
            if (_profile.name.isNotEmpty)
              pw.Text(
                _profile.name,
                style: pw.TextStyle(
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            if (_profile.profession.isNotEmpty) pw.Text(_profile.profession),
            if (_profile.phone.isNotEmpty)
              pw.Text('Contato: ${_profile.phone}'),
            pw.Divider(height: 28),
            pw.Text('Cliente: ${budget.clientName}'),
            pw.Text('Serviço: ${budget.serviceDescription}'),
            pw.SizedBox(height: 20),
            _pdfRow('Materiais', budget.materialCost),
            _pdfRow('Mão de obra', budget.laborCost),
            _pdfRow('Despesas extras', budget.extraExpenses),
            _pdfRow('Acréscimo', budget.profitAmount),
            _pdfRow('Desconto', -budget.discountAmount),
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'TOTAL',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  formatCurrency(budget.suggestedPrice),
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 24),
            pw.Text('Orçamento válido por ${budget.validityDays} dias.'),
            if (_profile.pixKey.isNotEmpty)
              pw.Text('Chave Pix: ${_profile.pixKey}'),
          ],
        ),
      ),
    );
    return document.save();
  }

  pw.Widget _pdfRow(String label, double value) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 5),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [pw.Text(label), pw.Text(formatCurrency(value))],
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Seu orçamento')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.check_circle_outline, size: 42),
                  const SizedBox(height: 8),
                  Text(
                    budget.clientName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatCurrency(budget.suggestedPrice),
                    key: const Key('suggested_price'),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            budget.serviceDescription,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _ResultRow('Materiais', budget.materialCost),
          _ResultRow(
            'Mão de obra (${budget.hours.toStringAsFixed(1)} h)',
            budget.laborCost,
          ),
          _ResultRow('Despesas extras', budget.extraExpenses),
          _ResultRow('Acréscimo', budget.profitAmount),
          if (budget.discountAmount > 0)
            _ResultRow('Desconto', -budget.discountAmount),
          const Divider(height: 24),
          Text('Válido por ${budget.validityDays} dias'),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _share,
            icon: const Icon(Icons.share_outlined),
            label: const Text('Compartilhar no WhatsApp'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _copy,
            icon: const Icon(Icons.copy_outlined),
            label: const Text('Copiar texto'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => Printing.layoutPdf(
              onLayout: _buildPdf,
              name: 'orcamento-${budget.clientName}.pdf',
            ),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Gerar PDF'),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Editar valores'),
          ),
        ],
      ),
    ),
  );
}

class _ResultRow extends StatelessWidget {
  const _ResultRow(this.label, this.value);
  final String label;
  final double value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(formatCurrency(value)),
      ],
    ),
  );
}
