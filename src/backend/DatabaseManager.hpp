#ifndef DATABASEMANAGER_HPP
#define DATABASEMANAGER_HPP

#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include <QSqlDatabase>

struct ProductData {
    int id;
    QString name;
    QString category;
    QString barcode;
    double price;
    int currentStock;
    int salesInPeriod;
};

class DatabaseManager : public QObject {
    Q_OBJECT
public:
    explicit DatabaseManager(QObject *parent = nullptr);
    static DatabaseManager& instance();

    std::vector<ProductData> getAllProducts() const;
    bool addProduct(const QString& name, const QString& category, const QString& barcode, double price, int stock);
    ProductData getProductByBarcode(const QString& barcode) const;
    
    // V2 features
    void recordSale(const QString& barcode, const QString& paymentMethod);
    bool importFromCSV(const QString& filePath);
    bool exportToCSV(const QString& filePath);
    bool exportSalesToCSV(const QString& filePath);
    bool updateProduct(int id, const QString& name, const QString& category, const QString& barcode, double price, int stock);
    bool deleteProduct(int id);
    bool restockProduct(int id, int quantity);
    
    QVariantList getSalesHistory(int limit) const;
    QVariantMap getDailyStats() const;

private:
    void initializeSchema();
    QSqlDatabase m_db;
};

#endif // DATABASEMANAGER_HPP
