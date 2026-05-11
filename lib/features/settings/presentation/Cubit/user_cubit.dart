import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:in_your_hand/core/database/database_helper.dart';
import 'package:in_your_hand/core/session/session_cubit.dart';
import 'package:in_your_hand/core/storage/business_logo_storage.dart';
import 'package:meta/meta.dart';

import '../../../business_profile/domain/entities/business_profile.dart';
import '../../../business_profile/domain/repositories/business_profile_repository.dart';

part 'user_state.dart';

/// Offline-first profile cubit.
///
/// Stores and loads a local [BusinessProfile] keyed by the active session
/// workspaceId (Guest UUID or Firebase uid).
class UserCubit extends Cubit<UserState> {
  UserCubit({
    required BusinessProfileRepository businessProfileRepository,
    required SessionCubit sessionCubit,
    DatabaseHelper? databaseHelper,
    Future<void> Function()? onLocalDatabaseCleared,
  })  : _businessProfileRepository = businessProfileRepository,
        _sessionCubit = sessionCubit,
        _databaseHelper = databaseHelper ?? DatabaseHelper.instance,
        _onLocalDatabaseCleared = onLocalDatabaseCleared,
        super(const UserLoading()) {
    _sessionSub = _sessionCubit.stream.listen((state) {
      if (state is SessionLoaded) {
        _workspaceId = state.context.workspaceId;
        loadProfile();
      }
    });
    final existing = _sessionCubit.contextOrNull;
    if (existing != null) {
      _workspaceId = existing.workspaceId;
      loadProfile();
    }
  }

  final BusinessProfileRepository _businessProfileRepository;
  final SessionCubit _sessionCubit;
  final DatabaseHelper _databaseHelper;
  final Future<void> Function()? _onLocalDatabaseCleared;
  StreamSubscription? _sessionSub;
  String? _workspaceId;

  @override
  Future<void> close() {
    _sessionSub?.cancel();
    return super.close();
  }

  Future<void> loadProfile() async {
    emit(const UserLoading());
    try {
      final wid = _workspaceId;
      if (wid == null) throw Exception('Session not ready');
      final existing = await _businessProfileRepository.getProfile(wid);
      final profile = existing ??
          BusinessProfile(
            workspaceId: wid,
            businessName: '',
            phone: null,
            address: null,
            logoLocalPath: null,
          );
      emit(UserLoaded(profile));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<BusinessProfile?> _currentOrStoredProfile(String wid) async {
    if (state is UserLoaded) return (state as UserLoaded).profile;
    return _businessProfileRepository.getProfile(wid);
  }

  Future<void> updateBusinessProfile({
    required String businessName,
    String? phone,
    String? address,
    String? logoLocalPath,
    bool mergeExistingLogo = true,
  }) async {
    emit(const UserLoading());
    try {
      final wid = _workspaceId;
      if (wid == null) throw Exception('Session not ready');
      final prev = await _currentOrStoredProfile(wid);
      final resolvedLogo = mergeExistingLogo
          ? (logoLocalPath ?? prev?.logoLocalPath)
          : logoLocalPath;

      String? p = phone?.trim();
      if (p != null && p.isEmpty) p = null;
      String? a = address?.trim();
      if (a != null && a.isEmpty) a = null;

      final profile = BusinessProfile(
        workspaceId: wid,
        businessName: businessName.trim(),
        phone: p,
        address: a,
        logoLocalPath: resolvedLogo,
      );
      await _businessProfileRepository.saveProfile(profile);
      emit(UserLoaded(profile));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  /// Picks from gallery, copies into app documents, updates profile. Local only.
  Future<void> pickAndSaveBusinessLogo() async {
    if (kIsWeb) return;
    final wid = _workspaceId;
    if (wid == null) {
      emit(const UserError('Session not ready'));
      return;
    }
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      final saved = await copyGalleryImageToAppDocuments(
        workspaceId: wid,
        sourcePath: picked.path,
      );
      if (saved == null) {
        emit(const UserError('Could not save logo file.'));
        return;
      }

      final prev = await _currentOrStoredProfile(wid);
      final oldPath = prev?.logoLocalPath;
      if (oldPath != null &&
          oldPath.isNotEmpty &&
          oldPath != saved) {
        await deleteBusinessLogoFile(oldPath);
      }

      final merged = BusinessProfile(
        workspaceId: wid,
        businessName: prev?.businessName ?? '',
        phone: prev?.phone,
        address: prev?.address,
        logoLocalPath: saved,
      );
      await _businessProfileRepository.saveProfile(merged);
      emit(UserLoaded(merged));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> deleteLocalData() async {
    emit(const UserLoading());
    try {
      final wid = _workspaceId;
      if (wid == null) throw Exception('Session not ready');
      await _businessProfileRepository.clearProfile(wid);
      await deleteAllLogosForWorkspace(wid);
      await _databaseHelper.deleteDatabaseFile();
      final hook = _onLocalDatabaseCleared;
      if (hook != null) await hook();
      await loadProfile();
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}
