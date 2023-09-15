import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/domain/constants.dart';
import 'package:hiddify/domain/failures.dart';
import 'package:hiddify/features/common/common.dart';
import 'package:hiddify/features/common/new_version_dialog.dart';
import 'package:hiddify/gen/assets.gen.dart';
import 'package:hiddify/services/service_providers.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AboutPage extends HookConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final appInfo = ref.watch(appInfoProvider);
    final appUpdate = ref.watch(appUpdateNotifierProvider);

    ref.listen(
      appUpdateNotifierProvider,
      (_, next) async {
        switch (next) {
          case AsyncData(value: final remoteVersion?):
            await NewVersionDialog(
              appInfo.version,
              remoteVersion,
              canIgnore: false,
            ).show(context);
          case AsyncError(:final error):
            if (!context.mounted) return;
            CustomToast.error(t.printError(error)).show(context);
        }
      },
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(t.about.pageTitle),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Assets.images.logo.svg(width: 64, height: 64),
                  const Gap(16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.general.appTitle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Gap(4),
                      Text(
                        "${t.about.version} ${appInfo.version}",
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                ListTile(
                  title: Text(t.about.sourceCode),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () async {
                    await UriUtils.tryLaunch(
                      Uri.parse(Constants.githubUrl),
                    );
                  },
                ),
                ListTile(
                  title: Text(t.about.telegramChannel),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () async {
                    await UriUtils.tryLaunch(
                      Uri.parse(Constants.telegramChannelUrl),
                    );
                  },
                ),
                if (appInfo.release.allowCustomUpdateChecker)
                  ListTile(
                    title: Text(t.about.checkForUpdate),
                    trailing: appUpdate.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(),
                          )
                        : const Icon(Icons.update),
                    onTap: () {
                      ref.invalidate(appUpdateNotifierProvider);
                    },
                  ),
                ListTile(
                  title: Text(t.settings.general.openWorkingDir),
                  trailing: const Icon(Icons.arrow_outward_outlined),
                  onTap: () async {
                    final path =
                        ref.read(filesEditorServiceProvider).workingDir.uri;
                    await UriUtils.tryLaunch(path);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
