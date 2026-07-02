import 'package:flowfi_fe/app/app_theme.dart';
import 'package:flowfi_fe/features/shared/presentation/widgets/feature_states.dart';
import 'package:flowfi_fe/features/shared/presentation/widgets/forui_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: buildAppTheme(),
      supportedLocales: FLocalizations.supportedLocales,
      localizationsDelegates: const [...FLocalizations.localizationsDelegates],
      home: FTheme(
        data: buildForuiTheme(),
        child: Scaffold(body: child),
      ),
    );
  }

  testWidgets('FlowFiTextField shows validation errors', (tester) async {
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      wrap(
        Form(
          key: formKey,
          child: Column(
            children: [
              FlowFiTextField(
                label: 'Tên ví',
                validator: (value) =>
                    value == null || value.isEmpty ? 'Bắt buộc' : null,
              ),
              FlowFiButton(
                label: 'Lưu',
                onPressed: () => formKey.currentState!.validate(),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byType(FlowFiButton));
    await tester.pumpAndSettle();

    expect(find.text('Bắt buộc'), findsOneWidget);
  });

  testWidgets('FlowFiSelectField reports value changes', (tester) async {
    String? selected = 'cash';

    await tester.pumpWidget(
      wrap(
        StatefulBuilder(
          builder: (context, setState) {
            return FlowFiSelectField<String>(
              label: 'Loại ví',
              value: selected,
              items: const [
                FlowFiSelectItem(value: 'cash', label: 'Tiền mặt'),
                FlowFiSelectItem(value: 'bank', label: 'Ngân hàng'),
              ],
              onChanged: (value) => setState(() => selected = value),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Tiền mặt'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ngân hàng').last);
    await tester.pumpAndSettle();

    expect(selected, 'bank');
  });

  testWidgets('FlowFiCheckboxField toggles value', (tester) async {
    var accepted = false;

    await tester.pumpWidget(
      wrap(
        StatefulBuilder(
          builder: (context, setState) {
            return FlowFiCheckboxField(
              label: 'Tôi đồng ý',
              value: accepted,
              onChanged: (value) => setState(() => accepted = value),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Tôi đồng ý'));
    await tester.pumpAndSettle();

    expect(accepted, isTrue);
  });

  testWidgets('FlowFiButton disables callbacks while loading', (tester) async {
    var pressed = 0;

    await tester.pumpWidget(
      wrap(
        FlowFiButton(label: 'Lưu', isLoading: true, onPressed: () => pressed++),
      ),
    );

    await tester.tap(find.byType(FlowFiButton));
    await tester.pump(const Duration(milliseconds: 200));

    expect(pressed, 0);
  });

  testWidgets('FlowFiActionMenu opens an action sheet and invokes actions', (
    tester,
  ) async {
    var selected = false;

    await tester.pumpWidget(
      wrap(
        FlowFiActionMenu(
          tooltip: 'Tùy chọn',
          actions: [
            FlowFiMenuAction(
              label: 'Sửa',
              icon: Icons.edit_rounded,
              onSelected: () => selected = true,
            ),
          ],
        ),
      ),
    );

    expect(find.byType(PopupMenuButton), findsNothing);
    await tester.tap(find.byTooltip('Tùy chọn'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sửa'));
    await tester.pumpAndSettle();

    expect(selected, isTrue);
  });

  testWidgets('FlowFiDateField reports taps with a stable value layout', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      wrap(
        FlowFiDateField(
          label: 'Ngày',
          value: '02/07/2026',
          onTap: () => tapped = true,
        ),
      ),
    );

    expect(find.text('Ngày'), findsOneWidget);
    expect(find.text('02/07/2026'), findsOneWidget);
    await tester.tap(find.byType(FlowFiDateField));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });

  testWidgets('FlowFiProgressBar renders without Material progress widgets', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const FlowFiProgressBar(value: 0.6)));

    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byType(FlowFiProgressBar), findsOneWidget);
  });
}
