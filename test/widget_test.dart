import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quanto_cobrar/main.dart';

void main() {
  testWidgets('calcula o exemplo informado', (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const QuantoCobrarApp());
    final fields = find.byType(EditableText);
    await tester.enterText(fields.at(0), 'Cliente teste');
    await tester.enterText(fields.at(1), 'Instalação elétrica');
    await tester.enterText(fields.at(2), '7');
    await tester.enterText(fields.at(3), '80');
    await tester.enterText(fields.at(4), '3');
    await tester.enterText(fields.at(5), '40');
    await tester.enterText(fields.at(6), '20');
    await tester.enterText(fields.at(7), '20');
    await tester.enterText(fields.at(8), '0');
    await tester.ensureVisible(find.byKey(const Key('calculate_button')));
    await tester.tap(find.byKey(const Key('calculate_button')));
    await tester.pumpAndSettle();
    expect(find.text('R\$ 264,00'), findsOneWidget);
    expect(find.text('Compartilhar no WhatsApp'), findsOneWidget);
  });
}
