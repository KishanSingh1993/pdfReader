class Transaction {
  String date;
  String description;
  String debitOrCredit;
  String balance;

  Transaction({
    required this.date,
    required this.description,
    required this.debitOrCredit,
    required this.balance,
  });

  @override
  String toString() {
    return 'Date: $date\nDescription: $description\nDebit/Credit: $debitOrCredit\nBalance: $balance\n---';
  }
}
