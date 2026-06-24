#include "DatabaseManager.hpp"

DatabaseManager::DatabaseManager(QObject *parent) : QObject(parent) {
    m_mockDB = {
        {1, "Cable HDMI 2M", "Electronica", "123456", 15.99, 50, 10},
        {2, "Cargador Rapido", "Accesorios", "111222", 12.50, 5, 20},
        {3, "Audifonos Inalambricos", "Audio", "333444", 45.00, 2, 15}
    };
}

DatabaseManager& DatabaseManager::instance() {
    static DatabaseManager instance;
    return instance;
}

std::vector<ProductData> DatabaseManager::getAllProducts() const {
    return m_mockDB;
}

bool DatabaseManager::addProduct(const QString& name, const QString& category, const QString& barcode, double price, int stock) {
    int newId = m_mockDB.empty() ? 1 : m_mockDB.back().id + 1;
    m_mockDB.push_back({newId, name, category, barcode, price, stock, 0});
    return true;
}

ProductData DatabaseManager::getProductByBarcode(const QString& barcode) const {
    for (const auto& prod : m_mockDB) {
        if (prod.barcode == barcode) return prod;
    }
    return {-1, "", "", "", 0.0, 0, 0};
}

void DatabaseManager::recordSale(const QString& barcode) {
    for (auto& prod : m_mockDB) {
        if (prod.barcode == barcode) {
            prod.currentStock--;
            prod.salesInPeriod++;
            break;
        }
    }
}
