import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/services/connectivity_service.dart';
import 'core/cubits/connectivity/connectivity_cubit.dart';

import 'features/auth/data/data_source/auth_remote_data_source.dart';
import 'features/auth/data/repos/auth_repo.dart';
import 'features/auth/presentation/cubit/login_cubit.dart';
import 'features/auth/presentation/cubit/signup_cubit.dart';
import 'features/auth/presentation/cubit/forgot_password_cubit.dart';

import 'features/suppliers/data/data_source/suppliers_remote_data_source.dart';
import 'features/suppliers/data/repos/suppliers_repo.dart';
import 'features/suppliers/presentation/cubit/suppliers_list_cubit.dart';
import 'features/suppliers/presentation/cubit/supplier_details_cubit.dart';
import 'features/suppliers/presentation/cubit/add_edit_supplier_cubit.dart';
import 'features/suppliers/presentation/cubit/route_ordering_cubit.dart';

import 'features/today/data/data_source/today_remote_data_source.dart';
import 'features/today/data/repos/today_repo.dart';
import 'features/today/presentation/cubit/today_cubit.dart';
import 'features/today/presentation/cubit/weight_entry_cubit.dart';
import 'features/today/presentation/cubit/edit_weight_cubit.dart';

import 'features/reports/data/data_source/reports_remote_data_source.dart';
import 'features/reports/data/repos/reports_repo.dart';
import 'features/reports/presentation/cubit/reports_list_cubit.dart';
import 'features/reports/presentation/cubit/report_details_cubit.dart';

import 'features/dashboard/presentation/cubit/dashboard_cubit.dart';

import 'features/settings/data/data_source/settings_data_source.dart';
import 'features/settings/data/repos/settings_repo.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';

import 'router/app_router.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  _registerExternal(await SharedPreferences.getInstance());
  _registerServices();
  _registerAuth();
  _registerSuppliers();
  _registerToday();
  _registerReports();
  _registerDashboard();
  _registerSettings();
  _registerRouter();
}

void _registerExternal(SharedPreferences prefs) {
  getIt.registerSingleton<SharedPreferences>(prefs);
  getIt.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  getIt.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
}

void _registerServices() {
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  getIt.registerLazySingleton<ConnectivityCubit>(
      () => ConnectivityCubit(getIt<ConnectivityService>()));
}

void _registerAuth() {
  getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(getIt<FirebaseAuth>()));
  getIt.registerLazySingleton<AuthRepo>(
      () => AuthRepo(getIt<AuthRemoteDataSource>()));
  getIt.registerFactory<LoginCubit>(
      () => LoginCubit(getIt<AuthRepo>()));
  getIt.registerFactory<SignupCubit>(
      () => SignupCubit(getIt<AuthRepo>()));
  getIt.registerFactory<ForgotPasswordCubit>(
      () => ForgotPasswordCubit(getIt<AuthRepo>()));
}

void _registerSuppliers() {
  getIt.registerLazySingleton<SuppliersRemoteDataSource>(
      () => SuppliersRemoteDataSource(getIt<FirebaseFirestore>()));
  getIt.registerLazySingleton<SuppliersRepo>(
      () => SuppliersRepo(getIt<SuppliersRemoteDataSource>()));
  getIt.registerFactory<SuppliersListCubit>(
      () => SuppliersListCubit(getIt<SuppliersRepo>(), getIt<TodayRepo>(), getIt<AuthRepo>()));
  getIt.registerFactory<SupplierDetailsCubit>(
      () => SupplierDetailsCubit(getIt<SuppliersRepo>(), getIt<TodayRepo>(), getIt<AuthRepo>()));
  getIt.registerFactory<AddEditSupplierCubit>(
      () => AddEditSupplierCubit(getIt<SuppliersRepo>(), getIt<AuthRepo>()));
  getIt.registerFactory<RouteOrderingCubit>(
      () => RouteOrderingCubit(getIt<SuppliersRepo>(), getIt<AuthRepo>()));
}

void _registerToday() {
  getIt.registerLazySingleton<TodayRemoteDataSource>(
      () => TodayRemoteDataSource(getIt<FirebaseFirestore>()));
  getIt.registerLazySingleton<TodayRepo>(
      () => TodayRepo(getIt<TodayRemoteDataSource>()));
  getIt.registerFactory<TodayCubit>(
      () => TodayCubit(getIt<TodayRepo>(), getIt<SuppliersRepo>(), getIt<ReportsRepo>(), getIt<AuthRepo>()));
  getIt.registerFactory<WeightEntryCubit>(
      () => WeightEntryCubit(getIt<TodayRepo>(), getIt<AuthRepo>(), getIt<ReportsRepo>(), getIt<SuppliersRepo>()));
  getIt.registerFactory<EditWeightCubit>(
      () => EditWeightCubit(getIt<TodayRepo>(), getIt<AuthRepo>(), getIt<ReportsRepo>(), getIt<SuppliersRepo>()));
}

void _registerReports() {
  getIt.registerLazySingleton<ReportsRemoteDataSource>(
      () => ReportsRemoteDataSource(getIt<FirebaseFirestore>()));
  getIt.registerLazySingleton<ReportsRepo>(
      () => ReportsRepo(getIt<ReportsRemoteDataSource>()));
  getIt.registerFactory<ReportsListCubit>(
      () => ReportsListCubit(getIt<ReportsRepo>(), getIt<SuppliersRepo>(), getIt<AuthRepo>()));
  getIt.registerFactory<ReportDetailsCubit>(
      () => ReportDetailsCubit(getIt<ReportsRepo>(), getIt<TodayRepo>(), getIt<SuppliersRepo>(), getIt<AuthRepo>()));
}

void _registerDashboard() {
  getIt.registerFactory<DashboardCubit>(
      () => DashboardCubit(getIt<SuppliersRepo>(), getIt<TodayRepo>(), getIt<AuthRepo>()));
}

void _registerSettings() {
  getIt.registerLazySingleton<SettingsDataSource>(
      () => SettingsDataSource(getIt<SharedPreferences>()));
  getIt.registerLazySingleton<SettingsRepo>(
      () => SettingsRepo(getIt<SettingsDataSource>()));
  getIt.registerFactory<SettingsCubit>(
      () => SettingsCubit(getIt<AuthRepo>()));
}

void _registerRouter() {
  getIt.registerLazySingleton<GoRouter>(
      () => createAppRouter(getIt<AuthRepo>(), getIt<SettingsRepo>()));
}
