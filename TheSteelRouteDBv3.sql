-- Создание базы данных (если нужно)
-- CREATE DATABASE TheSteelRouteDBv3;
-- GO

USE TheSteelRouteDBv3;
GO

-- Таблица пользователей (с полем роли)
CREATE TABLE Users (
    Id INT PRIMARY KEY IDENTITY(1,1),
    LastName NVARCHAR(100) NOT NULL,
    FirstName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(255) UNIQUE NOT NULL,
    Phone NVARCHAR(20),
    Login NVARCHAR(100) UNIQUE NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL,
    Role NVARCHAR(50) DEFAULT 'User', -- Роль пользователя
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO

-- Таблица водителей
CREATE TABLE Drivers (
    Id INT PRIMARY KEY IDENTITY(1,1),
    FullName NVARCHAR(200) NOT NULL,
    LicenseNumber NVARCHAR(50) UNIQUE NOT NULL,
    Phone NVARCHAR(20),
    IsAvailable BIT DEFAULT 1
);
GO

-- Таблица автобусов
CREATE TABLE Buses (
    Id INT PRIMARY KEY IDENTITY(1,1),
    PlateNumber NVARCHAR(20) UNIQUE NOT NULL,
    Model NVARCHAR(100),
    Capacity INT NOT NULL,
    IsAvailable BIT DEFAULT 1
);
GO

-- Таблица заказов
CREATE TABLE Orders (
    Id INT PRIMARY KEY IDENTITY(1,1),
    UserId INT NOT NULL,
    FromAddress NVARCHAR(500) NOT NULL,
    ToAddress NVARCHAR(500) NOT NULL,
    TravelTimeMinutes INT NOT NULL,
    DistanceKm DECIMAL(5,2) NOT NULL,
    TravelDate DATE NOT NULL,
    TravelTime TIME NOT NULL,
    PassengerCount INT NOT NULL,
    Status NVARCHAR(50) DEFAULT 'Pending confirmation',
    BusId INT NULL,
    DriverId INT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Orders_Users FOREIGN KEY (UserId) REFERENCES Users(Id),
    CONSTRAINT FK_Orders_Buses FOREIGN KEY (BusId) REFERENCES Buses(Id),
    CONSTRAINT FK_Orders_Drivers FOREIGN KEY (DriverId) REFERENCES Drivers(Id),
    CONSTRAINT CK_PassengerCount CHECK (PassengerCount > 0)
);
GO

-- Таблица платежей (доходы)
CREATE TABLE Payments (
    Id INT PRIMARY KEY IDENTITY(1,1),
    OrderId INT NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    CardLastFour CHAR(4),
    ConfirmationCode CHAR(4),
    IsConfirmed BIT DEFAULT 0,
    CreatedAt DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Payments_Orders FOREIGN KEY (OrderId) REFERENCES Orders(Id)
);
GO

-- Таблица расходов
CREATE TABLE Expenses (
    Id INT PRIMARY KEY IDENTITY(1,1),
    ExpenseDate DATE NOT NULL,
    Category NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500),
    Amount DECIMAL(10,2) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO

-- ================ ВСТАВКА ТЕСТОВЫХ ДАННЫХ ================

-- Пользователи (с ролями)
INSERT INTO Users (LastName, FirstName, Email, Phone, Login, PasswordHash, Role)
VALUES 
('admin', 'admin', 'admin@TheSteelRoute.ru', 'admin', 'admin', '03AC674216F3E15C761EE1A5E255F067953623C8B388B4459E13F978D7C846F4', 'Admin'),
('Иванов', 'Иван', 'ivanov@mail.ru', '+79001234567', 'ivanov_i', '03AC674216F3E15C761EE1A5E255F067953623C8B388B4459E13F978D7C846F4', 'User'),
('Петров', 'Петр', 'petrov@mail.ru', '+79007654321', 'petrov_p', '03AC674216F3E15C761EE1A5E255F067953623C8B388B4459E13F978D7C846F4', 'User'),
('Соколова', 'Елена', 'sokolova@steelroute.ru', '+79001112233', 'sokolova_e', '03AC674216F3E15C761EE1A5E255F067953623C8B388B4459E13F978D7C846F4', 'Accountant'),
('Морозов', 'Андрей', 'morozov@steelroute.ru', '+79002223344', 'morozov_a', '03AC674216F3E15C761EE1A5E255F067953623C8B388B4459E13F978D7C846F4', 'Director');
GO

-- Водители
INSERT INTO Drivers (FullName, LicenseNumber, Phone, IsAvailable)
VALUES 
('Сидоров Алексей Иванович', '78AB123456', '+79111234567', 1),
('Козлов Дмитрий Сергеевич', '78CD654321', '+79117654321', 1);
GO

-- Автобусы
INSERT INTO Buses (PlateNumber, Model, Capacity, IsAvailable)
VALUES 
('A123BB178', 'МАЗ-103', 40, 1),
('B456EE178', 'ЛИАЗ-5256', 45, 1);
GO

-- Заказы
INSERT INTO Orders (UserId, FromAddress, ToAddress, TravelTimeMinutes, DistanceKm, TravelDate, TravelTime, PassengerCount, Status)
VALUES 
(1, 'Санкт-Петербург, ул. Салова, 63', 'Пушкинский район, Екатерининский дворец', 41, 21.9, '2026-03-10', '10:00', 30, 'Pending confirmation'),
(2, 'Санкт-Петербург, Московский пр., 100', 'Петергоф, Большой дворец', 50, 29.5, '2026-04-15', '09:30', 35, 'Confirmed'),
(1, 'Санкт-Петербург, Лиговский пр., 50', 'Царское Село', 45, 24.0, '2026-05-20', '11:00', 20, 'Completed');
GO

-- Платежи (доходы)
INSERT INTO Payments (OrderId, Amount, CardLastFour, ConfirmationCode, IsConfirmed)
VALUES 
(1, 3500.00, '1234', '0000', 1),
(2, 4200.00, '5678', '1111', 1),
(3, 2800.00, '9012', '2222', 1);
GO

-- Расходы
INSERT INTO Expenses (ExpenseDate, Category, Description, Amount)
VALUES 
('2026-03-15', 'Топливо', 'Заправка автобуса A123BB178', 4500.00),
('2026-03-20', 'Зарплата', 'Зарплата водителя Сидорова А.И.', 35000.00),
('2026-04-10', 'Обслуживание', 'Ремонт автобуса ЛИАЗ-5256', 8200.00),
('2026-04-25', 'Топливо', 'Заправка автобуса B456EE178', 4800.00),
('2026-05-05', 'Зарплата', 'Зарплата водителя Козлова Д.С.', 35000.00),
('2026-05-18', 'Офис', 'Аренда офиса', 15000.00);
GO

-- Назначение водителей и автобусов для заказов
UPDATE Orders SET BusId = 1, DriverId = 1 WHERE Id = 1;
UPDATE Orders SET BusId = 2, DriverId = 2 WHERE Id = 2;
UPDATE Orders SET BusId = 1, DriverId = 1 WHERE Id = 3;
GO

-- ================ ПРОВЕРОЧНЫЕ ЗАПРОСЫ ================

-- Проверка пользователей с ролями
SELECT Id, LastName, FirstName, Email, Role
FROM Users
ORDER BY Role, LastName;
GO

-- Проверка заказов с назначенными водителями и автобусами
SELECT o.Id, o.FromAddress, o.ToAddress, o.TravelDate, 
       d.FullName as Driver, b.PlateNumber as Bus, o.Status
FROM Orders o
LEFT JOIN Drivers d ON o.DriverId = d.Id
LEFT JOIN Buses b ON o.BusId = b.Id;
GO

-- Проверка доходов и расходов
SELECT 'Доходы' as Type, SUM(Amount) as Total FROM Payments WHERE IsConfirmed = 1
UNION ALL
SELECT 'Расходы' as Type, SUM(Amount) as Total FROM Expenses;
GO

-- Отчёт о доходах за март-май 2026
SELECT 
    FORMAT(p.CreatedAt, 'dd.MM.yyyy') as Date,
    'Доход' as OperationType,
    o.FromAddress + ' -> ' + o.ToAddress as Description,
    p.Amount as Amount
FROM Payments p
JOIN Orders o ON p.OrderId = o.Id
WHERE o.TravelDate BETWEEN '2026-03-01' AND '2026-05-31'
UNION ALL
SELECT 
    FORMAT(ExpenseDate, 'dd.MM.yyyy') as Date,
    'Расход' as OperationType,
    Category + ': ' + ISNULL(Description, '') as Description,
    -Amount as Amount
FROM Expenses
WHERE ExpenseDate BETWEEN '2026-03-01' AND '2026-05-31'
ORDER BY Date;
GO

-- Итоговый отчёт с чистой прибылью/убытками
SELECT 
    SUM(CASE WHEN Type = 'Доход' THEN Total ELSE 0 END) as TotalIncome,
    SUM(CASE WHEN Type = 'Расход' THEN Total ELSE 0 END) as TotalExpenses,
    SUM(CASE WHEN Type = 'Доход' THEN Total ELSE -Total END) as NetProfit
FROM (
    SELECT 'Доход' as Type, SUM(Amount) as Total
    FROM Payments p
    JOIN Orders o ON p.OrderId = o.Id
    WHERE o.TravelDate BETWEEN '2026-03-01' AND '2026-05-31'
    UNION ALL
    SELECT 'Расход' as Type, SUM(Amount) as Total
    FROM Expenses
    WHERE ExpenseDate BETWEEN '2026-03-01' AND '2026-05-31'
) as Finances;
GO