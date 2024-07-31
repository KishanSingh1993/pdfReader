import 'package:equatable/equatable.dart';

abstract class PdfEvent extends Equatable {
  const PdfEvent();

  @override
  List<Object> get props => [];
}

class UploadPdfEvent extends PdfEvent {
  final String filePath;

  const UploadPdfEvent(this.filePath);

  @override
  List<Object> get props => [filePath];
}
