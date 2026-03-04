#pragma once

#include <QSqlError>
#include <QSqlQuery>
#include <QSqlDatabase>

namespace TheSteelRouteApi {
    class Database {
    public:
        Database();
        ~Database();

        [[nodiscard]] QSqlQuery sqlQuery(const QString &query) const;
        [[nodiscard]] QSqlQuery sqlQuery() const;

        [[nodiscard]] QString getLastError() const;

        QSqlDatabase &getDatabase();
    protected:
        QSqlDatabase db;

    private:
        bool openDatabase();
        void closeDatabase();
    };
}