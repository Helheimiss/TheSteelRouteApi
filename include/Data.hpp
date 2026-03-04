#pragma once

#include <string>
#include <unordered_set>

#include "Database.hpp"
#include "jwt-cpp/jwt.h"


namespace DATA {
    inline TheSteelRouteApi::Database DataBase;
    struct User {
        User(const std::string &id, const std::string &last_name, const std::string &first_name,
            const std::string &email, const std::string &phone, const std::string &login,
            const std::string &password_hash, const std::string &created_at)
            : Id(id),
              LastName(last_name),
              FirstName(first_name),
              Email(email),
              Phone(phone),
              Login(login),
              PasswordHash(password_hash),
              CreatedAt(created_at) {
        }

        std::string Id;
        std::string LastName;
        std::string FirstName;
        std::string Email;
        std::string Phone;
        std::string Login;
        std::string PasswordHash;
        std::string CreatedAt;
    };

    inline const std::string SECRET_KEY = "secret";
    inline std::unordered_set<std::string> Tokens;


    inline std::string createToken(const User& usr) {
        auto token= jwt::create()
            .set_type("JWT")
            .set_subject(usr.Id)
            .set_payload_claim("LastName", jwt::claim(usr.LastName))
            .set_payload_claim("FirstName", jwt::claim(usr.FirstName))
            .set_payload_claim("Email", jwt::claim(usr.Email))
            .set_payload_claim("Phone", jwt::claim(usr.Phone))
            .set_payload_claim("Login", jwt::claim(usr.Login))
            .set_payload_claim("CreatedAt", jwt::claim(usr.CreatedAt))
            .set_issued_at(std::chrono::system_clock::now())
            .sign(jwt::algorithm::hs256{SECRET_KEY});

        Tokens.insert(token);
        return token;
    }
}

