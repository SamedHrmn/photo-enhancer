import 'package:equatable/equatable.dart';

abstract class BaseDataHolder extends Equatable {
  const BaseDataHolder();

  BaseDataHolder copyWith();
}
