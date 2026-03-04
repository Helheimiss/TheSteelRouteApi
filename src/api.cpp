#include "api.hpp"

#include "Data.hpp"

#include <QCryptographicHash>

#include "Token.hpp"
#include "User.hpp"

void api::user::login(const drogon::HttpRequestPtr &req, HttpResponseCallback &&callback, std::string &&login, std::string &&password) const {
    auto resp = drogon::HttpResponse::newHttpResponse(drogon::HttpStatusCode::k200OK, drogon::ContentType::CT_TEXT_PLAIN);

    auto usr = User::findUser(login, password);

    if (usr) {
        resp->setBody(token::createToken(*usr));
    }
    else {
        resp->setStatusCode(drogon::HttpStatusCode::k404NotFound);
        resp->setBody("invalid login or password");
    }


    callback(resp);
}

void api::user::getAll(const drogon::HttpRequestPtr &req, HttpResponseCallback &&callback) const {
    Json::Value usersJson;
    // TODO() valid token


    auto users = User::getAllUsers();
    usersJson["count"] = static_cast<int>(users.size());
    usersJson["users"] = Json::arrayValue;

    for (const auto & user : users) {
        Json::Value userJson;
        userJson["Id"] = user.Id;
        userJson["LastName"] = user.LastName;
        userJson["FirstName"] = user.FirstName;
        userJson["Email"] = user.Email;
        userJson["Phone"] = user.Phone;
        userJson["Login"] = user.Login;
        userJson["PasswordHash"] = user.PasswordHash;
        userJson["CreatedAt"] = user.CreatedAt;

        usersJson["users"].append(userJson);  // Добавляем userJson в массив
    }


    auto resp = drogon::HttpResponse::newHttpJsonResponse(usersJson);
    callback(resp);
}
