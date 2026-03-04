#pragma once

#include <string>

#include "Database.hpp"
#include "jwt-cpp/jwt.h"


namespace DATA {
    inline TheSteelRouteApi::Database DataBase;

    inline const std::string SECRET_KEY = "secret";
    inline QHash<std::size_t, std::string> Tokens;


}

