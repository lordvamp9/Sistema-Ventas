#include "InventorySystem.hpp"
#include "DatabaseManager.hpp"
#include <cmath>

InventorySystem::InventorySystem(QObject *parent) : QObject(parent) {}

bool InventorySystem::addNewProduct(const QString& name, const QString& category, const QString& barcode, double price, int stock) {
    return DatabaseManager::instance().addProduct(name, category, barcode, price, stock);
}

void InventorySystem::runStockPrediction(int daysHistoryAnalysis, int criticalThresholdDays) {
    auto products = DatabaseManager::instance().getAllProducts();
    m_criticalCount = 0;
    for (const auto& product : products) {
        double dailyVelocity = static_cast<double>(product.salesInPeriod) / daysHistoryAnalysis;
        int estimatedDaysLeft = 9999;
        if (dailyVelocity > 0.0) {
            estimatedDaysLeft = std::floor(product.currentStock / dailyVelocity);
        }
        if (estimatedDaysLeft <= criticalThresholdDays || product.currentStock <= 5) {
            m_criticalCount++;
            emit criticalStockAlert(product.name, product.currentStock, dailyVelocity, estimatedDaysLeft);
        }
    }
    emit criticalProductsCountChanged();
}

int InventorySystem::criticalProductsCount() const {
    return m_criticalCount;
}

QVariantList InventorySystem::searchByName(const QString& query) {
    QVariantList list;
    auto products = DatabaseManager::instance().getAllProducts();
    for (const auto& p : products) {
        if (p.name.contains(query, Qt::CaseInsensitive)) {
            QVariantMap map;
            map["id"] = p.id;
            map["name"] = p.name;
            map["price"] = p.price;
            map["barcode"] = p.barcode;
            list.append(map);
        }
    }
    return list;
}

bool InventorySystem::restockProduct(int id, int quantity) {
    return DatabaseManager::instance().restockProduct(id, quantity);
}

bool InventorySystem::importFromCSV(const QString& filePath) {
    return DatabaseManager::instance().importFromCSV(filePath);
}

bool InventorySystem::exportInventoryCSV(const QString& filePath) {
    return DatabaseManager::instance().exportToCSV(filePath);
}

bool InventorySystem::exportSalesCSV(const QString& filePath) {
    return DatabaseManager::instance().exportSalesToCSV(filePath);
}
