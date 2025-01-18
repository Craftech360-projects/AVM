import 'package:capsaul/utils/permissions/permission_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'wizard_event.dart';
part 'wizard_state.dart';

class WizardBloc extends Bloc<WizardEvent, WizardState> {
  final BuildContext context;

  WizardBloc(this.context) : super(WizardInitial()) {
    on<CheckPermissionsEvent>((event, emit) async {
      emit(CheckingPermissions());

      bool notificationGranted =
          await PermissionsService.requestNotificationPermission(context);
      bool hasLocationPermission =
          await PermissionsService.requestLocationPermission(context);
      bool hasInternetConnection =
          await PermissionsService.checkInternetConnection(context);

      if (notificationGranted &&
          hasLocationPermission &&
          hasInternetConnection) {
        emit(PermissionsGranted());
      } else {
        emit(const PermissionsDenied("Some permissions are missing."));
      }
    });

    on<NavigateToNextPageEvent>((event, emit) {
      emit(NavigateToNextPageState());
    });
  }
}
