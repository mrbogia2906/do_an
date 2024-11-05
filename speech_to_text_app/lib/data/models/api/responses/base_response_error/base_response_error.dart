import 'package:freezed_annotation/freezed_annotation.dart';

part 'base_response_error.freezed.dart';
part 'base_response_error.g.dart';

@freezed
class BaseResponseError with _$BaseResponseError {
  factory BaseResponseError({
    @JsonKey(name: 'message') String? message,
  }) = _BaseResponseError;

  const BaseResponseError._();

  factory BaseResponseError.fromJson(Map<String, dynamic> json) =>
      _$BaseResponseErrorFromJson(json);
}
