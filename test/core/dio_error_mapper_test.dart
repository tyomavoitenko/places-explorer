import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:places_explorer/core/error/app_failure.dart';
import 'package:places_explorer/core/network/dio_error_mapper.dart';

void main() {
  final requestOptions = RequestOptions(path: '/v2/places');

  group('mapDioException', () {
    test('maps timeouts to NetworkFailure', () {
      final failure = mapDioException(
        DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.receiveTimeout,
        ),
      );

      expect(failure, isA<NetworkFailure>());
    });

    test('maps a socket error inside an unknown DioException to NetworkFailure',
        () {
      final failure = mapDioException(
        DioException(
          requestOptions: requestOptions,
          // type defaults to DioExceptionType.unknown
          error: const SocketException('no route to host'),
        ),
      );

      expect(failure, isA<NetworkFailure>());
    });

    test('maps a bad response to ServerFailure carrying the status code', () {
      final failure = mapDioException(
        DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.badResponse,
          response: Response<void>(
            requestOptions: requestOptions,
            statusCode: 429,
          ),
        ),
      );

      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 429);
    });

    test('maps a non-Dio error to UnexpectedFailure', () {
      expect(mapDioException(ArgumentError('boom')), isA<UnexpectedFailure>());
    });
  });
}
