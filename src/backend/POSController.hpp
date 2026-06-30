#ifndef POSCONTROLLER_HPP
#define POSCONTROLLER_HPP

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QString>

class POSController : public QObject {
    Q_OBJECT
    Q_PROPERTY(QVariantList cartItems READ cartItems NOTIFY cartChanged)
    Q_PROPERTY(double totalAmount READ totalAmount NOTIFY cartChanged)
    
    Q_PROPERTY(int dailyTransactions READ dailyTransactions NOTIFY dailyStatsChanged)
    Q_PROPERTY(double dailyTotal READ dailyTotal NOTIFY dailyStatsChanged)
    Q_PROPERTY(int dailyItemsCount READ dailyItemsCount NOTIFY dailyStatsChanged)
    Q_PROPERTY(QVariantList recentSales READ recentSales NOTIFY dailyStatsChanged)

public:
    explicit POSController(QObject *parent = nullptr);

    QVariantList cartItems() const;
    double totalAmount() const;

    Q_INVOKABLE void processScan(const QString& barcode);
    Q_INVOKABLE void checkout(const QString& paymentMethod);
    Q_INVOKABLE void clearCart();
    Q_INVOKABLE void removeCartItem(int index);
    Q_INVOKABLE void increaseQty(int index);
    Q_INVOKABLE void decreaseQty(int index);
    
    int dailyTransactions() const;
    double dailyTotal() const;
    int dailyItemsCount() const;
    QVariantList recentSales() const;
    
    Q_INVOKABLE void playBeep();
    Q_INVOKABLE void playError();
    Q_INVOKABLE void playSuccess();

signals:
    void cartChanged();
    void scanResult(bool success);
    void checkoutCompleted();
    void dailyStatsChanged();

private:
    void recalculateTotal();
    QVariantList m_cart;
    double m_total;
};

#endif // POSCONTROLLER_HPP
