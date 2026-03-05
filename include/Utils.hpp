#pragma once

#include "drogon/HttpResponse.h"


namespace Utils {
    inline drogon::HttpResponsePtr make404Page() {
        drogon::HttpResponsePtr resp = drogon::HttpResponse::newHttpResponse(drogon::HttpStatusCode::k404NotFound, drogon::ContentType::CT_TEXT_PLAIN);
        resp->setBody("not found");

        return resp;
    }

    inline drogon::HttpResponsePtr makeErrorJson(const std::string &error) {
        Json::Value json;
        json["error"] = error;

        return drogon::HttpResponse::newHttpJsonResponse(json);
    }
}
