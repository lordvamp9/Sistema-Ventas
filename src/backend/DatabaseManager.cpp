#include "DatabaseManager.hpp"
#include <QStandardPaths>
#include <QDir>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QFile>
#include <QTextStream>
#include <QDateTime>

DatabaseManager::DatabaseManager(QObject *parent) : QObject(parent) {
    QString dataDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/vamp9POS";
    QDir dir;
    if (!dir.exists(dataDir)) {
        dir.mkpath(dataDir);
    }
    
    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName(dataDir + "/vamp9pos.db");
    
    if (m_db.open()) {
        initializeSchema();
    } else {
        qWarning() << "Failed to open database:" << m_db.lastError().text();
    }
}

DatabaseManager& DatabaseManager::instance() {
    static DatabaseManager instance;
    return instance;
}

void DatabaseManager::initializeSchema() {
    QSqlQuery query;
    query.exec("CREATE TABLE IF NOT EXISTS products ("
               "id INTEGER PRIMARY KEY AUTOINCREMENT, "
               "name TEXT NOT NULL, "
               "category TEXT, "
               "barcode TEXT UNIQUE, "
               "price REAL NOT NULL, "
               "current_stock INTEGER DEFAULT 0, "
               "min_stock INTEGER DEFAULT 5)");
               
    query.exec("CREATE TABLE IF NOT EXISTS sales ("
               "id INTEGER PRIMARY KEY AUTOINCREMENT, "
               "barcode TEXT, "
               "product_name TEXT, "
               "price REAL, "
               "payment_method TEXT, "
               "timestamp DATETIME DEFAULT CURRENT_TIMESTAMP)");
               
    query.exec("CREATE TABLE IF NOT EXISTS settings ("
               "key TEXT PRIMARY KEY, "
               "value TEXT)");
               
    // Insert some mock data if empty
    QSqlQuery checkQuery("SELECT COUNT(*) FROM products");
    if (checkQuery.next() && checkQuery.value(0).toInt() == 0) {
        addProduct("Cable HDMI 2M", "Electronica", "123456", 15990, 50);
        addProduct("Cargador Rapido", "Accesorios", "111222", 12500, 5);
        addProduct("Audifonos Inalambricos", "Audio", "333444", 45000, 2);
    }
}

std::vector<ProductData> DatabaseManager::getAllProducts() const {
    std::vector<ProductData> products;
    QSqlQuery query("SELECT id, name, category, barcode, price, current_stock, "
                    "(SELECT COUNT(*) FROM sales WHERE sales.barcode = products.barcode) as salesInPeriod "
                    "FROM products");
    while (query.next()) {
        ProductData p;
        p.id = query.value(0).toInt();
        p.name = query.value(1).toString();
        p.category = query.value(2).toString();
        p.barcode = query.value(3).toString();
        p.price = query.value(4).toDouble();
        p.currentStock = query.value(5).toInt();
        p.salesInPeriod = query.value(6).toInt();
        products.push_back(p);
    }
    return products;
}

bool DatabaseManager::addProduct(const QString& name, const QString& category, const QString& barcode, double price, int stock) {
    QSqlQuery query;
    query.prepare("INSERT INTO products (name, category, barcode, price, current_stock) VALUES (?, ?, ?, ?, ?)");
    query.addBindValue(name);
    query.addBindValue(category);
    query.addBindValue(barcode);
    query.addBindValue(price);
    query.addBindValue(stock);
    return query.exec();
}

ProductData DatabaseManager::getProductByBarcode(const QString& barcode) const {
    QSqlQuery query;
    query.prepare("SELECT id, name, category, barcode, price, current_stock FROM products WHERE barcode = ?");
    query.addBindValue(barcode);
    if (query.exec() && query.next()) {
        ProductData p;
        p.id = query.value(0).toInt();
        p.name = query.value(1).toString();
        p.category = query.value(2).toString();
        p.barcode = query.value(3).toString();
        p.price = query.value(4).toDouble();
        p.currentStock = query.value(5).toInt();
        p.salesInPeriod = 0;
        return p;
    }
    return {-1, "", "", "", 0.0, 0, 0};
}

void DatabaseManager::recordSale(const QString& barcode, const QString& paymentMethod) {
    ProductData p = getProductByBarcode(barcode);
    if (p.id != -1) {
        QSqlQuery updateQuery;
        updateQuery.prepare("UPDATE products SET current_stock = current_stock - 1 WHERE barcode = ?");
        updateQuery.addBindValue(barcode);
        updateQuery.exec();
        
        QSqlQuery insertQuery;
        insertQuery.prepare("INSERT INTO sales (barcode, product_name, price, payment_method) VALUES (?, ?, ?, ?)");
        insertQuery.addBindValue(barcode);
        insertQuery.addBindValue(p.name);
        insertQuery.addBindValue(p.price);
        insertQuery.addBindValue(paymentMethod);
        insertQuery.exec();
    }
}

