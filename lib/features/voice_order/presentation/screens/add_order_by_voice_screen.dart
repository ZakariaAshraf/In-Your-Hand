import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_your_hand/core/services/gemeni_service.dart';
import 'package:in_your_hand/core/utils/screen_util.dart';
import 'package:in_your_hand/core/widgets/custom_button.dart';
import 'package:in_your_hand/features/clients/data/clients_model.dart';
import 'package:in_your_hand/features/clients/presentation/cubit/clients_cubit.dart';
import 'package:in_your_hand/features/orders/data/order_model.dart';
import 'package:in_your_hand/l10n/app_localizations.dart';

import '../cubit/voice_order_cubit.dart';

class AddOrderByVoiceScreen extends StatefulWidget {
  const AddOrderByVoiceScreen({super.key});

  @override
  State<AddOrderByVoiceScreen> createState() => _AddOrderByVoiceScreenState();
}

class _AddOrderByVoiceScreenState extends State<AddOrderByVoiceScreen> {
  @override
  void initState() {
    super.initState();
    context.read<VoiceOrderCubit>().init();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addOrderByVoice, style: theme.titleLarge),
        centerTitle: true,
      ),
      body: BlocConsumer<VoiceOrderCubit, VoiceOrderState>(
        listenWhen: (prev, curr) {
          if (curr.status == VoiceOrderStatus.success) return true;
          if (curr.status == VoiceOrderStatus.orderReadyToConfirm &&
              prev.status != VoiceOrderStatus.orderReadyToConfirm) return true;
          return false;
        },
        listener: (context, state) {
          if (state.status == VoiceOrderStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.orderAddedByVoice)),
            );
            Navigator.of(context).pop(true);
          }
          if (state.status == VoiceOrderStatus.orderReadyToConfirm &&
              state.orderPreview != null &&
              state.pendingOrder != null) {
            final clientsState = context.read<ClientsCubit>().state;
            if (clientsState is ClientsSuccess) {
              _showConfirmDialog(
                context,
                state.orderPreview!,
                state.pendingOrder!,
                clientsState.clients.where((c) => !c.isDeleted).toList(),
                l10n,
                theme,
              );
            }
          }
        },
        builder: (context, state) {
          if (state.status == VoiceOrderStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == VoiceOrderStatus.permissionDenied) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mic_off, size: 64, color: Colors.grey[600]),
                  SizedBox(height: 16.h(context)),
                  Text(
                    l10n.voicePermissionDenied,
                    textAlign: TextAlign.center,
                    style: theme.bodyLarge,
                  ),
                  SizedBox(height: 8.h(context)),
                  Text(
                    l10n.allowMicrophone,
                    textAlign: TextAlign.center,
                    style: theme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          if (state.status == VoiceOrderStatus.error && state.errorMessage != null) {
            if (state.errorMessage == 'voiceLimitReached') {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.workspace_premium,
                      size: 64,
                      color: Colors.amber,
                    ),
                    SizedBox(height: 16.h(context)),
                    Text(
                      l10n.voiceLimitReachedTitle,
                      textAlign: TextAlign.center,
                      style: theme.titleLarge,
                    ),
                    SizedBox(height: 12.h(context)),
                    Text(
                      l10n.voiceLimitReachedBody,
                      textAlign: TextAlign.center,
                      style: theme.bodyMedium?.copyWith(color: Colors.grey[700]),
                    ),
                  ],
                ),
              );
            }
            if (state.errorMessage == 'geminiQuotaExceeded') {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, size: 64, color: Colors.orange),
                    SizedBox(height: 16.h(context)),
                    Text(
                      l10n.geminiQuotaExceeded,
                      textAlign: TextAlign.center,
                      style: theme.bodyLarge,
                    ),
                    SizedBox(height: 24.h(context)),
                    CustomButton(
                      title: l10n.tryAgain,
                      onTap: () => context.read<VoiceOrderCubit>().clearError(),
                      width: 200.w(context),
                    ),
                  ],
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  SizedBox(height: 16.h(context)),
                  Text(
                    state.errorMessage!,
                    textAlign: TextAlign.center,
                    style: theme.bodyLarge,
                  ),
                  SizedBox(height: 24.h(context)),
                  CustomButton(
                    title: l10n.tryAgain,
                    onTap: () => context.read<VoiceOrderCubit>().clearError(),
                    width: 200.w(context),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 24.h(context)),
                Center(
                  child: GestureDetector(
                    onTap: state.status == VoiceOrderStatus.listening
                        ? () => context.read<VoiceOrderCubit>().stopListening()
                        : state.status == VoiceOrderStatus.processing
                            ? null
                            : () => _startListeningWithLocale(context),
                    child: Container(
                      width: 120.w(context),
                      height: 120.w(context),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: state.status == VoiceOrderStatus.listening
                            ? Colors.red.withOpacity(0.2)
                            : Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      ),
                      child: Icon(
                        state.status == VoiceOrderStatus.listening
                            ? Icons.stop_rounded
                            : Icons.mic,
                        size: 56,
                        color: state.status == VoiceOrderStatus.processing
                            ? Colors.grey
                            : (state.status == VoiceOrderStatus.listening
                                ? Colors.red
                                : Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h(context)),
                Center(
                  child: Text(
                    state.status == VoiceOrderStatus.listening
                        ? l10n.listening
                        : state.status == VoiceOrderStatus.processing
                            ? l10n.processing
                            : l10n.tapToSpeak,
                    style: theme.bodyLarge?.copyWith(color: Colors.grey[700]),
                  ),
                ),
                SizedBox(height: 24.h(context)),
                Text(
                  l10n.transcript,
                  style: theme.titleSmall?.copyWith(color: Colors.grey),
                ),
                SizedBox(height: 8.h(context)),
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(minHeight: 80),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    state.status == VoiceOrderStatus.listening
                        ? (state.transcript?.isEmpty ?? true
                            ? '...'
                            : state.transcript!)
                        : (state.transcript ?? ''),
                    style: theme.bodyMedium,
                  ),
                ),
                SizedBox(height: 24.h(context)),
                if (state.status == VoiceOrderStatus.processing) ...[
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  SizedBox(height: 16.h(context)),
                  Center(
                    child: Text(
                      l10n.processing,
                      style: theme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ),
                ] else if ((state.transcript ?? '').isNotEmpty &&
                    state.status != VoiceOrderStatus.listening &&
                    state.status != VoiceOrderStatus.orderReadyToConfirm)
                  CustomButton(
                    title: l10n.addOrderFromVoice,
                    onTap: () => _submitOrder(context),
                    height: 56.h(context),
                  ),
                if (!GeminiService.isConfigured) ...[
                  SizedBox(height: 16.h(context)),
                  Text(
                    l10n.geminiNotConfigured,
                    textAlign: TextAlign.center,
                    style: theme.bodySmall?.copyWith(color: Colors.orange),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _startListeningWithLocale(BuildContext context) {
    final locale = Localizations.localeOf(context);
    // Use BCP 47 style for better Arabic/English recognition on device
    final localeId = locale.languageCode == 'ar' ? 'ar_EG' : 'en_US';
    context.read<VoiceOrderCubit>().startListening(localeId: localeId);
  }

  void _submitOrder(BuildContext context) {
    final clientsState = context.read<ClientsCubit>().state;
    if (clientsState is! ClientsSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.errorLoadingClients)),
      );
      return;
    }
    final clients = clientsState.clients;
    context.read<VoiceOrderCubit>().submitAndAddOrder(clients: clients);
  }

  void _showConfirmDialog(
    BuildContext context,
    VoiceOrderPreview preview,
    OrderModel pendingOrder,
    List<ClientModel> clients,
    AppLocalizations l10n,
    TextTheme theme,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _VoiceOrderConfirmDialog(
        preview: preview,
        pendingOrder: pendingOrder,
        clients: clients,
        l10n: l10n,
        theme: theme,
        onConfirm: (order) async {
          Navigator.of(dialogContext).pop();
          await context.read<VoiceOrderCubit>().confirmAndAddOrder(order: order);
        },
        onCancel: () {
          Navigator.of(dialogContext).pop();
          context.read<VoiceOrderCubit>().cancelConfirm();
        },
      ),
    );
  }
}

