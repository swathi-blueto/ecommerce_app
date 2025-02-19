import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';

class RazorService {
  late Razorpay _razorpay;
  Function(String)? onSuccess;
  Function(String)? onFailure;

  RazorService({this.onSuccess, this.onFailure}) {
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (onSuccess != null) onSuccess!(response.paymentId ?? "");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (onFailure != null) onFailure!(response.message ?? "Payment failed");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("External Wallet Selected: ${response.walletName}");
  }

  void startPayment({
    required String name,
    required int amount,
    required String contact,
    required String email,
  }) {
    var options = {
      'key': 'rzp_test_0PcejQLIv802bL',
      'amount': amount * 100,
      'name': name,
      'description': 'Payment for $name',
      'prefill': {'contact': contact, 'email': email},
      'external': {'wallets': ['paytm']},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print("Error starting Razorpay: $e");
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}
