import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/asset_paths.dart';
import '../../../../core/utils/date_utils.dart';
import '../cubit/today_cubit.dart';
import '../cubit/today_state.dart';
import '../widgets/pending_card.dart';
import '../widgets/weight_entry_sheet.dart';
import '../widgets/no_milk_dialog.dart';

class TodayReceivingBody extends StatelessWidget {
  const TodayReceivingBody({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodayCubit, TodayState>(
      builder: (context, state) {
        if (state.loading)
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: Column(
              children: [
                _buildHeader(context, state),
                if (state.isWeekLocked) _buildLockedBanner(),
                _buildSearchRow(context, state),
                _buildTabs(state),
                Expanded(child: _buildTabContent(context, state)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, TodayState state) {
    final today = DateTime.now();
    return Container(
      color: AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Column(
            children: [
              Text(
                'today_receiving_title'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                MilkDateUtils.formatFullArabic(today),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _chip(
                    'received'.tr(),
                    MilkDateUtils.toArabicNumerals(state.receivedList.length),
                  ),
                  const SizedBox(width: 10),
                  _chip(
                    'total_kg'.tr(),
                    MilkDateUtils.toArabicNumeralsStr(
                      state.totalToday.toStringAsFixed(1),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, String value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      '$value $label',
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
    ),
  );

  Widget _buildLockedBanner() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    color: AppColors.editedBg,
    child: Row(
      children: [
        const Icon(Icons.lock, size: 16, color: AppColors.edited),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'week_locked_banner'.tr(),
            style: const TextStyle(color: AppColors.edited, fontSize: 12),
          ),
        ),
      ],
    ),
  );

  Widget _buildSearchRow(BuildContext context, TodayState state) {
    final cubit = context.read<TodayCubit>();
    final villages = state.suppliers
        .map((s) => s.village)
        .whereType<String>()
        .toSet()
        .toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'search_supplier_hint'.tr(),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    AssetPaths.iconSearch,
                    width: 16,
                    height: 16,
                    opacity: const AlwaysStoppedAnimation(0.4),
                  ),
                ),
                suffixIcon: state.search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => cubit.setSearch(''),
                      )
                    : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
              ),
              onChanged: cubit.setSearch,
            ),
          ),
          if (villages.isNotEmpty) ...[
            const SizedBox(width: 8),
            PopupMenuButton<String?>(
              icon: Icon(
                Icons.filter_list,
                color: state.villageFilter != null
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              onSelected: cubit.setVillageFilter,
              itemBuilder: (_) => [
                PopupMenuItem(value: null, child: Text('all_villages'.tr())),
                ...villages.map((v) => PopupMenuItem(value: v, child: Text(v))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabs(TodayState s) => TabBar(
    tabs: [
      Tab(
        text:
            '${'tab_pending'.tr()} (${MilkDateUtils.toArabicNumerals(s.pendingList.length)})',
      ),
      Tab(
        text:
            '${'tab_received'.tr()} (${MilkDateUtils.toArabicNumerals(s.receivedList.length)})',
      ),
      Tab(
        text:
            '${'tab_no_milk'.tr()} (${MilkDateUtils.toArabicNumerals(s.noMilkList.length)})',
      ),
    ],
  );

  Widget _buildTabContent(BuildContext ctx, TodayState state) {
    return TabBarView(
      children: [
        _list(ctx, state, state.pendingList, isPending: true),
        _list(ctx, state, state.receivedList),
        _list(ctx, state, state.noMilkList),
      ],
    );
  }

  Widget _list(
    BuildContext ctx,
    TodayState state,
    List list, {
    bool isPending = false,
  }) {
    if (list.isEmpty) {
      final hasFilter = state.search.isNotEmpty || state.villageFilter != null;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hasFilter ? 'no_results_found'.tr() : (isPending ? 'all_received'.tr() : 'no_received_today'.tr()),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            if (hasFilter) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  final cubit = ctx.read<TodayCubit>();
                  cubit.setSearch('');
                  cubit.setVillageFilter(null);
                },
                child: Text('clear_search'.tr()),
              ),
            ],
          ],
        ),
      );
    }
    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final supplier = list[i];
        final entry = state.entriesMap[supplier.id];
        return PendingCard(
          supplier: supplier,
          entry: entry,
          isLocked: state.isWeekLocked,
          onWeightEntry: isPending && !state.isWeekLocked
              ? () => showWeightEntrySheet(ctx, supplier)
              : null,
          onNoMilk: isPending && !state.isWeekLocked
              ? () => showNoMilkDialog(ctx, supplier)
              : null,
        );
      },
    );
  }
}
