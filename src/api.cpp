#include "api.hpp"

#include "Data.hpp"

#include <QCryptographicHash>

void api::User::login(const drogon::HttpRequestPtr &req, HttpResponseCallback &&callback, std::string &&login, std::string &&password) const {
    auto resp = drogon::HttpResponse::newHttpResponse(drogon::HttpStatusCode::k200OK, drogon::ContentType::CT_TEXT_PLAIN);

    auto query = DATA::DataBase.sqlQuery();
    query.prepare("SELECT Id, Username, PasswordHash, RoleId FROM Users "
                  "WHERE Username = ? AND PasswordHash = ?;");


    QString qLogin = login.c_str();
    QString qHashPassword = QCryptographicHash::hash(password, QCryptographicHash::Sha256).toHex().toUpper();

    query.bindValue(0, qLogin);
    query.bindValue(1, qHashPassword);


    if (query.exec() && query.next()) {
        int id = query.value(0).toInt();
        int roleId = query.value(3).toInt();

        resp->setBody(DATA::createToken(id, login, roleId));
    }
    else {
        resp->setStatusCode(drogon::HttpStatusCode::k404NotFound);
        resp->setBody("invalid login or password");
    }


    callback(resp);
}
