part of 'wizard_bloc.dart';

abstract class WizardEvent extends Equatable {
  const WizardEvent();

  @override
  List<Object> get props => [];
}

class CheckPermissionsEvent extends WizardEvent {}

class NavigateToNextPageEvent extends WizardEvent {}

class PermissionsCheckedEvent extends WizardEvent {
  final bool allPermissionsGranted;

  const PermissionsCheckedEvent(this.allPermissionsGranted);

  @override
  List<Object> get props => [allPermissionsGranted];
}
