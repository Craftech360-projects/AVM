import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'wizard_event.dart';
part 'wizard_state.dart';

class WizardBloc extends Bloc<WizardEvent, WizardState> {
  WizardBloc() : super(WizardInitial()) {
    on<WizardEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
