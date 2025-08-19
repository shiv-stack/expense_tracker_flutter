import 'package:flutter/material.dart';

void showPremiumBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => PremiumBottomSheet(),
  );
}

class PremiumBottomSheet extends StatefulWidget {
  const PremiumBottomSheet({super.key});

  @override
  State<PremiumBottomSheet> createState() => _PremiumBottomSheetState();
}

class _PremiumBottomSheetState extends State<PremiumBottomSheet> {
  final premiumFeatures = [
    'Unlimited transaction entries',
    'Can add Unlimited categories',
    'Advanced reports & statistics',
    'Data backup & sync',
    'Export to CSV/Excel',
    'Ad-free experience',
  ];
  bool monthlyselected = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0), // For draggable handle
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 16),
          Container(
            width: 50,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          SizedBox(height: 24),
          Icon(Icons.star_rounded, color: Colors.amber, size: 44),
          SizedBox(height: 8),
          Text(
            'Upgrade to Premium',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Unlock all features and take control of your finances!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          SizedBox(height: 16),
          ...premiumFeatures.map((f) => ListTile(
                leading: Icon(Icons.check_circle, color: Colors.teal),
                title: Text(f, style: TextStyle(fontSize: 15)),
                dense: true,
                visualDensity: VisualDensity.compact,
              )),
          SizedBox(height: 16),
          Row(
            children: [
              _buildPlanCard(
                context,
                title: 'Monthly',
                price: '\$3/mo',
                highlight: monthlyselected,
                onTap: () {
                  setState(() {
                    monthlyselected = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Premium features coming soon!!')));
                  // Navigator.pop(context);
                },
              ),
              SizedBox(width: 12),
              _buildPlanCard(
                context,
                title: 'Yearly',
                price: '\$20/yr',
                highlight: !monthlyselected,
                onTap: () {
                  setState(() {
                    monthlyselected = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Premium features coming soon!!')));
                },
              ),
            ],
          ),
          SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Not now', style: TextStyle(color: Colors.grey[600])),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context,
      {required String title, required String price, required bool highlight, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          margin: EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: highlight ? Colors.teal : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: highlight ? Colors.teal : Colors.grey.shade300, width: highlight ? 2 : 1),
            boxShadow: highlight
                ? [BoxShadow(color: Colors.teal.withOpacity(0.12), blurRadius: 10, offset: Offset(0, 2))]
                : [],
          ),
          child: Column(
            children: [
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15, color: highlight ? Colors.white : Colors.teal)),
              SizedBox(height: 6),
              Text(price,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 17, color: highlight ? Colors.white : Colors.teal)),
              if (highlight) ...[
                SizedBox(height: 6),
                Text('Save 45%', style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
