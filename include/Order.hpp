#pragma once

#include <string>
#include <variant>
#include <vector>

#include "Data.hpp"

class Order {
public:
    Order(int id, int user_id, const std::string &from_address, const std::string &to_address, int travel_time_minutes,
        double distance_km, const std::string &travel_date, const std::string &travel_time, int passenger_count,
        const std::string &status, const std::string &bus_id, const std::string &driver_id,
        const std::string &created_at)
        : Id(id),
          UserId(user_id),
          FromAddress(from_address),
          ToAddress(to_address),
          TravelTimeMinutes(travel_time_minutes),
          DistanceKm(distance_km),
          TravelDate(travel_date),
          TravelTime(travel_time),
          PassengerCount(passenger_count),
          Status(status),
          BusId(bus_id),
          DriverId(driver_id),
          CreatedAt(created_at) {
    }

    Order() = default;

    static std::optional<std::string> createOrderForUserId(int id, const Order &order) {
        auto query = Data::DataBase.sqlQuery();
        query.prepare("INSERT INTO Orders (UserId, FromAddress, ToAddress, TravelTimeMinutes, DistanceKm, TravelDate, TravelTime, PassengerCount, Status) "
                      "VALUES "
                      "(?, ?, ?, ?, ?, ?, ?, ?, 'Pending confirmation')");


        auto qUserId = id;
        auto qFromAddress = QString::fromStdString(order.FromAddress);
        auto qToAddress = QString::fromStdString(order.ToAddress);
        auto qTravelTimeMinutes = order.TravelTimeMinutes;
        auto qDistanceKm = order.DistanceKm;
        auto qTravelDate = QString::fromStdString(order.TravelDate);
        auto qTravelTime = QString::fromStdString(order.TravelTime);
        auto qPassengerCount = order.PassengerCount;


        query.bindValue(0, qUserId);
        query.bindValue(1, qFromAddress);
        query.bindValue(2, qToAddress);
        query.bindValue(3, qTravelTimeMinutes);
        query.bindValue(4, qDistanceKm);
        query.bindValue(5, qTravelDate);
        query.bindValue(6, qTravelTime);
        query.bindValue(7, qPassengerCount);


        if (!query.exec())
            return query.lastError().text().toStdString();


        return std::nullopt;
    };

    static std::variant<std::string, std::vector<Order>> getAllOrderByUserId(int id) {
        auto query = Data::DataBase.sqlQuery();
        query.prepare("SELECT Id ,UserId ,FromAddress ,ToAddress ,TravelTimeMinutes ,DistanceKm ,TravelDate ,TravelTime ,PassengerCount ,Status ,BusId ,DriverId, CreatedAt "
                      "FROM Orders WHERE UserId = ?;");
        query.bindValue(0, id);

        if (!query.exec())
            return query.lastError().text().toStdString();


        std::vector<Order> orders;
        orders.reserve(query.numRowsAffected());

        while (query.next()) {
        orders.emplace_back(
            query.value(0).toString().toInt(),
            query.value(1).toString().toInt(),
            query.value(2).toString().toStdString(),
            query.value(3).toString().toStdString(),
            query.value(4).toString().toInt(),
            query.value(5).toString().toDouble(),
            query.value(6).toString().toStdString(),
            query.value(7).toString().toStdString(),
            query.value(8).toString().toInt(),
            query.value(9).toString().toStdString(),
            query.value(10).toString().toStdString(),
            query.value(11).toString().toStdString(),
            query.value(12).toString().toStdString());
        }

        return orders;
    }

    int Id;
    int UserId;
    std::string FromAddress;
    std::string ToAddress;
    int TravelTimeMinutes;
    double DistanceKm;
    std::string TravelDate;
    std::string TravelTime;
    int PassengerCount;
    std::string Status;
    std::string BusId;
    std::string DriverId;
    std::string CreatedAt;
};
