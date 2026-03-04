#pragma once

#include <string>
#include <unordered_set>

#include "Database.hpp"
#include "jwt-cpp/jwt.h"


namespace DATA {
    inline TheSteelRouteApi::Database DataBase;

    inline const std::string SECRET_KEY = "secret";
    inline std::unordered_set<std::string> Tokens;


    inline std::string createToken(int id, std::string login, int roleId) {
        auto token= jwt::create()
            .set_type("JWT")
            .set_subject(std::to_string(id))
            .set_payload_claim("login", jwt::claim(login))
            .set_payload_claim("roleId", jwt::claim(std::to_string(roleId)))
            .set_audience("TheSteelRoute")
            .set_issuer("TheSteelRouteApi")
            .sign(jwt::algorithm::hs256{SECRET_KEY});

        return token;
    }
}

