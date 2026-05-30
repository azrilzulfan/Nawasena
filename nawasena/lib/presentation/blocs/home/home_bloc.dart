import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/inventory_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/inventory_repository.dart';

abstract class HomeEvent extends Equatable {
  @override List<Object?> get props => [];
}
class HomeFetchRequested extends HomeEvent {}

abstract class HomeState extends Equatable {
  @override List<Object?> get props => [];
}
class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}
class HomeLoaded extends HomeState {
  final UserModel user;
  final List<InventoryModel> urgentItems;
  HomeLoaded({required this.user, required this.urgentItems});
  @override List<Object?> get props => [user, urgentItems];
}
class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AuthRepository _authRepo;
  final InventoryRepository _invRepo;

  HomeBloc(this._authRepo, this._invRepo) : super(HomeInitial()) {
    on<HomeFetchRequested>(_onFetch);
  }

  Future<void> _onFetch(HomeFetchRequested event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final results = await Future.wait([
        _authRepo.getMe(),
        _invRepo.getUrgentInventories(),
      ]);
      emit(HomeLoaded(
        user: results[0] as UserModel,
        urgentItems: results[1] as List<InventoryModel>,
      ));
    } catch (e) {
      emit(HomeError('Gagal memuat data. Periksa koneksi Anda.'));
    }
  }
}