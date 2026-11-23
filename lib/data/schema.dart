/// SQL statements that create the version 1 database schema.
///
/// Conventions shared by every table:
/// - `id` is a UUID string, so data from several devices can be merged later.
/// - `created_at`, `updated_at` and `deleted_at` are Unix epoch milliseconds.
/// - Rows are never hard-deleted; a non-null `deleted_at` marks them as removed.
/// - Money is stored as integers in the currency's minor unit
///   (VND: dong, USD: cents) to avoid floating point rounding errors.
/// - Calendar dates (due dates, billing periods) are ISO strings `yyyy-MM-dd`.
const List<String> schemaV1 = [
  // A book is one thing the user manages: a boarding house, a shop, ...
  '''
  CREATE TABLE books (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    template TEXT NOT NULL,
    currency TEXT NOT NULL,
    note TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    deleted_at INTEGER
  )
  ''',
  // Income and expense categories of a book.
  '''
  CREATE TABLE categories (
    id TEXT PRIMARY KEY,
    book_id TEXT NOT NULL REFERENCES books(id),
    name TEXT NOT NULL,
    direction TEXT NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    deleted_at INTEGER
  )
  ''',
  // Things inside a book: rooms, houses, vehicles, products.
  '''
  CREATE TABLE items (
    id TEXT PRIMARY KEY,
    book_id TEXT NOT NULL REFERENCES books(id),
    name TEXT NOT NULL,
    kind TEXT NOT NULL,
    area_m2 REAL,
    default_price INTEGER,
    note TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    deleted_at INTEGER
  )
  ''',
  // People: tenants, suppliers, buyers. Shared across books.
  '''
  CREATE TABLE contacts (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    phone TEXT,
    id_number TEXT,
    note TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    deleted_at INTEGER
  )
  ''',
  // Rental contracts (rental template only).
  '''
  CREATE TABLE contracts (
    id TEXT PRIMARY KEY,
    item_id TEXT NOT NULL REFERENCES items(id),
    contact_id TEXT NOT NULL REFERENCES contacts(id),
    start_date TEXT NOT NULL,
    end_date TEXT,
    rent_amount INTEGER NOT NULL,
    currency TEXT NOT NULL,
    cycle TEXT NOT NULL,
    next_due_date TEXT NOT NULL,
    occupants INTEGER NOT NULL DEFAULT 1,
    deposit_amount INTEGER NOT NULL DEFAULT 0,
    deposit_status TEXT NOT NULL DEFAULT 'none',
    status TEXT NOT NULL DEFAULT 'active',
    note TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    deleted_at INTEGER
  )
  ''',
  // Extra charge templates (electricity, water, wifi, ...).
  // Belongs either to a book (default prices) or to a single contract.
  '''
  CREATE TABLE charge_templates (
    id TEXT PRIMARY KEY,
    book_id TEXT REFERENCES books(id),
    contract_id TEXT REFERENCES contracts(id),
    name TEXT NOT NULL,
    calc_type TEXT NOT NULL,
    unit_price INTEGER NOT NULL DEFAULT 0,
    last_meter_reading REAL,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    deleted_at INTEGER
  )
  ''',
  // Recurring amounts that do not need a contract (e.g. monthly shop rent).
  '''
  CREATE TABLE recurring_rules (
    id TEXT PRIMARY KEY,
    book_id TEXT NOT NULL REFERENCES books(id),
    direction TEXT NOT NULL,
    title TEXT NOT NULL,
    amount INTEGER NOT NULL,
    currency TEXT NOT NULL,
    cycle TEXT NOT NULL,
    next_due_date TEXT NOT NULL,
    category_id TEXT REFERENCES categories(id),
    contact_id TEXT REFERENCES contacts(id),
    active INTEGER NOT NULL DEFAULT 1,
    note TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    deleted_at INTEGER
  )
  ''',
  // Amounts that fall due: receivable (to collect) or payable (to pay).
  // These are what the app reminds the user about.
  '''
  CREATE TABLE dues (
    id TEXT PRIMARY KEY,
    book_id TEXT NOT NULL REFERENCES books(id),
    direction TEXT NOT NULL,
    contact_id TEXT REFERENCES contacts(id),
    contract_id TEXT REFERENCES contracts(id),
    recurring_rule_id TEXT REFERENCES recurring_rules(id),
    title TEXT NOT NULL,
    period_start TEXT,
    period_end TEXT,
    due_date TEXT NOT NULL,
    currency TEXT NOT NULL,
    total_amount INTEGER NOT NULL DEFAULT 0,
    paid_amount INTEGER NOT NULL DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'unpaid',
    snoozed_until TEXT,
    promise_note TEXT,
    note TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    deleted_at INTEGER
  )
  ''',
  // Lines of a due. Unit price is copied here so later price changes
  // never alter old bills.
  '''
  CREATE TABLE due_lines (
    id TEXT PRIMARY KEY,
    due_id TEXT NOT NULL REFERENCES dues(id),
    name TEXT NOT NULL,
    calc_type TEXT NOT NULL,
    unit_price INTEGER NOT NULL DEFAULT 0,
    quantity REAL,
    previous_reading REAL,
    current_reading REAL,
    amount INTEGER NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    deleted_at INTEGER
  )
  ''',
  // Every time money actually comes in or goes out. Reports are built from this.
  '''
  CREATE TABLE transactions (
    id TEXT PRIMARY KEY,
    book_id TEXT NOT NULL REFERENCES books(id),
    direction TEXT NOT NULL,
    category_id TEXT REFERENCES categories(id),
    amount INTEGER NOT NULL,
    currency TEXT NOT NULL,
    date TEXT NOT NULL,
    item_id TEXT REFERENCES items(id),
    quantity REAL,
    contact_id TEXT REFERENCES contacts(id),
    due_id TEXT REFERENCES dues(id),
    note TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    deleted_at INTEGER
  )
  ''',
  // Simple key/value app settings (bank account for VietQR, backup options, ...).
  '''
  CREATE TABLE settings (
    key TEXT PRIMARY KEY,
    value TEXT,
    updated_at INTEGER NOT NULL
  )
  ''',
  'CREATE INDEX idx_categories_book ON categories(book_id)',
  'CREATE INDEX idx_items_book ON items(book_id)',
  'CREATE INDEX idx_contracts_item ON contracts(item_id)',
  'CREATE INDEX idx_contracts_contact ON contracts(contact_id)',
  'CREATE INDEX idx_charge_templates_book ON charge_templates(book_id)',
  'CREATE INDEX idx_charge_templates_contract ON charge_templates(contract_id)',
  'CREATE INDEX idx_recurring_rules_book ON recurring_rules(book_id)',
  'CREATE INDEX idx_dues_book ON dues(book_id)',
  'CREATE INDEX idx_dues_due_date ON dues(due_date)',
  'CREATE INDEX idx_due_lines_due ON due_lines(due_id)',
  'CREATE INDEX idx_transactions_book_date ON transactions(book_id, date)',
];

