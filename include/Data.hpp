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

        friend std::size_t hash_value(const User &obj) {
            std::hash<std::string> hasher;

            std::size_t seed = 0x2D03CCAD;
            seed ^= (seed << 6) + (seed >> 2) + 0x3EEE27F1 + hasher(obj.Id);
            seed ^= (seed << 6) + (seed >> 2) + 0x18B109F5 + hasher(obj.LastName);
            seed ^= (seed << 6) + (seed >> 2) + 0x3215BAE4 + hasher(obj.FirstName);
            seed ^= (seed << 6) + (seed >> 2) + 0x4AF2B1D3 + hasher(obj.Email);
            seed ^= (seed << 6) + (seed >> 2) + 0x3E1DBBC1 + hasher(obj.Phone);
            seed ^= (seed << 6) + (seed >> 2) + 0x6ED35753 + hasher(obj.Login);
            seed ^= (seed << 6) + (seed >> 2) + 0x65533FFB + hasher(obj.PasswordHash);
            seed ^= (seed << 6) + (seed >> 2) + 0x243A8F37 + hasher(obj.CreatedAt);
            return seed;
        }
    };

    inline const std::string SECRET_KEY = "secret";
    inline QHash<std::size_t, std::string> Tokens;

    inline std::string createToken(const User& usr) {
        if (Tokens.contains(hash_value(usr))) {
            return Tokens[hash_value(usr)];
        }

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

        Tokens.insert(hash_value(usr), token);
        return token;
    }
}

