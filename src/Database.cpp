#include "Database.hpp"


TheSteelRouteApi::Database::~Database() {
    db.close();
}

void TheSteelRouteApi::Database::init() {
    db = QSqlDatabase::addDatabase("QODBC");
    QString connectionString =
        "DRIVER={ODBC Driver 18 for SQL Server};"
        "SERVER=localhost;"
        "DATABASE=SteelRouteDB;"
        "UID=sa;"
        "PWD=TempPa55wd;"
        "TrustServerCertificate=yes;";

    db.setDatabaseName(connectionString);
    if (!db.open())
        throw std::runtime_error(getLastError().toStdString());
}

QSqlQuery TheSteelRouteApi::Database::sqlQuery(const QString &query) const {
    return QSqlQuery(query, db);
}

QSqlQuery TheSteelRouteApi::Database::sqlQuery() const {
    return QSqlQuery(db);
}

QString TheSteelRouteApi::Database::getLastError() const {
    return db.lastError().text();
}

QSqlDatabase &TheSteelRouteApi::Database::getDatabase() {
    return db;
}
