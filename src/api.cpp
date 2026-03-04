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
