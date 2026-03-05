#pragma once

#include <string>

#include "User.hpp"
#include "Data.hpp"

namespace Token {
    inline std::string createToken(const User& usr) {
        if (Data::Tokens.contains(hash_value(usr))) {
            return Data::Tokens[hash_value(usr)];
        }

        auto token = jwt::create()
            .set_type("JWT")
            .set_subject(usr.Id)
            .set_payload_claim("LastName", jwt::claim(usr.LastName))
            .set_payload_claim("FirstName", jwt::claim(usr.FirstName))
            .set_payload_claim("Email", jwt::claim(usr.Email))
            .set_payload_claim("Phone", jwt::claim(usr.Phone))
            .set_payload_claim("Login", jwt::claim(usr.Login))
            .set_payload_claim("Role", jwt::claim(usr.Role))
            .set_payload_claim("CreatedAt", jwt::claim(usr.CreatedAt))
            .set_issued_at(std::chrono::system_clock::now())
            .sign(jwt::algorithm::hs256{Data::SECRET_KEY});

        Data::Tokens.insert(hash_value(usr), token);
        return token;
    }

    inline bool verifyToken(const std::string& token) {
        try {
            auto decoded = jwt::decode(token);

            auto verifier = jwt::verify()
                .allow_algorithm(jwt::algorithm::hs256{Data::SECRET_KEY});

            verifier.verify(decoded);

            return Data::Tokens.values().contains(token);
        } catch (...) {
            return false;
        }
    }
}
