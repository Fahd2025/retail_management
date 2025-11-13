import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../database/drift_database.dart';

class SyncService {
  final AppDatabase _db = AppDatabase();
  final Connectivity _connectivity = Connectivity();

  StreamSubscription? _connectivitySubscription;
  bool _isSyncing = false;

  void startListening(Function() onSyncComplete) {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none && !_isSyncing) {
        syncData(onSyncComplete);
      }
    });
  }

  void stopListening() {
    _connectivitySubscription?.cancel();
  }

  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<void> syncData(Function() onComplete) async {
    if (_isSyncing) return;

    _isSyncing = true;
    try {
      final connected = await isConnected();
      if (!connected) {
        _isSyncing = false;
        return;
      }

      // Get all items that need syncing
      final productsToSync = await _db.getProductsNeedingSync();
      final customersToSync = await _db.getCustomersNeedingSync();
      final salesToSync = await _db.getSalesNeedingSync();

      // In a real implementation, you would send these to your server
      // For now, we'll just mark them as synced
      for (var product in productsToSync) {
        await _db.updateProduct(product.copyWith(needsSync: false));
      }

      for (var customer in customersToSync) {
        await _db.updateCustomer(customer.copyWith(needsSync: false));
      }

      for (var sale in salesToSync) {
        await _db.updateSale(sale.copyWith(needsSync: false));
      }

      onComplete();
    } catch (e) {
      print('Sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  // Method to manually trigger sync
  Future<SyncResult> manualSync() async {
    final connected = await isConnected();
    if (!connected) {
      return SyncResult(
        success: false,
        messageType: SyncMessageType.noInternet,
      );
    }

    try {
      final productsToSync = await _db.getProductsNeedingSync();
      final customersToSync = await _db.getCustomersNeedingSync();
      final salesToSync = await _db.getSalesNeedingSync();

      final totalItems =
          productsToSync.length + customersToSync.length + salesToSync.length;

      if (totalItems == 0) {
        return SyncResult(
          success: true,
          messageType: SyncMessageType.alreadySynced,
          itemsSynced: 0,
        );
      }

      // Sync products
      for (var product in productsToSync) {
        await _db.updateProduct(product.copyWith(needsSync: false));
      }

      // Sync customers
      for (var customer in customersToSync) {
        await _db.updateCustomer(customer.copyWith(needsSync: false));
      }

      // Sync sales
      for (var sale in salesToSync) {
        await _db.updateSale(sale.copyWith(needsSync: false));
      }

      return SyncResult(
        success: true,
        messageType: SyncMessageType.success,
        itemsSynced: totalItems,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        messageType: SyncMessageType.failed,
        errorMessage: e.toString(),
      );
    }
  }
}

enum SyncMessageType {
  noInternet,
  alreadySynced,
  success,
  failed,
}

class SyncResult {
  final bool success;
  final SyncMessageType messageType;
  final int itemsSynced;
  final String? errorMessage;

  SyncResult({
    required this.success,
    required this.messageType,
    this.itemsSynced = 0,
    this.errorMessage,
  });
}
