import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillpay/theme/app_theme.dart';
import 'package:skillpay/screens/transaction_details_screen.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  final List<Map<String, dynamic>> _transactions = const [
    {'id': 'INV - 9008879', 'date': '26/12/2022 10:30 PM', 'amount': '-\$8000'},
    {'id': 'INV - 9008879', 'date': '26/12/2022 10:30 PM', 'amount': '-\$2500'},
    {'id': 'INV - 9008879', 'date': '26/12/2022 10:30 PM', 'amount': '-\$125'},
    {'id': 'INV - 9008879', 'date': '26/12/2022 10:30 PM', 'amount': '-\$500'},
    {'id': 'INV - 9008879', 'date': '26/12/2022 10:30 PM', 'amount': '-\$8000'},
    {'id': 'INV - 9008879', 'date': '26/12/2022 10:30 PM', 'amount': '-\$2500'},
    {'id': 'INV - 9008879', 'date': '26/12/2022 10:30 PM', 'amount': '-\$500'},
    {'id': 'INV - 9008879', 'date': '26/12/2022 10:30 PM', 'amount': '-\$125'},
    {'id': 'INV - 9008879', 'date': '26/12/2022 10:30 PM', 'amount': '-\$8000'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Transactions',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined, color: Colors.white),
            onPressed: () {
              // Filter logic placeholder
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        itemCount: _transactions.length,
        itemBuilder: (context, index) {
          final tx = _transactions[index];
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => TransactionDetailsScreen(transactionData: tx)),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.sync_alt, // Represents the circular arrows from design
                      color: AppColors.textDark,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx['id'],
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tx['date'],
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    tx['amount'],
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
