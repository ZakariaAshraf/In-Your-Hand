import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_your_hand/features/settings/presentation/screens/setting_screen.dart';
import '../Cubit/user_cubit.dart';
import '../../../../core/session/session_cubit.dart';
import '../../../../core/session/session_context.dart';
class SettingView extends StatelessWidget {
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionState = context.watch<SessionCubit>().state;
    final sessionContext =
        sessionState is SessionLoaded ? sessionState.context : null;
    final isGuest = sessionContext is GuestSession;
    return Scaffold(
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserLoaded) {
            return SettingScreen(
              profile: state.profile,
              isGuest: isGuest,
            );
            // return Scaffold(
            //   appBar: AppBar(),
            //   body: Column(
            //     children: [
            //       ListTile(
            //         title: Text(state.user.name),
            //         trailing: Text(state.user.nationality),
            //         subtitle: Text(state.user.phone),
            //       )
            //     ],
            //   ),
            // );
          } else if (state is UserError) {
            return Center(child: Text(state.message));
          } else {
            return Container();
          }
        },
      ),
    );
  }
}