class _VoiceOrderConfirmDialog extends StatefulWidget {
  const _VoiceOrderConfirmDialog({
    required this.preview,
    required this.pendingOrder,
    required this.clients,
    required this.l10n,
    required this.theme,
    required this.onConfirm,
    required this.onCancel,
  });

  final VoiceOrderPreview preview;
  final OrderModel pendingOrder;
  final List<ClientModel> clients;
  final AppLocalizations l10n;
  final TextTheme theme;
  final void Function(OrderModel order) onConfirm;
  final VoidCallback onCancel;

  @override
  State<_VoiceOrderConfirmDialog> createState() => _VoiceOrderConfirmDialogState();
}

class _VoiceOrderConfirmDialogState extends State<_VoiceOrderConfirmDialog> {
  late String? _selectedClientId;
  late TextEditingController _descriptionController;
  late TextEditingController _totalAmountController;
  late TextEditingController _paidController;

  @override
  void initState() {
    super.initState();
    _selectedClientId = widget.pendingOrder.clientId;
    if (!widget.clients.any((c) => c.id == _selectedClientId)) {
      _selectedClientId = widget.clients.isNotEmpty ? widget.clients.first.id : null;
    }
    _descriptionController = TextEditingController(text: widget.preview.description);
    _totalAmountController = TextEditingController(text: '${widget.preview.totalAmount}');
    _paidController = TextEditingController(text: '${widget.preview.totalPaid}');
  }

