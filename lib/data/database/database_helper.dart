import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  // Bump version when schema changes
  static const int _dbVersion = 6;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('finanzas_v4.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      return await openDatabase(
        filePath,
        version: _dbVersion,
        onCreate: _createDB,
        onUpgrade: _onUpgrade,
      );
    } else {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);
      return await openDatabase(
        path,
        version: _dbVersion,
        onCreate: _createDB,
        onUpgrade: _onUpgrade,
      );
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // categories
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        tipo TEXT,
        color TEXT,
        is_default INTEGER
      );
    ''');

    // accounts / bancos
    await db.execute('''
      CREATE TABLE accounts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        tipo TEXT NOT NULL,
        saldo_actual REAL NOT NULL DEFAULT 0.0,
        color TEXT,
        icono TEXT,
        creado_en TEXT
      );
    ''');

    // movements
    await db.execute('''
      CREATE TABLE movements(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo TEXT,
        monto REAL,
        descripcion TEXT,
        categoria_id INTEGER,
        account_id INTEGER,
        metodo_pago TEXT,
        fecha TEXT,
        creado_en TEXT,
        FOREIGN KEY(categoria_id) REFERENCES categories(id),
        FOREIGN KEY(account_id) REFERENCES accounts(id)
      );
    ''');

    // loans
    await db.execute('''
      CREATE TABLE loans(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo TEXT,
        nombre_persona TEXT,
        monto REAL,
        remaining_amount REAL,
        interes REAL,
        due_date TEXT,
        status TEXT,
        notas TEXT,
        account_id INTEGER,
        creado_en TEXT,
        FOREIGN KEY(account_id) REFERENCES accounts(id)
      );
    ''');

    // loan_payments (historial de devoluciones/abonos)
    await db.execute('''
      CREATE TABLE loan_payments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        loan_id INTEGER NOT NULL,
        monto REAL NOT NULL,
        account_id INTEGER,
        fecha TEXT NOT NULL,
        notas TEXT,
        creado_en TEXT,
        FOREIGN KEY(loan_id) REFERENCES loans(id) ON DELETE CASCADE,
        FOREIGN KEY(account_id) REFERENCES accounts(id)
      );
    ''');

    // goals
    await db.execute('''
      CREATE TABLE goals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        target_amount REAL,
        current_amount REAL,
        fecha_limite TEXT,
        estado TEXT,
        creado_en TEXT
      );
    ''');

    // goal contributions
    await db.execute('''
      CREATE TABLE goal_contributions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        goal_id INTEGER,
        monto REAL,
        fecha TEXT,
        creado_en TEXT,
        FOREIGN KEY(goal_id) REFERENCES goals(id)
      );
    ''');

    // budgets
    await db.execute('''
      CREATE TABLE budgets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        categoria_id INTEGER NOT NULL,
        monto_limite REAL NOT NULL,
        periodo TEXT NOT NULL DEFAULT 'mensual',
        creado_en TEXT,
        FOREIGN KEY(categoria_id) REFERENCES categories(id)
      );
    ''');

    // recurring movements
    await db.execute('''
      CREATE TABLE recurring_movements(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo TEXT NOT NULL,
        monto REAL NOT NULL,
        descripcion TEXT,
        categoria_id INTEGER,
        account_id INTEGER,
        frecuencia TEXT NOT NULL,
        dia_ejecucion INTEGER,
        fecha_inicio TEXT NOT NULL,
        fecha_fin TEXT,
        activo INTEGER NOT NULL DEFAULT 1,
        ultima_ejecucion TEXT,
        creado_en TEXT,
        FOREIGN KEY(categoria_id) REFERENCES categories(id),
        FOREIGN KEY(account_id) REFERENCES accounts(id)
      );
    ''');

    // settings (single row)
    await db.execute('''
      CREATE TABLE settings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pin TEXT,
        moneda TEXT,
        cash_balance REAL,
        bank_balance REAL,
        setup_complete INTEGER
      );
    ''');

    // seed default settings row
    await db.insert('settings', {
      'pin': null,
      'moneda': 'Bs.',
      'cash_balance': 0.0,
      'bank_balance': 0.0,
      'setup_complete': 0,
    });

    // seed default accounts
    await db.insert('accounts', {
      'nombre': 'Efectivo',
      'tipo': 'efectivo',
      'saldo_actual': 0.0,
      'color': '#4CAF50',
      'icono': 'payments',
      'creado_en': DateTime.now().toIso8601String(),
    });
    await db.insert('accounts', {
      'nombre': 'Banco Principal',
      'tipo': 'banco',
      'saldo_actual': 0.0,
      'color': '#2196F3',
      'icono': 'account_balance',
      'creado_en': DateTime.now().toIso8601String(),
    });

    // seed default categories (8 predeterminadas)
    final defaultCategories = [
      {'nombre': 'Alimentación', 'tipo': 'gasto', 'color': '#F44336'},
      {'nombre': 'Transporte', 'tipo': 'gasto', 'color': '#9C27B0'},
      {'nombre': 'Vivienda', 'tipo': 'gasto', 'color': '#3F51B5'},
      {'nombre': 'Servicios', 'tipo': 'gasto', 'color': '#03A9F4'},
      {'nombre': 'Entretenimiento', 'tipo': 'gasto', 'color': '#009688'},
      {'nombre': 'Salud', 'tipo': 'gasto', 'color': '#8BC34A'},
      {'nombre': 'Salario', 'tipo': 'ingreso', 'color': '#4CAF50'},
      {'nombre': 'Otros', 'tipo': 'gasto', 'color': '#607D8B'},
    ];
    for (final c in defaultCategories) {
      await db.insert('categories', {
        'nombre': c['nombre'],
        'tipo': c['tipo'],
        'color': c['color'],
        'is_default': 1,
      });
    }
    final tablasConSincronizacion = [
      'categories', 'accounts', 'movements', 'loans', 'loan_payments',
      'goals', 'goal_contributions', 'budgets', 'recurring_movements'
    ];
    for (final tabla in tablasConSincronizacion) {
      try {
        await db.execute('ALTER TABLE $tabla ADD COLUMN updated_at TEXT;');
        await db.execute('ALTER TABLE $tabla ADD COLUMN is_deleted INTEGER NOT NULL DEFAULT 0;');
        await db.execute('ALTER TABLE $tabla ADD COLUMN synced_at TEXT;');
      } catch (e) {
        debugPrint('Columna ya existe en $tabla');
      }
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS accounts(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre TEXT NOT NULL,
          tipo TEXT NOT NULL,
          saldo_actual REAL NOT NULL DEFAULT 0.0,
          color TEXT,
          icono TEXT,
          creado_en TEXT
        );
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS loan_payments(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          loan_id INTEGER NOT NULL,
          monto REAL NOT NULL,
          account_id INTEGER,
          fecha TEXT NOT NULL,
          notas TEXT,
          creado_en TEXT,
          FOREIGN KEY(loan_id) REFERENCES loans(id) ON DELETE CASCADE,
          FOREIGN KEY(account_id) REFERENCES accounts(id)
        );
      ''');

      // Add missing columns if upgrading existing db
      try {
        await db.execute('ALTER TABLE movements ADD COLUMN account_id INTEGER;');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE loans ADD COLUMN account_id INTEGER;');
      } catch (_) {}

      // Seed default accounts if table is empty
      final accCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM accounts'));
      if (accCount == 0) {
        await db.insert('accounts', {
          'nombre': 'Efectivo',
          'tipo': 'efectivo',
          'saldo_actual': 0.0,
          'color': '#4CAF50',
          'icono': 'payments',
          'creado_en': DateTime.now().toIso8601String(),
        });
        await db.insert('accounts', {
          'nombre': 'Banco Principal',
          'tipo': 'banco',
          'saldo_actual': 0.0,
          'color': '#2196F3',
          'icono': 'account_balance',
          'creado_en': DateTime.now().toIso8601String(),
        });
      }
    }

    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS budgets(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          categoria_id INTEGER NOT NULL,
          monto_limite REAL NOT NULL,
          periodo TEXT NOT NULL DEFAULT 'mensual',
          creado_en TEXT,
          FOREIGN KEY(categoria_id) REFERENCES categories(id)
        );
      ''');
    }

    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS recurring_movements(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          tipo TEXT NOT NULL,
          monto REAL NOT NULL,
          descripcion TEXT,
          categoria_id INTEGER,
          account_id INTEGER,
          frecuencia TEXT NOT NULL,
          dia_ejecucion INTEGER,
          fecha_inicio TEXT NOT NULL,
          fecha_fin TEXT,
          activo INTEGER NOT NULL DEFAULT 1,
          ultima_ejecucion TEXT,
          creado_en TEXT,
          FOREIGN KEY(categoria_id) REFERENCES categories(id),
          FOREIGN KEY(account_id) REFERENCES accounts(id)
        );
      ''');
    }

    if (oldVersion < 6) {
      final tablasConSincronizacion = [
        'categories', 'accounts', 'movements', 'loans', 'loan_payments',
        'goals', 'goal_contributions', 'budgets', 'recurring_movements'
      ];
      for (final tabla in tablasConSincronizacion) {
        try {
          await db.execute('ALTER TABLE $tabla ADD COLUMN updated_at TEXT;');
          await db.execute('ALTER TABLE $tabla ADD COLUMN is_deleted INTEGER NOT NULL DEFAULT 0;');
          await db.execute('ALTER TABLE $tabla ADD COLUMN synced_at TEXT;');
        } catch (_) {}
      }
    }
  }
}
