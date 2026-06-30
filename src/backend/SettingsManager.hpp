#ifndef SETTINGSMANAGER_HPP
#define SETTINGSMANAGER_HPP

#include <QObject>
#include <QString>

class SettingsManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString storeName READ storeName WRITE setStoreName NOTIFY settingsChanged)
    Q_PROPERTY(QString currency READ currency WRITE setCurrency NOTIFY settingsChanged)
    Q_PROPERTY(int criticalStockDays READ criticalStockDays WRITE setCriticalStockDays NOTIFY settingsChanged)
    Q_PROPERTY(QString cashierName READ cashierName WRITE setCashierName NOTIFY settingsChanged)

public:
    explicit SettingsManager(QObject *parent = nullptr);
    static SettingsManager& instance();

    QString storeName() const;
    void setStoreName(const QString& v);
    QString currency() const;
    void setCurrency(const QString& v);
    int criticalStockDays() const;
    void setCriticalStockDays(int v);
    QString cashierName() const;
    void setCashierName(const QString& v);

    Q_INVOKABLE void saveSettings();
    Q_INVOKABLE void loadSettings();

signals:
    void settingsChanged();

private:
    QString m_storeName = "vamp9 POS";
    QString m_currency = "CLP";
    int m_criticalStockDays = 3;
    QString m_cashierName = "Cajero 1";
};

#endif // SETTINGSMANAGER_HPP
