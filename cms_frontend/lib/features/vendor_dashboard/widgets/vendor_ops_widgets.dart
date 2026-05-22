import 'package:flutter/material.dart';

const vendorMint = Color(0xFF4ADDA2);
const vendorSurface = Color(0xFF141414);
const vendorBorder = Color(0xFF2A2A2A);
const vendorMuted = Color(0xFF8A8A8A);

class VendorSectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const VendorSectionCard({super.key, required this.child, this.padding = const EdgeInsets.all(24)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: vendorSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: vendorBorder),
      ),
      child: child,
    );
  }
}

class VendorKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const VendorKpiCard({super.key, required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return VendorSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(title, style: const TextStyle(color: vendorMuted, fontWeight: FontWeight.w600))),
              Icon(icon, color: color, size: 22),
            ],
          ),
          const SizedBox(height: 14),
          Text(value, style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class VendorStatusPill extends StatelessWidget {
  final String status;

  const VendorStatusPill({super.key, required this.status});

  Color get color {
    switch (status) {
      case 'Charging':
      case 'Active':
      case 'Authorized':
      case 'Captured':
      case 'Settled':
      case 'Available':
        return vendorMint;
      case 'Faulted':
      case 'Failed':
        return Colors.redAccent;
      case 'Refunded':
      case 'Processed':
        return Colors.blueAccent;
      case 'Offline':
        return vendorMuted;
      default:
        return Colors.orangeAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(50), border: Border.all(color: color.withOpacity(0.25))),
      child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

class VendorPageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? action;

  const VendorPageHeader({super.key, required this.title, required this.subtitle, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(subtitle, style: const TextStyle(color: vendorMuted)),
            ],
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

String money(dynamic value) {
  final amount = double.tryParse(value?.toString() ?? '0') ?? 0;
  return 'Rs. ${amount.toStringAsFixed(2)}';
}
