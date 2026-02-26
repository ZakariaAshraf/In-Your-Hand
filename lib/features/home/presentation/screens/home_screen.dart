import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_your_hand/core/utils/screen_util.dart';
import 'package:in_your_hand/core/widgets/custom_button.dart';
import 'package:in_your_hand/features/clients/presentation/screens/add_clients_screen.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../clients/presentation/cubit/clients_cubit.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../orders/data/order_model.dart';
import '../../../orders/presentation/cubit/orders_cubit.dart';
import '../../../orders/presentation/screens/add_order_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    context.read<ClientsCubit>().getClients();
    context.read<OrdersCubit>().getOrders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            BlocBuilder<OrdersCubit, OrdersState>(builder: (context, state) {
              if (state is OrdersSuccess) {
                // final totalOrders = state.orders.length;
                // print("Orders fetched: ${totalOrders}");
                //
                // final unpaidTotal = state.orders.fold<double>(
                //   0,
                //       (sum, o) => sum + o.remainingAmount,
                // );
                //
                // final userId=state.orders.first.userId;
                final totalOrders = state.orders.length;

                if (state.orders.isEmpty) {
                  return SizedBox.shrink();
                }
                final unpaidTotal = state.orders.fold<double>(
                  0,
                      (sum, o) => sum + o.remainingAmount,
                );
                final userId = state.orders.first.userId;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                // width: 160.w(context),
                                // height: 190.h(context),
                                // margin: EdgeInsets.only(left: 7),
                                decoration: BoxDecoration(
                                  border: BoxBorder.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  // color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.transparent,
                                      child: Icon(
                                        CupertinoIcons
                                            .list_bullet_below_rectangle,
                                        color: Colors.green,
                                      ),
                                    ),
                                    SizedBox(height: 10.h(context)),
                                    Text(
                                      "$totalOrders",
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
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                // width: 160.w(context),
                                // height: 190.h(context),
                                // margin: EdgeInsets.only(left: 7),
                                decoration: BoxDecoration(
                                  border: BoxBorder.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  // color: Colors.grey.shade200,
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
                                      "$unpaidTotal",
                                      style: theme.titleLarge!.copyWith(
                                        fontSize: 40.sp(context),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 10.h(context)),
                                    Text(
                                      l10n.unpaid,
                                      style: theme.bodySmall!.copyWith(
                                        fontSize: 16.sp(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30.h(context),),
                        InkWell(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  border: BoxBorder.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      l10n.checkAllData,
                                      style: theme.titleMedium!.copyWith(
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                    CircleAvatar(
                                      backgroundColor: Colors.transparent,
                                      child: Icon(
                                        Icons.analytics_outlined,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DashboardScreen(userId: userId),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (state is OrdersLoading) {
                return Center(child: CircularProgressIndicator(color: Colors.green,));
              }else if (state is OrdersInitial) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            // padding: const EdgeInsets.all(8.0),
                            width: 160.w(context),
                            height: 190.h(context),
                            // margin: EdgeInsets.only(left: 7),
                            decoration: BoxDecoration(
                              border: BoxBorder.all(
                                color: Colors.grey.shade300,
                              ),
                              // color: Colors.grey.shade200,
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
                                  l10n.notAvailable,
                                  style: theme.titleMedium!,
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
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            // padding: const EdgeInsets.all(8.0),
                            width: 160.w(context),
                            height: 190.h(context),
                            // margin: EdgeInsets.only(left: 7),
                            decoration: BoxDecoration(
                              border: BoxBorder.all(
                                color: Colors.grey.shade300,
                              ),
                              // color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  child: Icon(
                                    CupertinoIcons.money_dollar,
                                    color: Colors.red,
                                  ),
                                ),
                                SizedBox(height: 10.h(context)),
                                Text(
                                  l10n.notAvailable,
                                  style: theme.titleMedium,
                                ),
                                SizedBox(height: 10.h(context)),
                                Text(
                                  l10n.unpaid,
                                  style: theme.bodySmall!.copyWith(
                                    fontSize: 16.sp(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }  return SizedBox.shrink();
            },),
            SizedBox(height: 100.h(context)),
            Align(
              alignment: Alignment.center,
              child: CustomButton(
                title: l10n.addOrder,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddOrderScreen()),
                  );
                },
                height: 90.h(context),
                width: 300.w(context),
              ),
            ),
            SizedBox(height: 30.h(context)),
            CustomButton(
              title: l10n.addClient,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddClientsScreen()),
                );
              },
              height: 90.h(context),
              width: 300.w(context),
              isInvert: false,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
