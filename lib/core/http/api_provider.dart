import 'dart:convert';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:bakeet/core/constant/end_points/api_url.dart';
import 'dio_error_handle.dart';
import 'http_method.dart';

class ApiProvider {
  static var options = BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
  );
  static final Dio dio = Dio(options);

  static Future<Either<String, T>> sendObjectRequest<T>({
    required HttpMethod method,
    required String url,
    Map<String, dynamic>? data,
    Function(Map<String, dynamic>)? converter,
    Function(dynamic)? converter2,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    File? file,
    File? secondFile,
    List<File>? imageFiles,
    List<File>? videoFiles,
    String? fileVideoKey,
    String? fileKey,
    String? secondFileKey,
    String? contentType,
    required String strString,
  }) async {
    final Map<String, dynamic> dataMap = {};
    Response? response;
    try {
      if (data != null) {
        dataMap.addAll(data);
      }
      if (file != null) {
        if (fileKey != null && fileKey != '') {
          String fileName = file.path.split("/").last;
          debugPrint('fileNamexxxx in file');
          debugPrint(fileName);
          late MultipartFile multipartFile;
          multipartFile = await MultipartFile.fromFile(
            file.path,
            filename: fileName,
          );
          dataMap.addAll({fileKey: multipartFile});
        }
      }
      if (secondFile != null) {
        if (secondFileKey != null && secondFileKey != '') {
          String fileName = secondFile.path.split("/").last;
          debugPrint('fileNamexxxx in secondFile');
          debugPrint(fileName);
          late MultipartFile multipartFile;
          multipartFile = await MultipartFile.fromFile(
            secondFile.path,
            filename: fileName,
          );
          dataMap.addAll({secondFileKey: multipartFile});
        }
      }
      if (imageFiles != null && imageFiles.isNotEmpty) {
        List<MultipartFile> multipartFiles = [];
        int i = 0;
        for (var element in imageFiles) {
          String fileName = element.path.split("/").last;
          debugPrint('fileNamexxxx in imageFiles');
          debugPrint(fileName);
          multipartFiles.add(
            await MultipartFile.fromFile(element.path, filename: fileName),
          );
          debugPrint(multipartFiles[i].filename);
        }
        dataMap.addAll({fileKey!: multipartFiles});
      }
      if (videoFiles != null && videoFiles.isNotEmpty) {
        debugPrint('fileNamexxxx in videoooos');
        List<MultipartFile> multipartFiles = [];
        for (var element in videoFiles) {
          String fileName = element.path.split("/").last;
          debugPrint('fileNamexxxxvideoooos');
          debugPrint(videoFiles.first.path);
          multipartFiles.add(
            await MultipartFile.fromFile(element.path, filename: fileName),
          );
        }
        dataMap.addAll({fileVideoKey!: multipartFiles});
      }
      debugPrint('[$method: $url] data : [$data]');
      debugPrint('queryParameters : [$queryParameters]');

      dio.options.headers = headers;
      if (kDebugMode) {
        dio.interceptors.add(
          PrettyDioLogger(
            request: true,
            requestHeader: true,
            requestBody: true,
            responseBody: true,
            responseHeader: true,
            error: true,
            compact: true,
            maxWidth: 90,
          ),
        );
      }
      switch (method) {
        case HttpMethod.GET:
          response = await dio.get(url, queryParameters: queryParameters);
          break;
        case HttpMethod.POST:
          final hasFiles =
              file != null ||
              secondFile != null ||
              imageFiles != null && imageFiles.isNotEmpty ||
              videoFiles != null && videoFiles.isNotEmpty;

          final postData = hasFiles ? FormData.fromMap(dataMap) : dataMap;

          response = await dio.post(
            url,
            data: postData,
            queryParameters: queryParameters ?? {},
            options: Options(
              contentType: hasFiles ? 'multipart/form-data' : contentType,
            ),
            onSendProgress: (int sent, int total) {
              debugPrint(
                'progress: ${(sent / total * 100).toStringAsFixed(0)}% ($sent/$total)',
              );
            },
          );
          break;

        case HttpMethod.PUT:
          final hasFiles =
              file != null ||
              secondFile != null ||
              imageFiles != null && imageFiles.isNotEmpty ||
              videoFiles != null && videoFiles.isNotEmpty;

          final putData = hasFiles ? FormData.fromMap(dataMap) : dataMap;

          response = await dio.put(
            url,
            data: putData,
            queryParameters: queryParameters,
            options: Options(
              contentType: hasFiles
                  ? 'multipart/form-data'
                  : 'application/json',
            ),
          );
          break;

        case HttpMethod.DELETE:
          response = await dio.delete(
            url,
            data: data,
            queryParameters: queryParameters,
          );
          break;
      }
      dynamic decodedJson;

      if (response.data is String) {
        decodedJson = json.decode(response.data);
      } else {
        decodedJson = response.data;
      }

      if ((response.statusCode)! > 199 && (response.statusCode)! < 300) {
        if (decodedJson != null) {
          if (decodedJson != Map && converter2 != null) {
            return Right(converter2(response.data));
          } else {
            return Right(converter!(response.data));
          }
        } else {
          return Left(response.data['message']);
        }
      } else {
        return Left(response.data['message']);
      }
    } on DioException catch (e) {
      final errorData = e.response?.data;

      if (errorData is Map<String, dynamic>) {
        final validationErrors = errorData['error']?['validationErrors'];
        if (validationErrors != null &&
            validationErrors is List &&
            validationErrors.isNotEmpty) {
          final validationMessages = validationErrors
              .map((error) => error['message'] ?? 'Unknown error')
              .join('\n');
          return Left(validationMessages);
        }

        final errorMessage =
            errorData['error']?['message'] ?? 'An error occurred';
        return Left(errorMessage);
      }

      Map dioError = DioErrorsHandler.onError(e);
      return Left(dioError.toString());
    } on SocketException catch (e, stacktrace) {
      if (kDebugMode) {
        debugPrint('SocketException');
        print(e);
        print(stacktrace);
      }
      return const Left('please check your connection');
    }
  }

  static Future<Either<String, String>> sendObjectWithOutResponseRequest<T>({
    required HttpMethod method,
    required String url,
    Map<String, dynamic>? data,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    try {
      debugPrint('[$method: $url] data : $data');
      debugPrint('queryParameters : [$queryParameters]');
      dio.options.headers = headers;

      Response response;
      switch (method) {
        case HttpMethod.GET:
          response = await dio.get(url, queryParameters: queryParameters);
          break;
        case HttpMethod.POST:
          response = await dio.post(
            url,
            data: data,
            queryParameters: queryParameters ?? {},
          );
          break;
        case HttpMethod.PUT:
          response = await dio.put(
            url,
            data: data,
            queryParameters: queryParameters,
          );
          break;
        case HttpMethod.DELETE:
          response = await dio.delete(
            url,
            data: data,
            queryParameters: queryParameters,
          );
          break;
      }

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        if (response.data == null || response.data.toString().isEmpty) {
          return const Right('Request successful, but no response body');
        }

        dynamic decodedJson;
        if (response.data is String) {
          decodedJson = json.decode(response.data);
        } else {
          decodedJson = response.data;
        }

        return Right(decodedJson);
      } else {
        return Left(response.data?.toString() ?? 'Unexpected error');
      }
    } on DioException catch (e) {
      Map dioError = DioErrorsHandler.onError(e);
      debugPrint('DioException: $e');
      return Left(e.response?.data ?? dioError.toString());
    } on SocketException catch (e, stacktrace) {
      debugPrint('SocketException: $e\n$stacktrace');
      return const Left('Please check your connection');
    }
  }

  static void printWrapped(String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => debugPrint(match.group(0)));
  }
}
