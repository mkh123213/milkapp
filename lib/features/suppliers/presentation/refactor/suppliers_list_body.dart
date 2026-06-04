import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/asset_paths.dart';
import '../cubit/suppliers_list_cubit.dart';
import '../cubit/suppliers_list_state.dart';
import '../widgets/supplier_card.dart';
import '../widgets/filter_chip_widget.dart';

class SuppliersListBody extends StatelessWidget {
  const SuppliersListBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(),
          Expanded(
            child: BlocBuilder<SuppliersListCubit, SuppliersListState>(
              builder: (context, state) {
                if (state.loading) return const Center(child: CircularProgressIndicator());
                final filtered = state.filteredSuppliers;
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(AssetPaths.iconUser, width: 48, height: 48, opacity: const AlwaysStoppedAnimation(0.3)),
                        const SizedBox(height: 12),
                        Text(
                          state.search.isNotEmpty ? 'no_suppliers_search'.tr() : 'no_suppliers_yet'.tr(),
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: filtered.length,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                  itemBuilder: (_, i) {
                    final s = filtered[i];
                    final weekTotal = context.read<SuppliersListCubit>().weekTotalForSupplier(s.id);
                    return SupplierCard(supplier: s, weekTotal: weekTotal);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/suppliers/add'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: BlocBuilder<SuppliersListCubit, SuppliersListState>(
            builder: (context, state) {
              final cubit = context.read<SuppliersListCubit>();
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('suppliers_title'.tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      OutlinedButton.icon(
                        onPressed: () => context.push('/suppliers/route-order'),
                        icon: const Icon(Icons.sort, size: 16),
                        label: Text('route_order'.tr(), style: const TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), side: const BorderSide(color: AppColors.primary), foregroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'search_supplier_hint'.tr(),
                      prefixIcon: Padding(padding: const EdgeInsets.all(12), child: Image.asset(AssetPaths.iconSearch, width: 16, height: 16, opacity: const AlwaysStoppedAnimation(0.4))),
                      suffixIcon: state.search.isNotEmpty ? IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => cubit.setSearch('')) : null,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
                    ),
                    onChanged: cubit.setSearch,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      FilterChipWidget(label: 'all'.tr(), isActive: state.filterMode == 'all', onTap: () => cubit.setFilterMode('all')),
                      const SizedBox(width: 6),
                      FilterChipWidget(label: 'filter_active'.tr(), isActive: state.filterMode == 'active', onTap: () => cubit.setFilterMode('active')),
                      const SizedBox(width: 6),
                      FilterChipWidget(label: 'filter_inactive'.tr(), isActive: state.filterMode == 'inactive', onTap: () => cubit.setFilterMode('inactive')),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
