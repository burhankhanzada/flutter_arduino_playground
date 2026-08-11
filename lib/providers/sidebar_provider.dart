import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SidebarTab { editor, palette, properties, debugConsole, serialOutput, spiceLogs }

class SidebarTabNotifier extends Notifier<SidebarTab> {
  @override
  SidebarTab build() => SidebarTab.editor;

  void setTab(SidebarTab tab) {
    state = tab;
  }
}

final sidebarTabProvider = NotifierProvider<SidebarTabNotifier, SidebarTab>(
  SidebarTabNotifier.new,
);
