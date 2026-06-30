#include "SettingsManager.hpp"
#include <QSqlQuery>
#include <QVariant>
#include <QDebug>
#include <QSqlError>

SettingsManager::SettingsManager(QObject *parent) : QObject(parent) {
}

SettingsManager& SettingsManager::instance() {
    static SettingsManager instance;
    return instance;
}

QString SettingsManager::storeName() const { return m_storeName; }
void SettingsManager::setStoreName(const QString& v) {
    if (m_storeName != v) { m_storeName = v; emit settingsChanged(); }
}

QString SettingsManager::currency() const { return m_currency; }
void SettingsManager::setCurrency(const QString& v) {
    if (m_currency != v) { m_currency = v; emit settingsChanged(); }
}

int SettingsManager::criticalStockDays() const { return m_criticalStockDays; }
void SettingsManager::setCriticalStockDays(int v) {
    if (m_criticalStockDays != v) { m_criticalStockDays = v; emit settingsChanged(); }
}

QString SettingsManager::cashierName() const { return m_cashierName; }
void SettingsManager::setCashierName(const QString& v) {
    if (m_cashierName != v) { m_cashierName = v; emit settingsChanged(); }
}

void SettingsManager::saveSettings() {
    auto saveKey = [](const QString& key, const QString& value) {
        QSqlQuery q;
        q.prepare("INSERT OR REPLACE INTO settings (key, value) VALUES (?, ?)");
        q.addBindValue(key);
        q.addBindValue(value);
        q.exec();
    };
    saveKey("storeName", m_storeName);
    saveKey("currency", m_currency);
    saveKey("criticalStockDays", QString::number(m_criticalStockDays));
    saveKey("cashierName", m_cashierName);
}

void SettingsManager::loadSettings() {
    QSqlQuery q("SELECT key, value FROM settings");
    while (q.next()) {
        QString key = q.value(0).toString();
        QString value = q.value(1).toString();
        
        if (key == "storeName") m_storeName = value;
        else if (key == "currency") m_currency = value;
        else if (key == "criticalStockDays") m_criticalStockDays = value.toInt();
        else if (key == "cashierName") m_cashierName = value;
    }
    emit settingsChanged();
}
