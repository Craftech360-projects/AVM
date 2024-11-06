part of 'wizard_bloc.dart';

abstract class WizardState extends Equatable {
  const WizardState();  

  @override
  List<Object> get props => [];
}
class WizardInitial extends WizardState {}
