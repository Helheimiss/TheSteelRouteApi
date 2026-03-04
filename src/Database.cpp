#include "Database.hpp"

TheSteelRouteApi::Database::Database() {
    db = QSqlDatabase::addDatabase("QODBC");
    QString connectionString =
        "DRIVER={ODBC Driver 18 for SQL Server};"
        "SERVER=localhost;"
        "DATABASE=SteelRouteDB;"
        "UID=sa;"
        "PWD=TempPa55wd;"
        "TrustServerCertificate=yes;";

    db.setDatabaseName(connectionString);
}

TheSteelRouteApi::Database::~Database() {
    closeDatabase();
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

bool TheSteelRouteApi::Database::openDatabase() {
    return db.open();
}

void TheSteelRouteApi::Database::closeDatabase() {
    db.close();
}

QSqlDatabase &TheSteelRouteApi::Database::getDatabase() {
    return db;
}
