import 'package:flutter/material.dart';
import 'package:in_your_hand/core/utils/screen_util.dart';
import 'package:in_your_hand/features/orders/data/payment_model.dart';

import '../../../../core/generated/extentions.dart';
import '../../../../l10n/app_localizations.dart';

class PaymentHistoryTable extends StatefulWidget {
  final List<PaymentModel> payments;

  const PaymentHistoryTable({
    super.key,
    required this.payments,
  });

  @override
  State<PaymentHistoryTable> createState() => _PaymentHistoryTableState();
}

class _PaymentHistoryTableState extends State<PaymentHistoryTable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant PaymentHistoryTable oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.payments.length != widget.payments.length) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.payments.isEmpty) {
      return const SizedBox();
    }

    final theme = Theme.of(context).textTheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: EdgeInsets.all(12),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                blurRadius: 6,
                color: Colors.black.withOpacity(0.05),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),

              Divider(),

              /// Rows
              ...widget.payments.map(
                    (payment) => _AnimatedPaymentRow(payment: payment),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(TextTheme theme) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.amountLabel,
            style: theme.bodyMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(
            l10n.dateLabel,
            style: theme.bodyMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
class _AnimatedPaymentRow extends StatefulWidget {
  final PaymentModel payment;

  const _AnimatedPaymentRow({
    required this.payment,
  });

  @override
  State<_AnimatedPaymentRow> createState() =>
      _AnimatedPaymentRowState();
}

class _AnimatedPaymentRowState
    extends State<_AnimatedPaymentRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.payment.amount.toString(),
                style: theme.bodyMedium,
              ),
            ),
            Expanded(
              child: Text(
                formatDate(widget.payment.createdAt),
                style: theme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
