import 'package:cloud_firestore/cloud_firestore.dart';

import 'business_profile_cloud_text.dart';
import 'business_profile_remote_data_source.dart';

class BusinessProfileRemoteDataSourceFirestore
    implements BusinessProfileRemoteDataSource {
  BusinessProfileRemoteDataSourceFirestore({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String businessNameField = 'businessName';
  static const String businessPhoneField = 'businessPhone';
  static const String businessAddressField = 'businessAddress';

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  @override
  Future<void> upsertBusinessText({
    required String uid,
    required String businessName,
    String? businessPhone,
    String? businessAddress,
  }) async {
    await _userDoc(uid).set(<String, dynamic>{
      businessNameField: businessName.trim(),
      businessPhoneField: businessPhone?.trim() ?? '',
      businessAddressField: businessAddress?.trim() ?? '',
    }, SetOptions(merge: true));
  }

  @override
  Future<BusinessProfileCloudText?> fetchBusinessText(String uid) async {
    final snap = await _userDoc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    final data = snap.data()!;
    final nameFromMerged = (data[businessNameField] as String?)?.trim() ?? '';
    final name = nameFromMerged.isNotEmpty
        ? nameFromMerged
        : ((data['name'] as String?)?.trim() ?? '');

    final phoneRaw = data[businessPhoneField] ?? data['phone'];
    final phone =
        phoneRaw is String ? (phoneRaw.trim().isEmpty ? null : phoneRaw.trim())
            : null;

    final addrRaw = data[businessAddressField];
    final address =
        addrRaw is String ? (addrRaw.trim().isEmpty ? null : addrRaw.trim())
            : null;

    return BusinessProfileCloudText(
      businessName: name,
      businessPhone: phone,
      businessAddress: address,
    );
  }
}
