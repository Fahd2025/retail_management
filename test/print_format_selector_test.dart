import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:retail_management/models/print_format.dart';
import 'package:retail_management/blocs/app_config/app_config_bloc.dart';
import 'package:retail_management/blocs/app_config/app_config_event.dart';
import 'package:retail_management/blocs/app_config/app_config_state.dart';
import 'package:retail_management/widgets/print_format_selector.dart';

class MockAppConfigBloc extends AppConfigBloc {
  @override
  Stream<AppConfigState> mapEventToState(AppConfigEvent event) async* {
    if (event is UpdatePrintFormatEvent) {
      yield state.copyWith(printFormatConfig: event.config);
    }
  }
}

void main() {
  group('PrintFormatSelector Widget Tests', () {
    late AppConfigBloc appConfigBloc;

    setUp(() {
      appConfigBloc = AppConfigBloc();
    });

    tearDown(() {
      appConfigBloc.close();
    });

    testWidgets('should display all print formats', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<AppConfigBloc>(
              create: (_) => appConfigBloc,
              child: const PrintFormatSelector(),
            ),
          ),
        ),
      );

      // Should find all three format options
      expect(find.text('A4 (210×297mm)'), findsOneWidget);
      expect(find.text('80mm Thermal'), findsOneWidget);
      expect(find.text('58mm Thermal'), findsOneWidget);
    });

    testWidgets('should display display options switches', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<AppConfigBloc>(
              create: (_) => appConfigBloc,
              child: const PrintFormatSelector(),
            ),
          ),
        ),
      );

      // Should find all display option switches
      expect(find.text('Show Company Logo'), findsOneWidget);
      expect(find.text('Show QR Code'), findsOneWidget);
      expect(find.text('Show Customer Information'), findsOneWidget);
      expect(find.text('Show Notes'), findsOneWidget);
    });

    testWidgets('should show correct initial selected format', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<AppConfigBloc>(
              create: (_) => appConfigBloc,
              child: const PrintFormatSelector(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Default format should be A4
      final a4Radio = find.byWidgetPredicate(
        (widget) =>
            widget is RadioListTile<PrintFormat> &&
            widget.value == PrintFormat.a4,
      );
      expect(a4Radio, findsOneWidget);

      // Get the RadioListTile widget
      final RadioListTile<PrintFormat> radioTile =
          tester.widget(a4Radio);
      expect(radioTile.groupValue, PrintFormat.a4);
    });

    testWidgets('should toggle switch values', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<AppConfigBloc>(
              create: (_) => appConfigBloc,
              child: const PrintFormatSelector(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the "Show Company Logo" switch
      final logoSwitch = find.byWidgetPredicate(
        (widget) =>
            widget is SwitchListTile &&
            widget.title is Text &&
            (widget.title as Text).data == 'Show Company Logo',
      );

      expect(logoSwitch, findsOneWidget);

      // Initial value should be true
      SwitchListTile switchWidget = tester.widget(logoSwitch);
      expect(switchWidget.value, true);

      // Tap the switch
      await tester.tap(logoSwitch);
      await tester.pumpAndSettle();

      // Value should now be false
      switchWidget = tester.widget(logoSwitch);
      expect(switchWidget.value, false);
    });
  });

  group('PrintFormatQuickSelector Widget Tests', () {
    testWidgets('should display all print formats', (WidgetTester tester) async {
      PrintFormat selectedFormat = PrintFormat.a4;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrintFormatQuickSelector(
              selectedFormat: selectedFormat,
              onFormatChanged: (format) {
                selectedFormat = format;
              },
            ),
          ),
        ),
      );

      // Should find all three format options
      expect(find.text('A4 (210×297mm)'), findsOneWidget);
      expect(find.text('80mm Thermal'), findsOneWidget);
      expect(find.text('58mm Thermal'), findsOneWidget);
    });

    testWidgets('should show correct selected format', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrintFormatQuickSelector(
              selectedFormat: PrintFormat.thermal80mm,
              onFormatChanged: (_) {},
            ),
          ),
        ),
      );

      // Find the 80mm radio button
      final radio80mm = find.byWidgetPredicate(
        (widget) =>
            widget is RadioListTile<PrintFormat> &&
            widget.value == PrintFormat.thermal80mm,
      );

      expect(radio80mm, findsOneWidget);

      final RadioListTile<PrintFormat> radioTile =
          tester.widget(radio80mm);
      expect(radioTile.groupValue, PrintFormat.thermal80mm);
    });

    testWidgets('should call callback when format changes', (WidgetTester tester) async {
      PrintFormat? changedFormat;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrintFormatQuickSelector(
              selectedFormat: PrintFormat.a4,
              onFormatChanged: (format) {
                changedFormat = format;
              },
            ),
          ),
        ),
      );

      // Find and tap the 58mm option
      final radio58mm = find.byWidgetPredicate(
        (widget) =>
            widget is RadioListTile<PrintFormat> &&
            widget.value == PrintFormat.thermal58mm,
      );

      await tester.tap(radio58mm);
      await tester.pumpAndSettle();

      expect(changedFormat, PrintFormat.thermal58mm);
    });

    testWidgets('should display width information', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrintFormatQuickSelector(
              selectedFormat: PrintFormat.a4,
              onFormatChanged: (_) {},
            ),
          ),
        ),
      );

      // Should show width info for each format
      expect(find.text('210mm width'), findsOneWidget);
      expect(find.text('80mm width'), findsOneWidget);
      expect(find.text('58mm width'), findsOneWidget);
    });
  });
}