  bool get _clientsHasId => widget.clients.any((c) => c.id == _selectedClientId);
  bool get _hasSelectedClient => _selectedClientId != null && _selectedClientId!.isNotEmpty && _clientsHasId;

  @override
  void dispose() {
    _descriptionController.dispose();
    _totalAmountController.dispose();
    _paidController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_hasSelectedClient) return;
    final total = double.tryParse(_totalAmountController.text.trim());
    final paid = double.tryParse(_paidController.text.trim());
    if (total == null || total < 0) return;
    if (paid == null || paid < 0 || paid > total) return;
    final order = OrderModel(
      id: '',
      userId: widget.pendingOrder.userId,
      clientId: _selectedClientId!,
      description: _descriptionController.text.trim(),
      totalAmount: total,
      totalPaid: paid,
      createdAt: widget.pendingOrder.createdAt,
    );
    widget.onConfirm(order);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final theme = widget.theme;
    return AlertDialog(
      title: Text(l10n.confirmOrder, style: theme.titleLarge!.copyWith(color: Colors.green)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.confirmOrderMessage, style: theme.bodyMedium),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedClientId,
              decoration: InputDecoration(
                labelText: l10n.client,
                border: const OutlineInputBorder(),
              ),
              items: widget.clients
                  .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                  .toList(),
              onChanged: (id) => setState(() => _selectedClientId = id),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.description,
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _totalAmountController,
              decoration: InputDecoration(
                labelText: l10n.totalAmountLabel,
                border: const OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _paidController,
              decoration: InputDecoration(
                labelText: l10n.paidAmount.replaceAll(' (\$)', ''),
                border: const OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _hasSelectedClient &&
                  _descriptionController.text.trim().isNotEmpty &&
                  double.tryParse(_totalAmountController.text.trim()) != null &&
                  (double.tryParse(_totalAmountController.text.trim()) ?? 0) >= 0 &&
                  double.tryParse(_paidController.text.trim()) != null &&
                  (double.tryParse(_paidController.text.trim()) ?? 0) >= 0 &&
                  (double.tryParse(_paidController.text.trim()) ?? 0) <= (double.tryParse(_totalAmountController.text.trim()) ?? 0)
              ? _submit
              : null,
          child: Text(l10n.confirm),
        ),
      ],
    );
  }
}
