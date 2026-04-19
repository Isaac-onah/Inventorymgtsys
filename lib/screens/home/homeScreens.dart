import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:myinventory/controllers/auth_controller.dart';
import 'package:myinventory/controllers/facture_controller.dart';
import 'package:myinventory/controllers/products_controller.dart';
import 'package:myinventory/screens/receipts_screen/receipts_screen.dart';
import 'package:myinventory/screens/reports/reports_screen.dart';
import 'package:provider/provider.dart';

class WalletHomeScreen extends StatefulWidget {
  const WalletHomeScreen({super.key});

  @override
  State<WalletHomeScreen> createState() => _WalletHomeScreenState();
}

class _WalletHomeScreenState extends State<WalletHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FactureController>().getSevenDaysSales();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Dashboard", style: TextStyle(color: Color(0xFF382959), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.notification, color: Color(0xFF382959)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. User Profile Header
            Consumer<AuthController>(
              builder: (context, authController, child) {
                final user = authController.user;
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                      backgroundColor: const Color(0xFF382959),
                      child: user?.photoURL == null ? const Icon(Iconsax.user, color: Colors.white) : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Welcome back,", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                          Text(user?.displayName ?? "Store Manager", style: const TextStyle(color: Color(0xFF382959), fontSize: 18, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                    if (authController.isloadingSignOut || authController.isloadingLogin)
                      const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    else
                      IconButton(
                        onPressed: () => user != null ? authController.google_signOut() : authController.signInWithGoogle(),
                        icon: Icon(user != null ? Iconsax.logout : Iconsax.login, color: const Color(0xFF382959)),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 25),

            // Main Sales Card
            // Main Sales Card
            Consumer<ProductsController>(
              builder: (context, prodController, child) {
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF4A2C7A),
                        Color(0xFF2D1B52),
                        Color(0xFF1A0F35),
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7B3FE4).withOpacity(0.35),
                        blurRadius: 32,
                        spreadRadius: -4,
                        offset: const Offset(0, 12),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.10),
                      width: 1.2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        // Glowing orb top-right
                        Positioned(
                          top: -40,
                          right: -40,
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFF9B5DE5).withOpacity(0.30),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Subtle grid/noise texture overlay
                        Positioned.fill(
                          child: Opacity(
                            opacity: 0.04,
                            child: CustomPaint(painter: _DotGridPainter()),
                          ),
                        ),
                        // Card content
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF9B5DE5).withOpacity(0.18),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: const Color(0xFF9B5DE5).withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: const Icon(
                                          Iconsax.chart_2,
                                          color: Color(0xFFCB9EFF),
                                          size: 15,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        "Total Sales",
                                        style: TextStyle(
                                          color: Color(0xFFB89ED4),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 11,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFF9B5DE5).withOpacity(0.22),
                                          const Color(0xFF6B3FA0).withOpacity(0.15),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFF9B5DE5).withOpacity(0.35),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFF5EF08A),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(0xFF5EF08A),
                                                blurRadius: 6,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Text(
                                          "Earnings",
                                          style: TextStyle(
                                            color: Color(0xFFCFB3F5),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Amount
                              Text(
                                  "₦${prodController.totalAmountSold.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 34,
                                    fontWeight: FontWeight.w700,
                                    height: 1.1,
                                  ),
                                ),


                              const SizedBox(height: 6),

                              // Divider
                              Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withOpacity(0.10),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 18),

                              // Mini stats
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildMiniStat(
                                      Iconsax.arrow_up_3,
                                      "Earned",
                                      "₦${prodController.totalAmountSold.toStringAsFixed(0)}",
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 36,
                                    color: Colors.white.withOpacity(0.08),
                                  ),
                                  Expanded(
                                    child: _buildMiniStat(
                                      Iconsax.receipt_item,
                                      "Invoices",
                                      prodController.totalTransactions.toString(),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 15),

            // 2b. Separate Chart Card with Labels
            Consumer<FactureController>(
              builder: (context, factureController, child) {
                double maxVal = 1000;
                for (var s in factureController.lastSevenDaysSales) {
                  if ((s.total_sales_in_day ?? 0) > maxVal) maxVal = s.total_sales_in_day!;
                }
                
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Daily Performance", style: TextStyle(color: Color(0xFF382959), fontSize: 14, fontWeight: FontWeight.bold)),
                          Text("Last 7 Days (₦)", style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Y-Axis Labels
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildYLabel("${(maxVal / 1000).toStringAsFixed(1)}k"),
                              const SizedBox(height: 35),
                              _buildYLabel("${(maxVal / 2000).toStringAsFixed(1)}k"),
                              const SizedBox(height: 35),
                              _buildYLabel("0"),
                            ],
                          ),
                          const SizedBox(width: 10),
                          // Chart Bars with Number Lines
                          Expanded(
                            child: Column(
                              children: [
                                Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    // Horizontal grid lines
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildGridLine(),
                                        const SizedBox(height: 48),
                                        _buildGridLine(),
                                        const SizedBox(height: 48),
                                        _buildGridLine(),
                                      ],
                                    ),
                                    // Bars
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: factureController.lastSevenDaysSales.isEmpty 
                                          ? List.generate(7, (index) => _buildPlaceholderBar())
                                          : factureController.lastSevenDaysSales.map((sale) {
                                              return _buildChartBar(sale.total_sales_in_day ?? 0, maxVal, const Color(0xFF382959));
                                            }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                // X-Axis Labels (Day numbers)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: factureController.lastSevenDaysSales.isEmpty
                                      ? List.generate(7, (index) => _buildXLabel("--"))
                                      : factureController.lastSevenDaysSales.map((sale) {
                                          return _buildXLabel(sale.day_in_month.toString());
                                        }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 15),

            // 3. Horizontal Stats Scroll
            Consumer<ProductsController>(
              builder: (context, prodController, child) {
                return SizedBox(
                  height: 150,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildStatCard("Inventory", prodController.totalStock.toString(), "Total units", Iconsax.box, Colors.indigo),
                      _buildStatCard("Transactions", prodController.totalTransactions.toString(), "Total sales", Iconsax.receipt_2, Colors.orangeAccent),
                      _buildStatCard("Items Sold", prodController.totalItemsSold.toString(), "Total volume", Iconsax.shopping_cart, Colors.pinkAccent),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 15),

            // Action Cards
            _buildActionCard(
              "Receipts History",
              "View and search all transactions",
              Iconsax.document_text,
              Colors.orangeAccent,
              () => Get.to(() => ReceiptsScreen()),
            ),

            const SizedBox(height: 12),

            _buildActionCard(
              "Analytics & Reports",
              "Generate detailed business reports",
              Iconsax.chart_21,
              Colors.blueAccent,
              () => Get.to(() => ReportsScreen()),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildYLabel(String label) {
    return Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 10, fontWeight: FontWeight.bold));
  }

  Widget _buildXLabel(String label) {
    return SizedBox(width: 14, child: Center(child: Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 9, fontWeight: FontWeight.bold))));
  }

  Widget _buildGridLine() {
    return Container(width: double.infinity, height: 1, color: Colors.grey[100]);
  }

  Widget _buildChartBar(double value, double maxValue, Color color) {
    double percentage = value / maxValue;
    if (percentage < 0.05 && value > 0) percentage = 0.05;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 14,
          height: 96 * percentage,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderBar() {
    return Container(
      width: 14,
      height: 10,
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
    );
  }
  Widget _buildMiniStat(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: const Color(0xFFCB9EFF), size: 14),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.40),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.1), radius: 18, child: Icon(icon, color: color, size: 18)),
          const Spacer(),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(color: Color(0xFF382959), fontSize: 22, fontWeight: FontWeight.w900)),
          Text(subtitle, style: TextStyle(color: Colors.grey[400], fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Color(0xFF382959), fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
          ],
        ),
      ),
    );
  }
}
class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    const spacing = 18.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}