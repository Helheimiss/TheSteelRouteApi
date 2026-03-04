#include "api.hpp"

#include "Data.hpp"

#include <QCryptographicHash>

void api::User::login(const drogon::HttpRequestPtr &req, HttpResponseCallback &&callback, std::string &&login, std::string &&password) const {
    auto resp = drogon::HttpResponse::newHttpResponse(drogon::HttpStatusCode::k200OK, drogon::ContentType::CT_TEXT_PLAIN);

    auto query = DATA::DataBase.sqlQuery();
    query.prepare("SELECT Id, LastName, FirstName, Email, Phone, Login, PasswordHash, CreatedAt FROM Users "
                  "WHERE Login = ? AND PasswordHash = ?;");


    QString qLogin = login.c_str();
    QString qHashPassword = QCryptographicHash::hash(password, QCryptographicHash::Sha256).toHex().toUpper();

    query.bindValue(0, qLogin);
    query.bindValue(1, qHashPassword);


    if (query.exec() && query.next()) {
        DATA::User usr(
        query.value(0).toString().toStdString(),
        query.value(1).toString().toStdString(),
        query.value(2).toString().toStdString(),
        query.value(3).toString().toStdString(),
        query.value(4).toString().toStdString(),
        query.value(5).toString().toStdString(),
        query.value(6).toString().toStdString(),
        query.value(7).toString().toStdString());

        resp->setBody(DATA::createToken(usr));
    }
    else {
        resp->setStatusCode(drogon::HttpStatusCode::k404NotFound);
        resp->setBody("invalid login or password");
    }


    callback(resp);
}
