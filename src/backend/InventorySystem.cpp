#include "InventorySystem.hpp"
#include "DatabaseManager.hpp"
#include <cmath>

InventorySystem::InventorySystem(QObject *parent) : QObject(parent) {}

bool InventorySystem::addNewProduct(const QString& name, const QString& category, const QString& barcode, double price, int stock) {
    return DatabaseManager::instance().addProduct(name, category, barcode, price, stock);
}

void InventorySystem::runStockPrediction(int daysHistoryAnalysis, int criticalThresholdDays) {
    auto products = DatabaseManager::instance().getAllProducts();
    for (const auto& product : products) {
        double dailyVelocity = static_cast<double>(product.salesInPeriod) / daysHistoryAnalysis;
        int estimatedDaysLeft = 9999;
        if (dailyVelocity > 0.0) {
            estimatedDaysLeft = std::floor(product.currentStock / dailyVelocity);
        }
        if (estimatedDaysLeft <= criticalThresholdDays) {
            emit criticalStockAlert(product.name, product.currentStock, dailyVelocity, estimatedDaysLeft);
        }
    }
}
