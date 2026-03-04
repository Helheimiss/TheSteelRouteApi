#pragma once

#include <QSqlError>
#include <QSqlQuery>
#include <QSqlDatabase>

namespace TheSteelRouteApi {
    class Database {
    public:
        Database() = default;
        ~Database();

        void init();

        [[nodiscard]] QSqlQuery sqlQuery(const QString &query) const;
        [[nodiscard]] QSqlQuery sqlQuery() const;

        [[nodiscard]] QString getLastError() const;

        QSqlDatabase &getDatabase();
    protected:
        QSqlDatabase db;
    };
}