import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:pdf_reader_app/bloc/pdf_event.dart';
import 'package:pdf_reader_app/bloc/pdf_state.dart';

import '../model/transaction.dart';


class PdfBloc extends Bloc<PdfEvent, PdfState> {
  PdfBloc() : super(PdfInitial()) {
    on<UploadPdfEvent>(_onUploadPdfEvent);
  }

  String closingBalance = 'N/A';
  List<Transaction> transactions = [];

  void _onUploadPdfEvent(UploadPdfEvent event, Emitter<PdfState> emit) async {
    emit(PdfLoading());
    try {
      final file = File(event.filePath);
      final pdfDocument = PdfDocument(inputBytes: file.readAsBytesSync());
      final extractedData = await _extractDetailsFromPdf(pdfDocument);
      emit(PdfLoaded(extractedData));
    } catch (e) {
      emit(PdfError("Failed to load PDF: $e"));
    }
  }

  Future<Map<String, dynamic>> _extractDetailsFromPdf(
      PdfDocument pdfDocument) async {
    String text = PdfTextExtractor(pdfDocument).extractText();
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    // Extract account number
    //final accountNumberRegExp = RegExp(r'Account Number\s+(\d+)', caseSensitive: false);
    final accountNumberRegExp = RegExp(r'Account Number\s+([\d\s]+)', caseSensitive: false);
    final accountNumberMatch = accountNumberRegExp.firstMatch(text);
    final accountNumber = accountNumberMatch?.group(1) ?? 'N/A';

    // Extract statement period
    final statementPeriodRegExp = RegExp(r'Statement Period\s+(\d{1,2}\s\w+\s\d{4})\s*-\s*(\d{1,2}\s\w+\s\d{4})',
        caseSensitive: false);
    final statementPeriodMatch = statementPeriodRegExp.firstMatch(text);
    final startDate = statementPeriodMatch?.group(1) ?? 'N/A';
    final endDate = statementPeriodMatch?.group(2) ?? 'N/A';
    final statementPeriod = '$startDate - $endDate';
    debugPrint('Statement Period: $statementPeriod');

    // Extract closing balance
    // Example text
    const text1 = 'Closing Balance \$401.22 CR';
    // Print input text
    debugPrint('Input Text: $text1');
    // Extract closing balance
    extractClosingBalance(text1);
    // Print closing balance
    debugPrint('Closing Balance: $closingBalance');

    // Extract date (Assuming the date is always at the top of the statement)
    final dateRegExp = RegExp(r'\b(\d{1,2} \w+ \d{4})\b', caseSensitive: false);
    final dateMatch = dateRegExp.firstMatch(text);
    final date = dateMatch?.group(1) ?? 'N/A';

    // Extract transactions
    extractTransactions(text);

    // Print transactions for debugging
    for (var transaction in transactions) {
      debugPrint('$transaction');
    }

    return {
      "accountNumber": accountNumber,
      "statementPeriod": statementPeriod,
      "closingBalance": closingBalance,
      "date": date,
      "transactions": transactions,
      "balance": closingBalance,
    };
  }

  // Function to extract closing balance
  void extractClosingBalance(String text) {
    // Define the regex pattern
    final closingBalanceRegExp = RegExp(
        r'Closing Balance\s*\$\s*(\d+\.\d{2})\s*(\w+)',
        caseSensitive: false);

    // Match the regex pattern with the input text
    final closingBalanceMatch = closingBalanceRegExp.firstMatch(text);

    if (closingBalanceMatch != null) {
      // Capture the balance amount and type
      final balanceAmount = closingBalanceMatch.group(1) ?? 'N/A';
      final balanceType = closingBalanceMatch.group(2) ?? 'N/A';
      closingBalance = '\$$balanceAmount $balanceType';
    } else {
      closingBalance = 'N/A';
    }
  }

  // Function to extract transactions from the text
  void extractTransactions(String text) {
    // Removing everything above the first occurrence of "Date"
    final firstDateIndex = text.indexOf('Date');
    if (firstDateIndex != -1) {
      final cleanedTransactionData = text.substring(firstDateIndex);

      final regex = RegExp(
        r'(\d{2} \w{3})\s+([\s\S]*?)\s+((\d{1,3}(?:,\d{3})*\.\d{2})|S?[\d,]+\.\d{2})\s*([A-Z\d,]+\.\d{2} [A-Z]{2})',
        multiLine: true,
      );

      final matches = regex.allMatches(cleanedTransactionData);

      transactions = matches.map((match) {
        final date = match.group(1)!;
        final description = match.group(2)!.trim();
        final debitOrCredit = match.group(3)!.replaceAll('S', '').trim();
        final balance = match.group(5)!.trim();

        return Transaction(
          date: date,
          description: description,
          debitOrCredit: debitOrCredit,
          balance: balance,
        );
      }).toList();
    }
  }
}








