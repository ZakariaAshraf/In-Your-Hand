import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Core SQLite access for offline-first CRM data.
///
/// Primary keys are TEXT because we generate UUID strings locally, and later
/// map them to Firestore string IDs during sync.
class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _dbName = 'in_your_hand_local.db';
  static const int _dbVersion = 2;

  static const String clientsTable = 'clients';
  static const String ordersTable = 'orders';
  static const String paymentsTable = 'payments';

  Database? _db;

  Future<Database> get database async {
    final existing = _db;
    if (existing != null) return existing;

    final dbPath = await getDatabasesPath();
    final fullPath = p.join(dbPath, _dbName);
    final db = await openDatabase(
      fullPath,
      version: _dbVersion,
      onConfigure: (db) async {
        // Enforce FK constraints when present.
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    _db = db;
    return db;
  }

  Future<void> resetDatabase() async {
    final existing = _db;
    _db = null;
    await existing?.close();
  }

  Future<void> deleteDatabaseFile() async {
    await resetDatabase();
    final dbPath = await getDatabasesPath();
    final fullPath = p.join(dbPath, _dbName);
    await deleteDatabase(fullPath);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
CREATE TABLE $clientsTable (
  id TEXT PRIMARY KEY,
  workspace_id TEXT NOT NULL,
  name TEXT NOT NULL,
  phone TEXT,
  notes TEXT,
  is_deleted INTEGER NOT NULL DEFAULT 0,
  sync_status INTEGER NOT NULL DEFAULT 1,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  remote_id TEXT
);
''');
    await db.execute(
      'CREATE INDEX idx_clients_workspace ON $clientsTable(workspace_id);',
    );

    await db.execute('''
CREATE TABLE $ordersTable (
  id TEXT PRIMARY KEY,
  workspace_id TEXT NOT NULL,
  client_id TEXT NOT NULL,
  description TEXT NOT NULL,
  total_amount REAL NOT NULL,
  total_paid REAL NOT NULL,
  notes TEXT,
  is_deleted INTEGER NOT NULL DEFAULT 0,
  sync_status INTEGER NOT NULL DEFAULT 1,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  remote_id TEXT,
  FOREIGN KEY (client_id) REFERENCES $clientsTable(id) ON DELETE CASCADE
);
''');
    await db.execute(
      'CREATE INDEX idx_orders_workspace ON $ordersTable(workspace_id);',
    );
    await db.execute(
      'CREATE INDEX idx_orders_client ON $ordersTable(client_id);',
    );

    await db.execute('''
CREATE TABLE $paymentsTable (
  id TEXT PRIMARY KEY,
  workspace_id TEXT NOT NULL,
  order_id TEXT NOT NULL,
  amount REAL NOT NULL,
  is_deleted INTEGER NOT NULL DEFAULT 0,
  sync_status INTEGER NOT NULL DEFAULT 1,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  remote_id TEXT,
  FOREIGN KEY (order_id) REFERENCES $ordersTable(id) ON DELETE CASCADE
);
''');
    await db.execute(
      'CREATE INDEX idx_payments_workspace ON $paymentsTable(workspace_id);',
    );
    await db.execute(
      'CREATE INDEX idx_payments_order ON $paymentsTable(order_id);',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // clients
      await db.execute(
        'ALTER TABLE $clientsTable ADD COLUMN sync_status INTEGER NOT NULL DEFAULT 1',
      );

      // orders
      await db.execute(
        'ALTER TABLE $ordersTable ADD COLUMN is_deleted INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE $ordersTable ADD COLUMN sync_status INTEGER NOT NULL DEFAULT 1',
      );

      // payments
      await db.execute(
        'ALTER TABLE $paymentsTable ADD COLUMN is_deleted INTEGER NOT NULL DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE $paymentsTable ADD COLUMN sync_status INTEGER NOT NULL DEFAULT 1',
      );
      await db.execute(
        'ALTER TABLE $paymentsTable ADD COLUMN updated_at INTEGER NOT NULL DEFAULT 0',
      );
    }
  }
}

