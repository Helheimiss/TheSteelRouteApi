-- Create database (if needed)
--CREATE DATABASE TheSteelRouteDBv2;
--GO

USE TheSteelRouteDBv2;
GO

-- Users table (unauthorized/authorized)
CREATE TABLE Users (
    Id INT PRIMARY KEY IDENTITY(1,1),
    LastName NVARCHAR(100) NOT NULL,
    FirstName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(255) UNIQUE NOT NULL,
    Phone NVARCHAR(20),
    Login NVARCHAR(100) UNIQUE NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- Drivers table
CREATE TABLE Drivers (
    Id INT PRIMARY KEY IDENTITY(1,1),
    FullName NVARCHAR(200) NOT NULL,
    LicenseNumber NVARCHAR(50) UNIQUE NOT NULL,
    Phone NVARCHAR(20),
    IsAvailable BIT DEFAULT 1
);

-- Buses table
CREATE TABLE Buses (
    Id INT PRIMARY KEY IDENTITY(1,1),
    PlateNumber NVARCHAR(20) UNIQUE NOT NULL,
    Model NVARCHAR(100),
    Capacity INT NOT NULL,
    IsAvailable BIT DEFAULT 1
);

-- Orders table
CREATE TABLE Orders (
    Id INT PRIMARY KEY IDENTITY(1,1),
    UserId INT NOT NULL FOREIGN KEY REFERENCES Users(Id),
    FromAddress NVARCHAR(500) NOT NULL,
    ToAddress NVARCHAR(500) NOT NULL,
    TravelTimeMinutes INT NOT NULL,
    DistanceKm DECIMAL(5,2) NOT NULL,
    TravelDate DATE NOT NULL,
    TravelTime TIME NOT NULL,
    PassengerCount INT NOT NULL,
    Status NVARCHAR(50) DEFAULT 'Pending confirmation',
    BusId INT NULL FOREIGN KEY REFERENCES Buses(Id),
    DriverId INT NULL FOREIGN KEY REFERENCES Drivers(Id),
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT CK_PassengerCount CHECK (PassengerCount > 0)
);

-- Payments table
CREATE TABLE Payments (
    Id INT PRIMARY KEY IDENTITY(1,1),
    OrderId INT NOT NULL FOREIGN KEY REFERENCES Orders(Id),
    Amount DECIMAL(10,2) NOT NULL,
    CardLastFour CHAR(4),
    ConfirmationCode CHAR(4),
    IsConfirmed BIT DEFAULT 0,
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- Insert test data
INSERT INTO Users (LastName, FirstName, Email, Phone, Login, PasswordHash)
VALUES 
('Ivanov', 'Ivan', 'ivanov@mail.ru', '+79001234567', 'ivanov_i', '03AC674216F3E15C761EE1A5E255F067953623C8B388B4459E13F978D7C846F4'),
('Petrov', 'Petr', 'petrov@mail.ru', '+79007654321', 'petrov_p', '03AC674216F3E15C761EE1A5E255F067953623C8B388B4459E13F978D7C846F4');

INSERT INTO Drivers (FullName, LicenseNumber, Phone, IsAvailable)
VALUES 
('Sidorov Alexey Ivanovich', '78AB123456', '+79111234567', 1),
('Kozlov Dmitry Sergeevich', '78CD654321', '+79117654321', 1);

INSERT INTO Buses (PlateNumber, Model, Capacity, IsAvailable)
VALUES 
('A123BB178', 'MAZ-103', 40, 1),
('B456EE178', 'LIAZ-5256', 45, 1);

INSERT INTO Orders (UserId, FromAddress, ToAddress, TravelTimeMinutes, DistanceKm, TravelDate, TravelTime, PassengerCount, Status)
VALUES 
(1, 'St. Petersburg, Salova str., 63', 'Pushkinsky district, Catherine Palace', 41, 21.9, '2026-03-10', '10:00', 30, 'Pending confirmation');

INSERT INTO Payments (OrderId, Amount, CardLastFour, ConfirmationCode, IsConfirmed)
VALUES 
(1, 3500.00, '1234', '0000', 1);