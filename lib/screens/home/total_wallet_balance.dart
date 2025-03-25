import 'package:flutter/material.dart';

class TotalWalletBalance extends StatelessWidget {
  const TotalWalletBalance({
    super.key,
    required this.context,
    required this.totalBalance,
    required this.percentage,
  });

  final BuildContext context;
  final String totalBalance;
  final percentage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color:const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        width: MediaQuery.of(context).size.width / 1.15,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Text('Total Wallet Balance', style: TextStyle(color: Colors.white.withOpacity(0.6)),),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  totalBalance,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 38,
                    color: Colors.white,
                  ),
                ),
                // for increment decrement
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: percentage >= 0
                        ? const Color(0xFF387F36)
                        : Colors.pink,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                  child: Text(
                    percentage >= 0 ? '+$percentage%' : '$percentage%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}