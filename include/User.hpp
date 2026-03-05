#pragma once

#include "Data.hpp"

#include <string>
#include <QCryptographicHash>

class User {
public:
    User(const std::string &id, const std::string &last_name, const std::string &first_name, const std::string &email,
        const std::string &phone, const std::string &login, const std::string &password_hash, const std::string &role,
        const std::string &created_at)
        : Id(id),
          LastName(last_name),
          FirstName(first_name),
          Email(email),
          Phone(phone),
          Login(login),
          PasswordHash(password_hash),
          Role(role),
          CreatedAt(created_at) {
    }

    static std::optional<User> findUser(const std::string &login, const std::string &password) {
        auto query = DATA::DataBase.sqlQuery();
        query.prepare("SELECT Id, LastName, FirstName, Email, Phone, Login, PasswordHash, Role, CreatedAt FROM Users "
                      "WHERE Login = ? AND PasswordHash = ?;");


        QString qLogin = login.c_str();
        QString qHashPassword = QCryptographicHash::hash(password, QCryptographicHash::Sha256).toHex().toUpper();

        query.bindValue(0, qLogin);
        query.bindValue(1, qHashPassword);


        if (query.exec() && query.next()) {
            return User(
            query.value(0).toString().toStdString(),
            query.value(1).toString().toStdString(),
            query.value(2).toString().toStdString(),
            query.value(3).toString().toStdString(),
            query.value(4).toString().toStdString(),
            query.value(5).toString().toStdString(),
            query.value(6).toString().toStdString(),
            query.value(7).toString().toStdString(),
            query.value(8).toString().toStdString());
        }

        return std::nullopt;
    }

    static std::variant<std::string, std::vector<User>> getAllUsers() {
        std::vector<User> users;

        auto query = DATA::DataBase.sqlQuery();
        query.prepare("SELECT Id, LastName, FirstName, Email, Phone, Login, PasswordHash, Role, CreatedAt FROM Users;");

        if (!query.exec())
            return query.lastError().text().toStdString();

        users.reserve(query.numRowsAffected());

        while (query.next()) {
            users.emplace_back(
            query.value(0).toString().toStdString(),
            query.value(1).toString().toStdString(),
            query.value(2).toString().toStdString(),
            query.value(3).toString().toStdString(),
            query.value(4).toString().toStdString(),
            query.value(5).toString().toStdString(),
            query.value(6).toString().toStdString(),
            query.value(7).toString().toStdString(),
            query.value(8).toString().toStdString()
            );

        }

        return users;
    }

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


    std::string Id;
    std::string LastName;
    std::string FirstName;
    std::string Email;
    std::string Phone;
    std::string Login;
    std::string PasswordHash;
    std::string Role;
    std::string CreatedAt;
};