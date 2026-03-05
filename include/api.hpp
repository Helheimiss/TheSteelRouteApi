#pragma once

#include "drogon/HttpController.h"

using HttpResponseCallback = std::function<void(const drogon::HttpResponsePtr &)>;

namespace api {
class buses : public drogon::HttpController<buses> {

};


class drivers : public drogon::HttpController<drivers> {

};


class expenses : public drogon::HttpController<expenses> {

};


class orders : public drogon::HttpController<orders> {

};


class payments : public drogon::HttpController<payments> {

};


class user : public drogon::HttpController<user> {
public:
    METHOD_LIST_BEGIN
    METHOD_ADD(user::login, "/public/login/{login}/{password}", drogon::Get);
    METHOD_ADD(user::getAll, "/private/getAll/{token}", drogon::Get);
    METHOD_LIST_END

    void login(const drogon::HttpRequestPtr &req, HttpResponseCallback &&callback, std::string &&login, std::string &&password) const;
    void getAll(const drogon::HttpRequestPtr &req, HttpResponseCallback &&callback, std::string &&token) const;
private:
};
}