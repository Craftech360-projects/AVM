import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:friend_private/src/core/utils/permissions/PermissionsService.dart';

part 'wizard_event.dart';
part 'wizard_state.dart';

class WizardBloc extends Bloc<WizardEvent, WizardState> {
  final BuildContext context; // Add context as a member variable

  WizardBloc(this.context) : super(WizardInitial()) {
    on<CheckPermissionsEvent>((event, emit) async {
      emit(CheckingPermissions());

      // Pass the context to the permission request methods
      bool notificationGranted =
          await PermissionsService.requestNotificationPermission(context);
      bool hasLocationPermission =
          await PermissionsService.requestLocationPermission(context);
      // bool hasBluetoothPermission =
      //     await PermissionsService.requestBluetoothPermission(context);
      bool hasInternetConnection =
          await PermissionsService.checkInternetConnection(context);

      if (notificationGranted &&
          hasLocationPermission &&
          // hasBluetoothPermission &&
          hasInternetConnection) {
        emit(PermissionsGranted());
      } else {
        emit(PermissionsDenied("Some permissions are missing."));
      }
    });

    on<NavigateToNextPageEvent>((event, emit) {
      emit(NavigateToNextPageState());
    });
  }
}
