enum PendingSyncAction { create, update, delete }

extension PendingSyncActionApi on PendingSyncAction {
  String get apiValue {
    return switch (this) {
      PendingSyncAction.create => 'Create',
      PendingSyncAction.update => 'Update',
      PendingSyncAction.delete => 'Delete',
    };
  }
}

PendingSyncAction pendingSyncActionFromApi(Object? value) {
  return switch (value) {
    'Create' => PendingSyncAction.create,
    'Update' => PendingSyncAction.update,
    'Delete' => PendingSyncAction.delete,
    _ => PendingSyncAction.create,
  };
}

final class PendingSyncOperation {
  const PendingSyncOperation({
    required this.localId,
    required this.entityName,
    required this.entityId,
    required this.clientId,
    required this.action,
    required this.payload,
  });

  final int localId;
  final String entityName;
  final String? entityId;
  final String clientId;
  final PendingSyncAction action;
  final Map<String, Object?> payload;
}
