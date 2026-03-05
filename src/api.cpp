#include "api.hpp"

#include "Data.hpp"

#include "Token.hpp"
#include "User.hpp"

#include <QDateTime>

void api::orders::create(const drogon::HttpRequestPtr &req, HttpResponseCallback &&callback,
                         std::string &&FromAddress, std::string &&ToAddress, int TravelTimeMinutes, double DistanceKm,
                         std::string &&TravelDate, std::string &&TravelTime, int PassengerCount, std::string &&token) const {

    if (!Token::verifyToken(token)) {
        auto resp = drogon::HttpResponse::newHttpJsonResponse(Json::Value());
        resp->setStatusCode(drogon::HttpStatusCode::k401Unauthorized);
        callback(resp);
        return;
    }
    Json::Value result;
    result["status"] = "Pending confirmation";

    auto query = DATA::DataBase.sqlQuery();
    query.prepare("INSERT INTO Orders (UserId, FromAddress, ToAddress, TravelTimeMinutes, DistanceKm, TravelDate, TravelTime, PassengerCount, Status) "
                  "VALUES "
                  "(?, ?, ?, ?, ?, ?, ?, ?, 'Pending confirmation')");

    auto decode = jwt::decode(token);


    auto qUserId = stoi(decode.get_subject());
    auto qFromAddress = QString::fromStdString(FromAddress);
    auto qToAddress = QString::fromStdString(ToAddress);
    auto qTravelTimeMinutes = TravelTimeMinutes;
    auto qDistanceKm = DistanceKm;
    auto qTravelDate = QString::fromStdString(TravelDate);
    auto qTravelTime = QString::fromStdString(TravelTime);
    auto qPassengerCount = PassengerCount;


    query.bindValue(0, qUserId);
    query.bindValue(1, qFromAddress);
    query.bindValue(2, qToAddress);
    query.bindValue(3, qTravelTimeMinutes);
    query.bindValue(4, qDistanceKm);
    query.bindValue(5, qTravelDate);
    query.bindValue(6, qTravelTime);
    query.bindValue(7, qPassengerCount);

    auto re = query.exec();
    if (!re) throw std::runtime_error(query.lastError().text().toStdString());

    auto resp = drogon::HttpResponse::newHttpJsonResponse(result);
    callback(resp);
}

void api::orders::getAll(const drogon::HttpRequestPtr &req, HttpResponseCallback &&callback,
    std::string &&token) const {
    Json::Value ordersJson;

    auto decoded = jwt::decode(token);

    if (!Token::verifyToken(token)) {
        auto resp = drogon::HttpResponse::newHttpJsonResponse(ordersJson);
        resp->setStatusCode(drogon::HttpStatusCode::k401Unauthorized);
        callback(resp);
        return;
    }

    auto Id = stoi(decoded.get_subject());
    auto query = DATA::DataBase.sqlQuery();

    query.prepare("SELECT Id ,UserId ,FromAddress ,ToAddress ,TravelTimeMinutes ,DistanceKm ,TravelDate ,TravelTime ,PassengerCount ,Status ,BusId ,DriverId, CreatedAt "
                  "FROM Orders WHERE UserId = ?;");
    query.bindValue(0, Id);

    if (!query.exec())
        throw std::runtime_error(query.lastError().text().toStdString());

    ordersJson["count"] = query.numRowsAffected();
    ordersJson["orders"] = Json::arrayValue;

    while (query.next()) {
        Json::Value orderJson;
        orderJson["Id"] = query.value(0).toString().toStdString();
        orderJson["UserId"] = query.value(1).toString().toStdString();
        orderJson["FromAddress"] = query.value(2).toString().toStdString();
        orderJson["ToAddress"] = query.value(3).toString().toStdString();
        orderJson["TravelTimeMinutes"] = query.value(4).toString().toStdString();
        orderJson["DistanceKm"] = query.value(5).toString().toStdString();
        orderJson["TravelDate"] = query.value(6).toString().toStdString();
        orderJson["TravelTime"] = query.value(7).toString().toStdString();
        orderJson["PassengerCount"] = query.value(8).toString().toStdString();
        orderJson["Status"] = query.value(9).toString().toStdString();
        orderJson["BusId"] = query.value(10).toString().toStdString();
        orderJson["DriverId"] = query.value(11).toString().toStdString();
        orderJson["CreatedAt"] = query.value(12).toString().toStdString();

        ordersJson["orders"].append(orderJson);
    }

    auto resp = drogon::HttpResponse::newHttpJsonResponse(ordersJson);
    callback(resp);
}

void api::user::login(const drogon::HttpRequestPtr &req, HttpResponseCallback &&callback, std::string &&login, std::string &&password) const {
    auto resp = drogon::HttpResponse::newHttpResponse(drogon::HttpStatusCode::k200OK, drogon::ContentType::CT_TEXT_PLAIN);

    auto usr = User::findUser(login, password);

    if (usr) {
        resp->setBody(Token::createToken(*usr));
    }
    else {
        resp->setStatusCode(drogon::HttpStatusCode::k404NotFound);
        resp->setBody("invalid login or password");
    }


    callback(resp);
}

void api::user::getAll(const drogon::HttpRequestPtr &req, HttpResponseCallback &&callback, std::string &&token) const {
    Json::Value usersJson;

    auto decoded = jwt::decode(token);
    auto role = decoded.get_payload_claim("Role").as_string();

    if (role != "Admin") {
        auto resp = drogon::HttpResponse::newHttpJsonResponse(usersJson);
        resp->setStatusCode(drogon::HttpStatusCode::k403Forbidden);
        callback(resp);
        return;
    }

    if (!Token::verifyToken(token)) {
        auto resp = drogon::HttpResponse::newHttpJsonResponse(usersJson);
        resp->setStatusCode(drogon::HttpStatusCode::k401Unauthorized);
        callback(resp);
        return;
    }

    auto users = User::getAllUsers();
    usersJson["count"] = static_cast<int>(users.size());
    usersJson["users"] = Json::arrayValue;

    for (const auto & user : users) {
        Json::Value userJson;
        userJson["Id"] = user.Id;
        userJson["LastName"] = user.LastName;
        userJson["FirstName"] = user.FirstName;
        userJson["Email"] = user.Email;
        userJson["Phone"] = user.Phone;
        userJson["Login"] = user.Login;
        userJson["PasswordHash"] = user.PasswordHash;
        userJson["Role"] = user.Role;
        userJson["CreatedAt"] = user.CreatedAt;
        usersJson["users"].append(userJson);
    }


    auto resp = drogon::HttpResponse::newHttpJsonResponse(usersJson);
    callback(resp);
}
