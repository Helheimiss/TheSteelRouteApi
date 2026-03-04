#include <QCoreApplication>

#include "drogon/drogon.h"

#include "Database.hpp"


int main(int argc, char *argv[]) {
    QCoreApplication app(argc, argv);

    TheSteelRouteApi::Database db;

    drogon::app()
        .enableServerHeader(false)
        .addListener("0.0.0.0", 80)
        .setThreadNum(2)
        .run();

    return app.exec();
}
