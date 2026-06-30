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
    
    Q_INVOKABLE QVariantList searchByName(const QString& query);
    Q_INVOKABLE bool restockProduct(int id, int quantity);
    Q_INVOKABLE bool importFromCSV(const QString& filePath);
    Q_INVOKABLE bool exportInventoryCSV(const QString& filePath);
    Q_INVOKABLE bool exportSalesCSV(const QString& filePath);
    
    Q_PROPERTY(int criticalProductsCount READ criticalProductsCount NOTIFY criticalProductsCountChanged)
    int criticalProductsCount() const;

signals:
    void criticalStockAlert(QString productName, int currentStock, double dailyVelocity, int estimatedDaysLeft);
    void criticalProductsCountChanged();

private:
    int m_criticalCount = 0;
};

#endif // INVENTORYSYSTEM_HPP
