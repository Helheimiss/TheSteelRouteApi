#include <QCoreApplication>

#include "Data.hpp"
#include "drogon/HttpAppFramework.h"

#include "Database.hpp"


int main(int argc, char *argv[]) {
    QCoreApplication app(argc, argv);
    DATA::DataBase.init();

    drogon::app()
        .enableServerHeader(false)
        .addListener("0.0.0.0", 80)
        .setThreadNum(2)
        .run();

    return app.exec();
}
