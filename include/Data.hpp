#pragma once

#include <string>

#include "Database.hpp"
#include "jwt-cpp/jwt.h"


namespace Data {
    inline TheSteelRouteApi::Database DataBase;

    inline const std::string SECRET_KEY = "secret";
    inline QHash<std::size_t, std::string> Tokens;


}