/// Version 2: per-book defaults for rentals, notice before moving out, and
/// per-line payment tracking on bills.
const List<String> migrationV2 = [
  // 'postpaid': rent for a period is collected at its end (live first,
  // pay after). 'prepaid': collected at its start.
  "ALTER TABLE books ADD COLUMN rent_timing TEXT NOT NULL DEFAULT 'postpaid'",
  // New contracts suggest a deposit of this many months of rent.
  'ALTER TABLE books ADD COLUMN deposit_months INTEGER NOT NULL DEFAULT 1',
  // Days of notice a tenant must give before moving out to get the
  // deposit back.
  'ALTER TABLE books ADD COLUMN notice_days INTEGER NOT NULL DEFAULT 14',
  'ALTER TABLE contracts ADD COLUMN notice_days INTEGER NOT NULL DEFAULT 14',
  'ALTER TABLE contracts ADD COLUMN notice_date TEXT',
  'ALTER TABLE contracts ADD COLUMN move_out_date TEXT',
  // Day of month bills fall on, taken from the move-in date. Kept so
  // short months (e.g. February) do not shift it permanently.
  'ALTER TABLE contracts ADD COLUMN anchor_day INTEGER NOT NULL DEFAULT 1',
  'ALTER TABLE due_lines ADD COLUMN paid_amount INTEGER NOT NULL DEFAULT 0',
  'CREATE INDEX idx_contacts_name ON contacts(name)',
];

/// Version 3: rental templates. A template pre-fills the rent-out form for
/// a new tenant (rent, cycle, occupants, deposit, extra charges).
/// Extra charges now belong to a contract or to a template; the former
/// per-book default charges are moved into a default template by
/// `AppDatabase` during the upgrade.
const List<String> migrationV3 = [
  '''
  CREATE TABLE rental_templates (
    id TEXT PRIMARY KEY,
    book_id TEXT NOT NULL REFERENCES books(id),
    name TEXT NOT NULL,
    rent_amount INTEGER,
    cycle TEXT NOT NULL DEFAULT 'month',
    occupants INTEGER NOT NULL DEFAULT 1,
    deposit_months INTEGER NOT NULL DEFAULT 1,
    is_default INTEGER NOT NULL DEFAULT 0,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    deleted_at INTEGER
  )
  ''',
  'CREATE INDEX idx_rental_templates_book ON rental_templates(book_id)',
  'ALTER TABLE charge_templates ADD COLUMN rental_template_id TEXT '
      'REFERENCES rental_templates(id)',
  'CREATE INDEX idx_charge_templates_rental_template '
      'ON charge_templates(rental_template_id)',
];
