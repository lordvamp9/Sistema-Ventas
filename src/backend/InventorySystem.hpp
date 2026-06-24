#ifndef INVENTORYSYSTEM_HPP
#define INVENTORYSYSTEM_HPP

#include <QObject>
#include <QString>

class InventorySystem : public QObject {
    Q_OBJECT
public:
    explicit InventorySystem(QObject *parent = nullptr);

    Q_INVOKABLE bool addNewProduct(const QString& name, const QString& category, const QString& barcode, double price, int stock);
    Q_INVOKABLE void runStockPrediction(int daysHistoryAnalysis, int criticalThresholdDays);

signals:
    void criticalStockAlert(QString productName, int currentStock, double dailyVelocity, int estimatedDaysLeft);
};

#endif // INVENTORYSYSTEM_HPP
