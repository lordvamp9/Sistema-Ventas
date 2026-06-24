#include "POSController.hpp"
#include "DatabaseManager.hpp"

POSController::POSController(QObject *parent) : QObject(parent), m_total(0.0) {}

QVariantList POSController::cartItems() const { return m_cart; }
double POSController::totalAmount() const { return m_total; }

void POSController::processScan(const QString& barcode) {
    ProductData prod = DatabaseManager::instance().getProductByBarcode(barcode);
    if (prod.id != -1) {
        QVariantMap item;
        item["name"] = prod.name;
        item["price"] = prod.price;
        m_cart.append(item);
        m_total += prod.price;
        emit cartChanged();
        emit scanResult(true);
    } else {
        emit scanResult(false);
    }
}

#ifdef _WIN32
#include <windows.h>
#endif

void POSController::checkout() {
    m_cart.clear();
    m_total = 0.0;
    emit cartChanged();
    emit checkoutCompleted();
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
    // Ascending chime
    Beep(1200, 80);
    Beep(1500, 80);
    Beep(1800, 120);
#endif
}
