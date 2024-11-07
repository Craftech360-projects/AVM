part of 'wizard_bloc.dart';

abstract class WizardState extends Equatable {
  const WizardState();

  @override
  List<Object> get props => [];
}

class WizardInitial extends WizardState {}

class CheckingPermissions extends WizardState {}

class PermissionsGranted extends WizardState {}

class PermissionsDenied extends WizardState {
  final String message;

  const PermissionsDenied(this.message);

  @override
  List<Object> get props => [message];
}

class NavigateToNextPageState extends WizardState {}
