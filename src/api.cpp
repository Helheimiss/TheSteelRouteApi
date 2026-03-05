#include "api.hpp"

#include "Data.hpp"

#include "Token.hpp"
#include "User.hpp"

#include "Order.hpp"
#include "Utils.hpp"

void api::orders::create(const drogon::HttpRequestPtr &req, HttpResponseCallback &&callback,
                         std::string &&FromAddress, std::string &&ToAddress, int TravelTimeMinutes, double DistanceKm,
                         std::string &&TravelDate, std::string &&TravelTime, int PassengerCount, std::string &&token) const {
    if (!Token::verifyToken(token)) {
        auto resp = Utils::makeErrorJson("bad token");
        resp->setStatusCode(drogon::HttpStatusCode::k401Unauthorized);
        callback(resp);
        return;
    }


    Order order;
    auto decode = jwt::decode(token);
    int id = stoi(decode.get_subject());

    order.Id = id;
    order.FromAddress = FromAddress;
    order.ToAddress = ToAddress;
    order.TravelTimeMinutes = TravelTimeMinutes;
    order.DistanceKm = DistanceKm;
    order.TravelDate = TravelDate;
    order.TravelTime = TravelTime;
    order.PassengerCount = PassengerCount;

    auto errorOptional = Order::createOrderForUserId(id, order);
    if (errorOptional) {
        auto resp = Utils::makeErrorJson(*errorOptional);
        resp->setStatusCode(drogon::HttpStatusCode::k400BadRequest);
        callback(resp);
        return;
    }


    Json::Value result;
    result["status"] = "Pending confirmation";

    auto resp = drogon::HttpResponse::newHttpJsonResponse(result);
    callback(resp);
}

void api::orders::getAll(const drogon::HttpRequestPtr &req, HttpResponseCallback &&callback,
    std::string &&token) const {
    if (!Token::verifyToken(token)) {
        auto resp = Utils::makeErrorJson("bad token");
        resp->setStatusCode(drogon::HttpStatusCode::k401Unauthorized);
        callback(resp);
        return;
    }

    auto decoded = jwt::decode(token);
    auto Id = stoi(decoded.get_subject());

    auto ordersVariant = Order::getAllOrderByUserId(Id);

    if (std::holds_alternative<std::string>(ordersVariant)) {
        auto resp = Utils::makeErrorJson(std::get<std::string>(ordersVariant));
        resp->setStatusCode(drogon::HttpStatusCode::k400BadRequest);
        callback(resp);
        return;
    }

    auto orders = std::get<std::vector<Order>>(ordersVariant);
    Json::Value ordersJson;
    ordersJson["count"] = orders.size();
    ordersJson["orders"] = Json::arrayValue;

    for (const auto & order : orders) {
        Json::Value orderJson;
        orderJson["Id"] = order.Id;
        orderJson["UserId"] = order.UserId;
        orderJson["FromAddress"] = order.FromAddress;
        orderJson["ToAddress"] = order.ToAddress;
        orderJson["TravelTimeMinutes"] = order.TravelTimeMinutes;
        orderJson["DistanceKm"] = order.DistanceKm;
        orderJson["TravelDate"] = order.TravelDate;
        orderJson["TravelTime"] = order.TravelTime;
        orderJson["PassengerCount"] = order.PassengerCount;
        orderJson["Status"] = order.Status;
        orderJson["BusId"] = order.BusId;
        orderJson["DriverId"] = order.DriverId;
        orderJson["CreatedAt"] = order.CreatedAt;

        ordersJson["orders"].append(orderJson);
    }


    auto resp = drogon::HttpResponse::newHttpJsonResponse(ordersJson);
    callback(resp);
}

void api::user::login(const drogon::HttpRequestPtr &req, HttpResponseCallback &&callback, std::string &&login, std::string &&password) const {

    if (const auto usr = User::findUser(login, password)) {
        auto resp = drogon::HttpResponse::newHttpResponse(drogon::HttpStatusCode::k200OK, drogon::ContentType::CT_TEXT_PLAIN);
        resp->setBody(Token::createToken(*usr));
        callback(resp);
        return;
    }

    auto resp = Utils::makeErrorJson("invalid login or password");
    resp->setStatusCode(drogon::HttpStatusCode::k404NotFound);

    callback(resp);
}

void api::user::getAll(const drogon::HttpRequestPtr &req, HttpResponseCallback &&callback, std::string &&token) const {
    if (!Token::verifyToken(token)) {
        auto resp = Utils::makeErrorJson("bad token");
        resp->setStatusCode(drogon::HttpStatusCode::k401Unauthorized);
        callback(resp);
        return;
    }


    auto decoded = jwt::decode(token);
    auto role = decoded.get_payload_claim("Role").as_string();

    if (role != "Admin") {
        auto resp = Utils::makeErrorJson("not allowed");
        resp->setStatusCode(drogon::HttpStatusCode::k405MethodNotAllowed);
        callback(resp);
        return;
    }


    auto usersVariant = User::getAllUsers();
    if (std::holds_alternative<std::string>(usersVariant)) {
        auto resp = Utils::makeErrorJson(std::get<std::string>(usersVariant));
        resp->setStatusCode(drogon::HttpStatusCode::k400BadRequest);
        callback(resp);
        return;
    }

    auto users = std::get<std::vector<User>>(usersVariant);
    Json::Value usersJson;
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