bool DatabaseManager::importFromCSV(const QString& filePath) {
    // Basic CSV import for local paths (strip file:/// if needed)
    QString path = filePath;
    if(path.startsWith("file:///")) {
        path = path.mid(8);
    }
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) return false;

    QTextStream in(&file);
    bool isFirstLine = true;
    m_db.transaction();
    while (!in.atEnd()) {
        QString line = in.readLine();
        if (isFirstLine) { isFirstLine = false; continue; } // skip header
        QStringList fields = line.split(",");
        if (fields.size() >= 5) {
            QString name = fields[0];
            QString cat = fields[1];
            QString code = fields[2];
            double price = fields[3].toDouble();
            int stock = fields[4].toInt();
            
            QSqlQuery q;
            q.prepare("INSERT OR REPLACE INTO products (id, name, category, barcode, price, current_stock) "
                      "VALUES ((SELECT id FROM products WHERE barcode = ?), ?, ?, ?, ?, ?)");
            q.addBindValue(code);
            q.addBindValue(name);
            q.addBindValue(cat);
            q.addBindValue(code);
            q.addBindValue(price);
            q.addBindValue(stock);
            q.exec();
        }
    }
    m_db.commit();
    return true;
}

bool DatabaseManager::exportToCSV(const QString& filePath) {
    QString path = filePath;
    if(path.startsWith("file:///")) path = path.mid(8);
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) return false;

    QTextStream out(&file);
    out << "name,category,barcode,price,current_stock\n";
    
    QSqlQuery query("SELECT name, category, barcode, price, current_stock FROM products");
    while (query.next()) {
        out << query.value(0).toString() << ","
            << query.value(1).toString() << ","
            << query.value(2).toString() << ","
            << query.value(3).toString() << ","
            << query.value(4).toString() << "\n";
    }
    return true;
}

bool DatabaseManager::exportSalesToCSV(const QString& filePath) {
    QString path = filePath;
    if(path.startsWith("file:///")) path = path.mid(8);
    QFile file(path);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) return false;

    QTextStream out(&file);
    out << "id,barcode,product_name,price,payment_method,timestamp\n";
    
    QSqlQuery query("SELECT id, barcode, product_name, price, payment_method, timestamp FROM sales");
    while (query.next()) {
        out << query.value(0).toString() << ","
            << query.value(1).toString() << ","
            << query.value(2).toString() << ","
            << query.value(3).toString() << ","
            << query.value(4).toString() << ","
            << query.value(5).toString() << "\n";
    }
    return true;
}

bool DatabaseManager::updateProduct(int id, const QString& name, const QString& category, const QString& barcode, double price, int stock) {
    QSqlQuery query;
    query.prepare("UPDATE products SET name=?, category=?, barcode=?, price=?, current_stock=? WHERE id=?");
    query.addBindValue(name);
    query.addBindValue(category);
    query.addBindValue(barcode);
    query.addBindValue(price);
    query.addBindValue(stock);
    query.addBindValue(id);
    return query.exec();
}

bool DatabaseManager::deleteProduct(int id) {
    QSqlQuery query;
    query.prepare("DELETE FROM products WHERE id=?");
    query.addBindValue(id);
    return query.exec();
}

bool DatabaseManager::restockProduct(int id, int quantity) {
    QSqlQuery query;
    query.prepare("UPDATE products SET current_stock = current_stock + ? WHERE id=?");
    query.addBindValue(quantity);
    query.addBindValue(id);
    return query.exec();
}

QVariantList DatabaseManager::getSalesHistory(int limit) const {
    QVariantList list;
    QSqlQuery query;
    query.prepare("SELECT product_name, price, timestamp FROM sales ORDER BY timestamp DESC LIMIT ?");
    query.addBindValue(limit);
    if(query.exec()) {
        while(query.next()) {
            QVariantMap map;
            map["name"] = query.value(0).toString();
            map["price"] = query.value(1).toDouble();
            map["time"] = query.value(2).toDateTime().toString("HH:mm");
            list.append(map);
        }
    }
    return list;
}

QVariantMap DatabaseManager::getDailyStats() const {
    QVariantMap map;
    QSqlQuery query("SELECT COUNT(*), SUM(price) FROM sales WHERE date(timestamp) = date('now', 'localtime')");
    if(query.next()) {
        map["transactions"] = query.value(0).toInt();
        map["total"] = query.value(1).toDouble();
    }
    return map;
}
