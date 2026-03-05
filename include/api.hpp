#pragma once

#include "drogon/HttpController.h"

using HttpResponseCallback = std::function<void(const drogon::HttpResponsePtr &)>;

namespace api {
class buses : public drogon::HttpController<buses> {
public:

};


class drivers : public drogon::HttpController<drivers> {
public:

};


class expenses : public drogon::HttpController<expenses> {
public:

};


class orders : public drogon::HttpController<orders> {
public:
    METHOD_LIST_BEGIN
    METHOD_ADD(orders::create, "/private/create/{FromAddress}/{ToAddress}/{TravelTimeMinutes}/{DistanceKm}/{TravelDate}/{TravelTime}/{PassengerCount}/{token}", drogon::Get);
    METHOD_ADD(orders::getAll, "/private/getAll/{token}", drogon::Get);
    METHOD_LIST_END

    void create(const drogon::HttpRequestPtr &req, HttpResponseCallback &&callback, std::string &&FromAddress, std::string &&ToAddress, int TravelTimeMinutes, double DistanceKm, std::string &&TravelDate, std
                ::string &&TravelTime, int PassengerCount, std::string &&token) const;

    // for current user
    void getAll(const drogon::HttpRequestPtr &req, HttpResponseCallback &&callback, std::string &&token) const;
};


class payments : public drogon::HttpController<payments> {
public:
};


class user : public drogon::HttpController<user> {
public:
    METHOD_LIST_BEGIN
    METHOD_ADD(user::login, "/public/login/{login}/{password}", drogon::Get);
    METHOD_ADD(user::getAll, "/private/getAll/{token}", drogon::Get);
    METHOD_LIST_END

    void login(const drogon::HttpRequestPtr &req, HttpResponseCallback &&callback, std::string &&login, std::string &&password) const;

    // only for admin
    void getAll(const drogon::HttpRequestPtr &req, HttpResponseCallback &&callback, std::string &&token) const;
private:
};
}