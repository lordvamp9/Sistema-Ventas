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

public:
    explicit POSController(QObject *parent = nullptr);

    QVariantList cartItems() const;
    double totalAmount() const;

    Q_INVOKABLE void processScan(const QString& barcode);
    Q_INVOKABLE void checkout();

signals:
    void cartChanged();
    void scanResult(bool success);
    void checkoutCompleted();

private:
    QVariantList m_cart;
    double m_total;
};

#endif // POSCONTROLLER_HPP
