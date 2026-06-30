#include "POSController.hpp"
#include "DatabaseManager.hpp"
#include <QCoreApplication>
#include <QDir>
#ifdef _WIN32
#include <windows.h>
#include <mmsystem.h>
#endif

POSController::POSController(QObject *parent) : QObject(parent), m_total(0.0) {}

QVariantList POSController::cartItems() const { return m_cart; }
double POSController::totalAmount() const { return m_total; }

void POSController::recalculateTotal() {
    m_total = 0.0;
    for (const QVariant& v : m_cart) {
        QVariantMap item = v.toMap();
        m_total += item["price"].toDouble() * item["quantity"].toInt();
    }
    emit cartChanged();
}

void POSController::processScan(const QString& barcode) {
    ProductData prod = DatabaseManager::instance().getProductByBarcode(barcode);
    if (prod.id != -1) {
        // Check if already in cart
        bool found = false;
        for (int i = 0; i < m_cart.size(); ++i) {
            QVariantMap item = m_cart[i].toMap();
            if (item["barcode"].toString() == barcode) {
                item["quantity"] = item["quantity"].toInt() + 1;
                m_cart[i] = item;
                found = true;
                break;
            }
        }
        if (!found) {
            QVariantMap item;
            item["name"] = prod.name;
            item["price"] = prod.price;
            item["barcode"] = barcode;
            item["quantity"] = 1;
            m_cart.append(item);
        }
        recalculateTotal();
        emit scanResult(true);
    } else {
        emit scanResult(false);
    }
}

void POSController::clearCart() {
    m_cart.clear();
    recalculateTotal();
}

void POSController::removeCartItem(int index) {
    if (index >= 0 && index < m_cart.size()) {
        m_cart.removeAt(index);
        recalculateTotal();
    }
}

void POSController::increaseQty(int index) {
    if (index >= 0 && index < m_cart.size()) {
        QVariantMap item = m_cart[index].toMap();
        item["quantity"] = item["quantity"].toInt() + 1;
        m_cart[index] = item;
        recalculateTotal();
    }
}

void POSController::decreaseQty(int index) {
    if (index >= 0 && index < m_cart.size()) {
        QVariantMap item = m_cart[index].toMap();
        int qty = item["quantity"].toInt();
        if (qty > 1) {
            item["quantity"] = qty - 1;
            m_cart[index] = item;
            recalculateTotal();
        } else {
            removeCartItem(index);
        }
    }
}

void POSController::checkout(const QString& paymentMethod) {
    for (const QVariant& v : m_cart) {
        QVariantMap item = v.toMap();
        int qty = item["quantity"].toInt();
        for (int i=0; i<qty; ++i) {
            DatabaseManager::instance().recordSale(item["barcode"].toString(), paymentMethod);
        }
    }
    m_cart.clear();
    m_total = 0.0;
    emit cartChanged();
    emit checkoutCompleted();
    emit dailyStatsChanged();
}

int POSController::dailyTransactions() const {
    return DatabaseManager::instance().getDailyStats()["transactions"].toInt();
}

double POSController::dailyTotal() const {
    return DatabaseManager::instance().getDailyStats()["total"].toDouble();
}

int POSController::dailyItemsCount() const {
    // simplified: return transactions count for now
    return dailyTransactions();
}

QVariantList POSController::recentSales() const {
    return DatabaseManager::instance().getSalesHistory(10);
}

void POSController::playBeep() {
#ifdef _WIN32
    Beep(1000, 100); // 1000 Hz for 100 ms
#endif
}

void POSController::playError() {
#ifdef _WIN32
    Beep(300, 300);  // Low pitch buzz
#endif
}

void POSController::playSuccess() {
#ifdef _WIN32
    // Resolve the path correctly from the build folder
    QString wavPath = QCoreApplication::applicationDirPath() + "/../src/assets/cash.wav";
    PlaySoundA(wavPath.toLocal8Bit().constData(), NULL, SND_FILENAME | SND_ASYNC);
#endif
}
