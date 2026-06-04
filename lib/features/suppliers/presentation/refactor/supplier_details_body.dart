import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/asset_paths.dart';
import '../cubit/supplier_details_cubit.dart';
import '../cubit/supplier_details_state.dart';
import '../widgets/supplier_info_card.dart';
import '../widgets/last_7_days_tab.dart';
import '../widgets/monthly_stats_tab.dart';

class SupplierDetailsBody extends StatefulWidget {
  final String supplierId;
  const SupplierDetailsBody({super.key, required this.supplierId});

  @override
  State<SupplierDetailsBody> createState() => _SupplierDetailsBodyState();
}

class _SupplierDetailsBodyState extends State<SupplierDetailsBody> with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SupplierDetailsCubit, SupplierDetailsState>(
      builder: (context, state) {
        final supplier = state.supplier;
        if (supplier == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Column(
              children: [
                _buildHeader(context, null),
                Expanded(child: Center(child: state.loading ? const CircularProgressIndicator() : Text('supplier_not_found'.tr(), style: const TextStyle(color: AppColors.textSecondary)))),
              ],
            ),
          );
        }
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              _buildHeader(context, supplier.name),
              SupplierInfoCard(supplier: supplier, todayEntry: state.todayEntry),
              Container(
                color: Colors.white,
                child: TabBar(controller: _tab, indicatorColor: AppColors.primary, labelColor: AppColors.primary, unselectedLabelColor: AppColors.textSecondary, labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), tabs: [Tab(text: 'last_7_days'.tr()), Tab(text: 'monthly_stats'.tr())]),
              ),
              Expanded(
                child: TabBarView(controller: _tab, children: [
                  Last7DaysTab(supplier: supplier, entries: state.entries),
                  MonthlyStatsTab(supplier: supplier, entries: state.entries, selectedMonth: state.selectedMonth, onMonthChanged: (m) => context.read<SupplierDetailsCubit>().changeMonth(widget.supplierId, m)),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, String? name) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Row(
            children: [
              GestureDetector(onTap: () => Navigator.pop(context), child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.divider.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.arrow_back, size: 20))),
              const SizedBox(width: 12),
              if (name != null) Expanded(child: Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
              if (name != null)
                GestureDetector(
                  onTap: () => context.push('/suppliers/edit/${widget.supplierId}'),
                  child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Image.asset(AssetPaths.iconPencil, width: 18, height: 18)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
