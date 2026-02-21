import 'package:dio/dio.dart';
import 'package:e_trainer_chess/infra/base.api.dart';
import 'package:flutter/material.dart';

class IntraApi {
  final String _baseUrl;

  IntraApi(this._baseUrl);
  String get baseUrl => _baseUrl;

  @protected
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await BaseApi.get(
      joinUrl(_baseUrl, path),
      queryParameters: queryParameters,
    );
  }

  @protected
  Future<Response> post(String path, {Object? data}) async {
    return await BaseApi.post(
      joinUrl(_baseUrl, path),
      data: data,
    );
  }

  @protected
  Future<Response> put(String path, {Object? data}) async {
    return await BaseApi.put(
      joinUrl(_baseUrl, path),
      data: data,
    );
  }

  @protected
  Future<Response> patch(String path, {Object? data}) async {
    return await BaseApi.patch(
      joinUrl(_baseUrl, path),
      data: data,
    );
  }

  @protected
  Future<Response> delete(String path, {Object? data}) async {
    return await BaseApi.delete(
      joinUrl(_baseUrl, path),
      data: data,
    );
  }
    String joinUrl(String baseUrl, String path) {
    baseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    path = path.startsWith('/') ? path : '/$path';
    return '$baseUrl$path';
  }
}