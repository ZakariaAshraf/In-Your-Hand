import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_your_hand/core/utils/screen_util.dart';
import 'package:in_your_hand/core/widgets/default_message_card.dart';
import 'package:in_your_hand/features/dashboard/presentation/cubit/dashboard_cubit.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../clients/presentation/cubit/clients_cubit.dart';

class DashboardScreen extends StatefulWidget {
  final String userId;

  const DashboardScreen({super.key, required this.userId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    context.read<DashboardCubit>().loadDashboard(widget.userId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.dashboardTitle), centerTitle: true),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoaded) {
            final dashboard = state.dashboard;
            return GridView(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 7,
                childAspectRatio: 0.6,
              ),
              children: [
                /// total amount
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: BoxBorder.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: Text(
                            "EGP",
                            style: TextStyle(color: Colors.green),
                          ),
                        ),
                        SizedBox(height: 10.h(context)),
                        Text(
                          "${dashboard.totalAmount}",
                          style: theme.titleLarge!.copyWith(
                            fontSize: 30.sp(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10.h(context)),
                        Text(
                          l10n.totalAmountLabel,
                          style: theme.bodySmall!.copyWith(
                            fontSize: 16.sp(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// total clients with dept
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: BoxBorder.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: Icon(
                            CupertinoIcons.person_2,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 10.h(context)),
                        Text(
                          "${dashboard.clientsWithDebt}",
                          style: theme.titleLarge!.copyWith(
                            fontSize: 30.sp(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10.h(context)),
                        Text(
                          l10n.totalClientsWithDebt,
                          style: theme.bodySmall!.copyWith(
                            fontSize: 16.sp(context),
                          ),
                        ),
                        SizedBox(height: 6.h(context)),
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (dialogContext) {
                                final dialogL10n = AppLocalizations.of(
                                  dialogContext,
                                )!;
                                return AlertDialog(
                                  title: Text(
                                    dialogL10n.clientsWithDebtTitle,
                                    style: theme.titleLarge,
                                  ),
                                  content: SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.9,
                                    height: MediaQuery.of(context).size.height * 0.4,
                                    child: ListView.builder(
                                      itemCount: dashboard.clientsIds.length,
                                      itemBuilder: (context, index) {
                                        final clientId = dashboard.clientsIds[index];
                                        final client = context.read<ClientsCubit>().clientsMap[clientId];
                                        final clientName = client == null
                                            ? l10n.unknownClient
                                            : client.isDeleted
                                            ? l10n.deletedClient
                                            : client.name;
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: BoxBorder.all(color: Colors.grey.shade300),
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                            child: ListTile(
                                              leading: Icon(CupertinoIcons.person),
                                              title: Text(clientName,style: theme.titleMedium,),
                                              subtitle: client?.phone!= "" ?Text(client!.phone!,style: theme.titleMedium!.copyWith(color: Colors.grey),) : null,
                                            ),
                                          ),
                                        );
                                      }

                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext),
                                      child: Text(
                                        dialogL10n.cancel,
                                        style: theme.titleMedium,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                l10n.checkThem,
                                style: theme.titleSmall!.copyWith(
                                  fontSize: 16.sp(context),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// total Paid
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: BoxBorder.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: Text(
                            "EGP",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        SizedBox(height: 10.h(context)),
                        Text(
                          "${dashboard.totalPaid}",
                          style: theme.titleLarge!.copyWith(
                            fontSize: 30.sp(context),
                            fontWeight: FontWeight.bold,

                          ),
                        ),
                        SizedBox(height: 10.h(context)),
                        Text(
                          l10n.totalPaid,
                          style: theme.bodySmall!.copyWith(
                            fontSize: 16.sp(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// total unPaid
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: BoxBorder.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: Text(
                            "EGP",
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                        SizedBox(height: 10.h(context)),
                        Text(
                          "${dashboard.totalUnpaid}",
                          style: theme.titleLarge!.copyWith(
                            fontSize: 30.sp(context),
                            fontWeight: FontWeight.bold,
                            color: dashboard.totalUnpaid >0?Colors.red :Colors.green,
                          ),
                        ),
                        SizedBox(height: 10.h(context)),
                        Text(
                          l10n.totalUnpaid,
                          style: theme.bodySmall!.copyWith(
                            fontSize: 16.sp(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                /// total orders
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: BoxBorder.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.transparent,
                          child: Icon(
                            CupertinoIcons.list_bullet_below_rectangle,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 10.h(context)),
                        Text(
                          "${dashboard.totalOrders}",
                          style: theme.titleLarge!.copyWith(
                            fontSize: 40.sp(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10.h(context)),
                        Text(
                          l10n.totalOrders,
                          style: theme.bodySmall!.copyWith(
                            fontSize: 16.sp(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else if (state is DashboardLoading) {
            return Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          } else if (state is DashboardError) {
            return Center(
              child: DefaultMessageCard(
                sign: "😡",
                title: l10n.errorTitle,
                subTitle: state.errorMessage,
              ),
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}
