 class CardDetails {
  final String cardHolderName;
  final String cardNumber;
  final String expiryMonth;
  final String expiryYear;
  final String cvv;

  CardDetails({
    required this.cardHolderName,
    required this.cardNumber,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
  });
}