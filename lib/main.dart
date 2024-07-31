import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_reader_app/bloc/pdf_bloc.dart';
import 'package:pdf_reader_app/bloc/pdf_event.dart';
import 'package:pdf_reader_app/bloc/pdf_state.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (context) => PdfBloc(),
        child: PdfReaderScreen(),
      ),
    );
  }
}

class PdfReaderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Reader App'),
      ),
      body: BlocBuilder<PdfBloc, PdfState>(
        builder: (context, state) {
          if (state is PdfInitial) {
            return Center(
              child: ElevatedButton(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
                  if (result != null) {
                    BlocProvider.of<PdfBloc>(context).add(UploadPdfEvent(result.files.single.path!));
                  }
                },
                child: const Text('Upload PDF'),
              ),
            );
          } else if (state is PdfLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PdfLoaded) {
            return _buildPdfDetails(context, state.extractedData);
          } else if (state is PdfError) {
            return Center(child: Text(state.message));
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Widget _buildPdfDetails(BuildContext context, Map<String, dynamic> data) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text('Account Number: ${data["accountNumber"]}'),
        Text('Statement Period: ${data["statementPeriod"]}'),
        Text('Closing Balance: ${data["closingBalance"]}'),
        const SizedBox(height: 20),
        const Text('Transactions:', style: TextStyle(fontWeight: FontWeight.bold)),
        ...data["transactions"].map<Widget>((transaction) {
          return ListTile(
            title: Text(transaction["description"]),
            subtitle: Text('Date: ${transaction["date"]}, Debit: ${transaction["debit"]}, Credit: ${transaction["credit"]}, Balance: ${transaction["balance"]}'),
          );
        }).toList(),
        const SizedBox(height: 20),
        Text('Balance: ${data["balance"]}'),
      ],
    );
  }
}
