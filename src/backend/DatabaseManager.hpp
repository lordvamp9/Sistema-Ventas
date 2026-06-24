#ifndef DATABASEMANAGER_HPP
#define DATABASEMANAGER_HPP

#include <QObject>
#include <QString>
#include <vector>

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
    void recordSale(const QString& barcode);

private:
    std::vector<ProductData> m_mockDB;
};

#endif // DATABASEMANAGER_HPP
