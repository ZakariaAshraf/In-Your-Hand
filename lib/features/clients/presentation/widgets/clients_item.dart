import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_your_hand/core/utils/app_colors.dart';
import 'package:in_your_hand/core/utils/screen_util.dart';
import 'package:in_your_hand/features/clients/data/clients_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/app_localizations.dart';
import '../screens/edit_client_screen.dart';

class ClientsItem extends StatelessWidget {
  final ClientModel client;

  const ClientsItem({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: ClipRect(
        child: client.phone != ""
            ? ExpansionTile(
          shape: BoxBorder.all(color: Colors.transparent),
                childrenPadding: EdgeInsets.all(12),
                title: Text(client.name, style: theme.titleMedium),
                subtitle: client.notes != ""
                    ? Text(
                        client.notes ?? "",
                        style: theme.titleMedium!.copyWith(
                          color: Colors.grey,
                        ),
                      )
                    : null,
                trailing: Icon(
                  Icons.arrow_drop_down_circle_outlined,
                  color: AppColors.secondary,
                ),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ?client.phone != ""
                          ? Row(
                              children: [
                                InkWell(
                                  onTap: () {},
                                  child: Container(
                                    height: 50.h(context),
                                    width: 60.w(context),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(
                                        30.r(context),
                                      ),
                                      border: BoxBorder.all(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    child: Icon(
                                      CupertinoIcons.phone,
                                      size: 30.r(context),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 40.w(context)),
                                InkWell(
                                  child: Container(
                                    height: 50.h(context),
                                    width: 60.w(context),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(
                                        30.r(context),
                                      ),
                                      border: BoxBorder.all(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    child: Image.asset(
                                      "assets/icons/ic_whatsapp.png",
                                      height: 30,
                                      width: 30,
                                    ),
                                  ),
                                  onTap: () async {
                                    final phone = client.phone
                                        ?.replaceAll('+', '')
                                        .replaceAll(':', '')
                                        .trim();
                                    final encoded = Uri.encodeComponent(
                                      l10n.whatsappDefaultMessage,
                                    );
                                    final url = Uri.parse(
                                      "https://wa.me/$phone?text=$encoded",
                                    );

                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(
                                        url,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }
                                  },
                                ),
                              ],
                            )
                          : null,
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditClientScreen(client: client),
                            ),
                          );
                        },
                        child: Container(
                          height: 50.h(context),
                          width: 60.w(context),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              30.r(context),
                            ),
                            border: BoxBorder.all(color: Colors.grey),
                          ),
                          child: Center(child: Text(l10n.edit, style: theme.titleSmall)),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : ClipRect(
              child: ListTile(
                subtitle: client.notes != ""
                    ? Text(
                  client.notes ?? "",
                  style: theme.titleMedium!.copyWith(
                    color: Colors.grey,
                  ),
                )
                    : null,
                title: Text(client.name, style: theme.titleMedium),
                trailing: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditClientScreen(client: client),
                      ),
                    );
                  },
                  child: Container(
                    height: 50.h(context),
                    width: 60.w(context),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        30.r(context),
                      ),
                      border: BoxBorder.all(color: Colors.grey),
                    ),
                    child: Center(child: Text(l10n.edit, style: theme.titleSmall)),
                  ),
                ),
              ),
            ),
      ),
    );
  }
}
