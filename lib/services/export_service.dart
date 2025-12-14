import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';
import '../models/trip.dart';
import '../models/expense.dart';
import '../models/user.dart';
import '../services/currency_service.dart';

class ExportService {
  // Export trip data to PDF
  static Future<String> exportToPdf(
    Trip trip,
    List<Expense> expenses,
    List<User> members,
  ) async {
    final pdf = pw.Document();

    // Add trip information
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Trip Summary: ${trip.name}',
                  style: pw.TextStyle(fontSize: 24),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Duration: ${trip.startDate} to ${trip.endDate}'),
              pw.Text('Base Currency: ${trip.baseCurrency}'),
              pw.Text('Members: ${members.length}'),
              pw.SizedBox(height: 30),
              pw.Header(level: 1, child: pw.Text('Expenses')),
              pw.Table.fromTextArray(
                headers: ['Description', 'Amount', 'Paid By', 'Date'],
                data: expenses.map((expense) {
                  final paidBy = members.firstWhere(
                    (member) => member.id == expense.paidById,
                    orElse: () {
                      final unknownUser = User.empty();
                      unknownUser.name = 'Unknown';
                      return unknownUser;
                    },
                  );
                  return [
                    expense.description,
                    CurrencyService.formatCurrency(
                      expense.amount,
                      expense.currency,
                    ),
                    paidBy.name,
                    expense.dateTime.toString(),
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    // Save PDF to file
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${trip.name}_summary.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }

  // Export trip data to CSV
  static Future<String> exportToCsv(
    Trip trip,
    List<Expense> expenses,
    List<User> members,
  ) async {
    // Create CSV data
    final csvData = <List<String>>[
      ['Trip Name', trip.name],
      ['Start Date', trip.startDate.toString()],
      ['End Date', trip.endDate.toString()],
      ['Base Currency', trip.baseCurrency],
      [''],
      [
        'Description',
        'Amount',
        'Currency',
        'Paid By',
        'Participants',
        'Date',
        'Category',
      ],
      ...expenses.map((expense) {
        final paidBy = members.firstWhere(
          (member) => member.id == expense.paidById,
          orElse: () => User.empty()..name = 'Unknown',
        );

        final participants = expense.participantIds
            .map((id) {
              final user = members.firstWhere(
                (member) => member.id == id,
                orElse: () {
                  final unknownUser = User.empty();
                  unknownUser.name = 'Unknown';
                  return unknownUser;
                },
              );
              return user.name;
            })
            .join(', ');

        return [
          expense.description,
          expense.amount.toString(),
          expense.currency,
          paidBy.name,
          participants,
          expense.dateTime.toString(),
          expense.categoryId,
        ];
      }),
    ];

    // Convert to CSV string
    final csvString = const ListToCsvConverter().convert(csvData);

    // Save CSV to file
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${trip.name}_summary.csv';
    final file = File(filePath);
    await file.writeAsString(csvString);

    return filePath;
  }

  // Share settlement summary
  static Future<String> exportSettlementSummary(
    Trip trip,
    List<User> members,
    Map<String, double> balances,
  ) async {
    final pdf = pw.Document();

    // Add settlement information
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Settlement Summary: ${trip.name}',
                  style: pw.TextStyle(fontSize: 24),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Trip Duration: ${trip.startDate} to ${trip.endDate}'),
              pw.SizedBox(height: 30),
              pw.Header(level: 1, child: pw.Text('Balances')),
              pw.Table.fromTextArray(
                headers: ['Member', 'Balance'],
                data: members.map((member) {
                  final balance = balances[member.id] ?? 0.0;
                  return [
                    member.name,
                    CurrencyService.formatCurrency(balance, trip.baseCurrency),
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    // Save PDF to file
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${trip.name}_settlements.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }
}