// class PdfBloc extends Bloc<PdfEvent, PdfState> {
//   PdfBloc() : super(PdfInitial()) {
//     on<UploadPdfEvent>(_onUploadPdfEvent);
//   }
//
//   String closingBalance = 'N/A';
//   List<Map<String, String>> transactions = [];
//
//   void _onUploadPdfEvent(UploadPdfEvent event, Emitter<PdfState> emit) async {
//     emit(PdfLoading());
//     try {
//       final file = File(event.filePath);
//       final pdfDocument = PdfDocument(inputBytes: file.readAsBytesSync());
//       final extractedData = await _extractDetailsFromPdf(pdfDocument);
//       emit(PdfLoaded(extractedData));
//     } catch (e) {
//       emit(PdfError("Failed to load PDF: $e"));
//     }
//   }
//
//   Future<Map<String, dynamic>> _extractDetailsFromPdf(PdfDocument pdfDocument) async {
//     String text = PdfTextExtractor(pdfDocument).extractText();
//
//     // Extract account number
//     //final accountNumberRegExp = RegExp(r'Account Number\s+(\d+)', caseSensitive: false);
//     final accountNumberRegExp = RegExp(r'Account Number\s+([\d\s]+)', caseSensitive: false);
//     final accountNumberMatch = accountNumberRegExp.firstMatch(text);
//     final accountNumber = accountNumberMatch?.group(1) ?? 'N/A';
//
//     // Extract statement period
//     final statementPeriodRegExp = RegExp(r'Statement Period\s+(\d{1,2}\s\w+\s\d{4})\s*-\s*(\d{1,2}\s\w+\s\d{4})', caseSensitive: false);
//     final statementPeriodMatch = statementPeriodRegExp.firstMatch(text);
//     final startDate = statementPeriodMatch?.group(1) ?? 'N/A';
//     final endDate = statementPeriodMatch?.group(2) ?? 'N/A';
//     final statementPeriod = '$startDate - $endDate';
//     print('Statement Period: $statementPeriod');
//
//     // Extract closing balance
//     const text1 = 'Closing Balance \$401.22 CR';
//     extractClosingBalance(text1);
//     // Print closing balance
//     print('Closing Balance: $closingBalance');
//
//     // Extract date (Assuming the date is always at the top of the statement)
//     final dateRegExp = RegExp(r'\b(\d{1,2} \w+ \d{4})\b', caseSensitive: false);
//     final dateMatch = dateRegExp.firstMatch(text);
//     final date = dateMatch?.group(1) ?? 'N/A';
//
//     // Extract transactions
//     extractTransactions(text);
//
//     // Print transactions for debugging
//     for (var transaction in transactions) {
//       print(transaction);
//     }
//
//     return {
//       "accountNumber": accountNumber,
//       "statementPeriod": statementPeriod,
//       "closingBalance": closingBalance,
//       "date": date,
//       "transactions": transactions,
//       "balance": closingBalance,
//     };
//   }
//
//   // Function to extract closing balance
//   void extractClosingBalance(String text) {
//     // Define the regex pattern
//     final closingBalanceRegExp = RegExp(r'Closing Balance\s*\$\s*(\d+\.\d{2})\s*(\w+)', caseSensitive: false);
//
//     // Match the regex pattern with the input text
//     final closingBalanceMatch = closingBalanceRegExp.firstMatch(text);
//
//     if (closingBalanceMatch != null) {
//       // Capture the balance amount and type
//       final balanceAmount = closingBalanceMatch.group(1) ?? 'N/A';
//       final balanceType = closingBalanceMatch.group(2) ?? 'N/A';
//       closingBalance = '\$$balanceAmount $balanceType';
//     } else {
//       closingBalance = 'N/A';
//     }
//   }
//
//   // Function to extract transactions from the text
//
//   void extractTransactions(String text) {
//     // Define the regex pattern for transactions
//     final transactionsRegExp = RegExp(
//       r'(\d{1,2} \w+ \d{4})\s+(.+?)\s+(\$\d+\.\d{2})?\s*(CR)?\s*(\$\d+\.\d{2} CR?)?',
//       caseSensitive: false,
//       multiLine: true,
//     );
//
//     // Match the regex pattern with the input text
//     final transactionsMatches = transactionsRegExp.allMatches(text);
//
//     // Debugging: print raw matches
//     print('Total matches found: ${transactionsMatches.length}');
//     transactionsMatches.forEach((match) {
//       print('Match: ${match.group(0)}');
//     });
//
//     // Extract transactions
//     transactions = transactionsMatches.map((match) {
//       return {
//         "date": match.group(1) ?? '',
//         "description": match.group(2) ?? '',
//         "debit": (match.group(3) != null && match.group(4) == null) ? match.group(3)! : '',
//         "credit": (match.group(3) != null && match.group(4) != null) ? match.group(3)! : '',
//         "balance": match.group(5) ?? '',
//       };
//     }).toList();
//   }
//
// }
