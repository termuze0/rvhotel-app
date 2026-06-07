import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class TelebirrPaymentScreen extends StatefulWidget {
  final String paymentUrl;
  final String orderNumber;
  final VoidCallback onPaymentComplete;

  const TelebirrPaymentScreen({
    super.key,
    required this.paymentUrl,
    required this.orderNumber,
    required this.onPaymentComplete,
  });

  @override
  State<TelebirrPaymentScreen> createState() => _TelebirrPaymentScreenState();
}

class _TelebirrPaymentScreenState extends State<TelebirrPaymentScreen> {
  bool _isLaunching = false;
  bool _paymentLaunched = false;

  Future<void> _launchTelebirr() async {
    setState(() => _isLaunching = true);

    try {
      final uri = Uri.parse(widget.paymentUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // ✅ Opens in browser
        );
        setState(() {
          _isLaunching = false;
          _paymentLaunched = true; // ✅ Show confirmation buttons
        });
      } else {
        setState(() => _isLaunching = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open Telebirr. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLaunching = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Telebirr Payment',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.orange.shade700,
              ),
            ),
            Text(
              'Order #${widget.orderNumber}',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: () => _showCancelConfirmation(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Icon ──
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _paymentLaunched ? Icons.check_circle : Icons.payment,
                size: 50,
                color: _paymentLaunched
                    ? Colors.green.shade600
                    : Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 24),

            // ── Title ──
            Text(
              _paymentLaunched
                  ? 'Payment Page Opened'
                  : 'Complete Payment via Telebirr',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            Text(
              'Order #${widget.orderNumber}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              _paymentLaunched
                  ? 'After completing payment in your browser, tap "I have paid" below.'
                  : 'Tap the button below to open the Telebirr payment page in your browser.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),

            // ── After payment launched: show confirm/retry buttons ──
            if (_paymentLaunched) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    widget.onPaymentComplete();
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: Text(
                    'I Have Paid',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _launchTelebirr,
                  icon: Icon(Icons.open_in_browser,
                      color: Colors.orange.shade700),
                  label: Text(
                    'Reopen Payment Page',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.orange.shade700),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ] else ...[
              // ── Before launch: show open button ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLaunching ? null : _launchTelebirr,
                  icon: _isLaunching
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.open_in_browser, color: Colors.white),
                  label: Text(
                    _isLaunching ? 'Opening...' : 'Proceed to Telebirr',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),

            // ── Cancel button ──
            TextButton.icon(
              onPressed: () => _showCancelConfirmation(),
              icon: const Icon(Icons.arrow_back, size: 16),
              label: Text(
                'Cancel Payment',
                style: GoogleFonts.poppins(color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Cancel Payment?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure? Your order is saved and you can pay later from My Orders.',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No, Continue',
                style: GoogleFonts.poppins(color: Colors.orange.shade700)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // close payment screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Yes, Cancel',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
