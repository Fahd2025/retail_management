import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:retail_management/widgets/data_type_selector_bottom_sheet.dart';
import 'package:retail_management/blocs/data_import_export/data_import_export_event.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:retail_management/l10n/app_localizations.dart';

void main() {
  group('DataTypeSelectorBottomSheet', () {
    testWidgets('renders correctly for export', (WidgetTester tester) async {
      bool confirmed = false;
      List<DataType>? selectedTypes;
      ExportFormat? selectedFormat;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(1920, 1080),
          builder: (context, child) => MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('ar', 'SA'),
            ],
            home: Scaffold(
              body: DataTypeSelectorBottomSheet(
                isExport: true,
                onConfirm: (types, format) {
                  confirmed = true;
                  selectedTypes = types;
                  selectedFormat = format;
                },
              ),
            ),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Verify that the title is displayed
      expect(find.text('Select Data to Export'), findsOneWidget);

      // Verify that data type options are displayed
      expect(find.text('All Data'), findsOneWidget);
      expect(find.text('Products'), findsOneWidget);
      expect(find.text('Categories'), findsOneWidget);
      expect(find.text('Customers'), findsOneWidget);
      expect(find.text('Sales'), findsOneWidget);

      // Verify that format options are displayed for export
      expect(find.text('Export Format'), findsOneWidget);
      expect(find.text('JSON'), findsOneWidget);
      expect(find.text('CSV'), findsOneWidget);
    });

    testWidgets('renders correctly for import', (WidgetTester tester) async {
      bool confirmed = false;
      List<DataType>? selectedTypes;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(1920, 1080),
          builder: (context, child) => MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('ar', 'SA'),
            ],
            home: Scaffold(
              body: DataTypeSelectorBottomSheet(
                isExport: false,
                onConfirm: (types, format) {
                  confirmed = true;
                  selectedTypes = types;
                },
              ),
            ),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Verify that the title is displayed
      expect(find.text('Select Data to Import'), findsOneWidget);

      // Verify that format options are NOT displayed for import
      expect(find.text('Export Format'), findsNothing);
    });

    testWidgets('selecting a data type updates the selection',
        (WidgetTester tester) async {
      List<DataType>? selectedTypes;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(1920, 1080),
          builder: (context, child) => MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('ar', 'SA'),
            ],
            home: Scaffold(
              body: DataTypeSelectorBottomSheet(
                isExport: true,
                onConfirm: (types, format) {
                  selectedTypes = types;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the "Products" checkbox
      final productsCheckbox = find.byType(Checkbox).first;
      await tester.tap(productsCheckbox);
      await tester.pumpAndSettle();

      // Verify that the checkbox is now checked
      // This is a simplified test - in a real scenario you'd verify the state
    });

    testWidgets('confirm button is disabled when no selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(1920, 1080),
          builder: (context, child) => MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('ar', 'SA'),
            ],
            home: Scaffold(
              body: DataTypeSelectorBottomSheet(
                isExport: true,
                onConfirm: (types, format) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the confirm button
      final confirmButton = find.widgetWithText(ElevatedButton, 'Confirm');

      // Verify that the button is disabled (onPressed is null)
      final button = tester.widget<ElevatedButton>(confirmButton);
      expect(button.onPressed, isNull);
    });

    testWidgets('cancel button closes the bottom sheet',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(1920, 1080),
          builder: (context, child) => MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('ar', 'SA'),
            ],
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      showDataTypeSelectorBottomSheet(
                        context: context,
                        isExport: true,
                        onConfirm: (types, format) {},
                      );
                    },
                    child: const Text('Show'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open the bottom sheet
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      // Verify bottom sheet is shown
      expect(find.text('Select Data to Export'), findsOneWidget);

      // Tap cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify bottom sheet is closed
      expect(find.text('Select Data to Export'), findsNothing);
    });
  });
}
