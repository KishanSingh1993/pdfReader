import 'package:equatable/equatable.dart';

abstract class PdfState extends Equatable {
  const PdfState();

  @override
  List<Object> get props => [];
}

class PdfInitial extends PdfState {}

class PdfLoading extends PdfState {}

class PdfLoaded extends PdfState {
  final Map<String, dynamic> extractedData;

  const PdfLoaded(this.extractedData);

  @override
  List<Object> get props => [extractedData];
}

class PdfError extends PdfState {
  final String message;

  const PdfError(this.message);

  @override
  List<Object> get props => [message];
}
