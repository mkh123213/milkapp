import 'package:cloud_firestore/cloud_firestore.dart';

class Supplier {
  final String id;
  final String name;
  final String? phone;
  final String? village;
  final String? address;
  final int routeOrder;
  final bool isActive;
  final String? notes;
  final DateTime addedAt;
  final DateTime? deactivatedAt;

  const Supplier({
    required this.id,
    required this.name,
    this.phone,
    this.village,
    this.address,
    required this.routeOrder,
    this.isActive = true,
    this.notes,
    required this.addedAt,
    this.deactivatedAt,
  });

  factory Supplier.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Supplier(
      id: doc.id,
      name: d['name'] as String,
      phone: d['phone'] as String?,
      village: d['village'] as String?,
      address: d['address'] as String?,
      routeOrder: (d['routeOrder'] as num?)?.toInt() ?? 999,
      isActive: d['isActive'] as bool? ?? true,
      notes: d['notes'] as String?,
      addedAt: (d['addedAt'] as Timestamp?)?.toDate() ?? DateTime(2024, 1, 1),
      deactivatedAt: (d['deactivatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'phone': phone,
        'village': village,
        'address': address,
        'routeOrder': routeOrder,
        'isActive': isActive,
        'notes': notes,
        'addedAt': Timestamp.fromDate(addedAt),
        'deactivatedAt':
            deactivatedAt != null ? Timestamp.fromDate(deactivatedAt!) : null,
      };

  Supplier copyWith({
    String? name,
    String? phone,
    String? village,
    String? address,
    int? routeOrder,
    bool? isActive,
    String? notes,
    DateTime? deactivatedAt,
    bool clearDeactivatedAt = false,
  }) =>
      Supplier(
        id: id,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        village: village ?? this.village,
        address: address ?? this.address,
        routeOrder: routeOrder ?? this.routeOrder,
        isActive: isActive ?? this.isActive,
        notes: notes ?? this.notes,
        addedAt: addedAt,
        deactivatedAt:
            clearDeactivatedAt ? null : (deactivatedAt ?? this.deactivatedAt),
      );
}
