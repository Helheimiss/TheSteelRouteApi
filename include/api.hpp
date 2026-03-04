#pragma once

#include "drogon/HttpController.h"

using HttpResponseCallback = std::function<void(const drogon::HttpResponsePtr &)>;

namespace api {
class user : public drogon::HttpController<user> {
public:
    METHOD_LIST_BEGIN
    METHOD_ADD(user::login, "/login/{login}/{password}", drogon::Get);
    METHOD_LIST_END

    void login(const drogon::HttpRequestPtr &req, HttpResponseCallback &&callback, std::string &&login, std::string &&password) const;
private:
};
}