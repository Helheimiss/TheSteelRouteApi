#pragma once

#include "drogon/HttpResponse.h"


namespace Utils {
    inline drogon::HttpResponsePtr makeErrorJson(const std::string &error, drogon::HttpStatusCode statusCode=drogon::HttpStatusCode::k404NotFound) {
        Json::Value json;
        json["error"] = error;
        auto resp = drogon::HttpResponse::newHttpJsonResponse(json);
        resp->setStatusCode(statusCode);

        return resp;
    }

    inline drogon::HttpResponsePtr make404Page() {
        return Utils::makeErrorJson("not found");
    }
}
