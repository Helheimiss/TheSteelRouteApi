-- Create database
--CREATE DATABASE SteelRouteDBv2;
--GO

USE SteelRouteDBv2;
GO

-- 1. Facilities directory
CREATE TABLE Facilities (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    Address NVARCHAR(200)
);

-- 2. Vehicles
CREATE TABLE Vehicles (
    Id INT PRIMARY KEY IDENTITY(1,1),
    StateNumber NVARCHAR(20) NOT NULL,
    VIN NVARCHAR(50) NOT NULL,
    Brand NVARCHAR(50) NOT NULL,
    Model NVARCHAR(50) NOT NULL,
    Year INT,
    Capacity DECIMAL(10,2),
    PassengerSeats INT,
    Status NVARCHAR(20) DEFAULT 'available',
    FacilityId INT,
    FOREIGN KEY (FacilityId) REFERENCES Facilities(Id)
);

-- 3. Drivers
CREATE TABLE Drivers (
    Id INT PRIMARY KEY IDENTITY(1,1),
    FullName NVARCHAR(100) NOT NULL,
    LicenseNumber NVARCHAR(50),
    LicenseExpiryDate DATE,
    MedicalCertExpiryDate DATE,
    Phone NVARCHAR(20)
);

-- 4. Clients
CREATE TABLE Clients (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Name NVARCHAR(100) NOT NULL,
    IsCompany BIT DEFAULT 0,
    Phone NVARCHAR(20),
    Email NVARCHAR(50)
);

-- 5. Services (new table for service types)
CREATE TABLE Services (
    Id INT PRIMARY KEY IDENTITY(1,1),
    ServiceName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500),
    BasePrice DECIMAL(10,2),
    PricePerKm DECIMAL(10,2),  -- Увеличил точность
    PricePerHour DECIMAL(10,2)  -- Увеличил точность
);

-- 6. Orders (modified)
CREATE TABLE Orders (
    Id INT PRIMARY KEY IDENTITY(1,1),
    ClientId INT NOT NULL,
    ServiceId INT NOT NULL,
    OrderDate DATETIME DEFAULT GETDATE(),
    TripDate DATETIME NOT NULL,
    RouteFrom NVARCHAR(200) NOT NULL,
    RouteTo NVARCHAR(200) NOT NULL,
    Distance DECIMAL(10,2),
    DurationMinutes INT,
    PassengerCount INT NOT NULL,
    TotalPrice DECIMAL(10,2),
    Status NVARCHAR(50) DEFAULT 'pending_payment',
    PaymentStatus NVARCHAR(50) DEFAULT 'pending',
    ConfirmationCode NVARCHAR(10),
    VehicleId INT,
    DriverId INT,
    Notes NVARCHAR(500),
    FOREIGN KEY (ClientId) REFERENCES Clients(Id),
    FOREIGN KEY (ServiceId) REFERENCES Services(Id),
    FOREIGN KEY (VehicleId) REFERENCES Vehicles(Id),
    FOREIGN KEY (DriverId) REFERENCES Drivers(Id)
);

-- 7. Trips (modified)
CREATE TABLE Trips (
    Id INT PRIMARY KEY IDENTITY(1,1),
    OrderId INT NOT NULL UNIQUE,
    VehicleId INT NOT NULL,
    DriverId INT NOT NULL,
    ActualStartTime DATETIME,
    ActualEndTime DATETIME,
    ActualMileage INT,
    Status NVARCHAR(50) DEFAULT 'scheduled',
    FOREIGN KEY (OrderId) REFERENCES Orders(Id),
    FOREIGN KEY (VehicleId) REFERENCES Vehicles(Id),
    FOREIGN KEY (DriverId) REFERENCES Drivers(Id)
);

-- 8. Maintenance types directory
CREATE TABLE MaintenanceTypes (
    Id INT PRIMARY KEY IDENTITY(1,1),
    WorkType NVARCHAR(100) NOT NULL
);

-- 9. Maintenance log
CREATE TABLE MaintenanceLog (
    Id INT PRIMARY KEY IDENTITY(1,1),
    VehicleId INT NOT NULL,
    MaintenanceDate DATE NOT NULL,
    MaintenanceTypeId INT NOT NULL,
    Mileage INT,
    MechanicName NVARCHAR(100),
    Notes NVARCHAR(500),
    FOREIGN KEY (VehicleId) REFERENCES Vehicles(Id),
    FOREIGN KEY (MaintenanceTypeId) REFERENCES MaintenanceTypes(Id)
);

-- 10. Users and roles
CREATE TABLE Roles (
    Id INT PRIMARY KEY IDENTITY(1,1),
    RoleName NVARCHAR(50) NOT NULL
);

CREATE TABLE Users (
    Id INT PRIMARY KEY IDENTITY(1,1),
    ClientId INT,
    Username NVARCHAR(50) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(256) NOT NULL,
    TempPassword BIT DEFAULT 0,
    RoleId INT NOT NULL,
    LastPasswordChange DATETIME,
    FOREIGN KEY (RoleId) REFERENCES Roles(Id),
    FOREIGN KEY (ClientId) REFERENCES Clients(Id)
);

-- 11. Payments (new table)
CREATE TABLE Payments (
    Id INT PRIMARY KEY IDENTITY(1,1),
    OrderId INT NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    PaymentDate DATETIME DEFAULT GETDATE(),
    CardNumber NVARCHAR(50),
    CardHolderName NVARCHAR(100),
    BankCode NVARCHAR(10),
    Status NVARCHAR(50) DEFAULT 'pending',
    FOREIGN KEY (OrderId) REFERENCES Orders(Id)
);

-- 12. Password reset requests (new table)
CREATE TABLE PasswordResetRequests (
    Id INT PRIMARY KEY IDENTITY(1,1),
    UserId INT NOT NULL,
    RequestDate DATETIME DEFAULT GETDATE(),
    IsUsed BIT DEFAULT 0,
    FOREIGN KEY (UserId) REFERENCES Users(Id)
);
GO

-- =====================================================
-- FILLING TABLES WITH TEST DATA
-- =====================================================

-- 1. Facilities (3 branches)
INSERT INTO Facilities (Name, Address) VALUES 
('Central Branch', 'Moscow, Logisticheskaya St., 10'),
('Northern Branch', 'Saint Petersburg, Bolshoy Ave., 25'),
('Southern Branch', 'Krasnodar, Dalnyaya St., 7');

-- 2. Vehicles (33 vehicles)
INSERT INTO Vehicles (StateNumber, VIN, Brand, Model, Year, Capacity, PassengerSeats, Status, FacilityId) VALUES
-- Trucks (heavy)
('A123BC', 'XTA12345678901234', 'Scania', 'R500', 2021, 20.0, 2, 'available', 1),
('B456EN', 'XTA23456789012345', 'MAN', 'TGX', 2020, 22.0, 2, 'available', 1),
('C789NK', 'XTA34567890123456', 'Volvo', 'FH16', 2022, 25.0, 2, 'available', 1),
('K123MR', 'XTA45678901234567', 'Mercedes', 'Actros', 2021, 21.5, 2, 'available', 1),
('M456OR', 'XTA56789012345678', 'DAF', 'XF', 2019, 19.8, 2, 'available', 2),
('N789ST', 'XTA67890123456789', 'Scania', 'R450', 2023, 20.5, 2, 'available', 2),
('R123UH', 'XTA78901234567890', 'IVECO', 'Stralis', 2020, 21.0, 2, 'available', 3),

-- Gazelles (light trucks)
('T234AE', 'XTA89012345678901', 'GAZ', 'Gazelle NEXT', 2022, 1.5, 3, 'available', 1),
('U345VS', 'XTA90123456789012', 'GAZ', 'Gazelle Business', 2021, 1.5, 3, 'available', 1),
('F456EK', 'XTA01234567890123', 'GAZ', 'Gazelle Farmer', 2020, 1.3, 5, 'available', 2),
('H567MN', 'XTA12345098765432', 'GAZ', 'Gazelle NEXT', 2023, 1.5, 3, 'available', 2),
('C678OR', 'XTA23456109876543', 'GAZ', 'Gazelle Business', 2021, 1.5, 3, 'available', 3),

-- Minibuses (passenger)
('CH789PT', 'XTA34567210987654', 'Ford', 'Transit', 2022, NULL, 16, 'available', 1),
('SH890RS', 'XTA45678321098765', 'Mercedes', 'Sprinter', 2023, NULL, 20, 'available', 1),
('SCH901TU', 'XTA56789432109876', 'Volkswagen', 'Crafter', 2021, NULL, 18, 'available', 2),
('E012FH', 'XTA67890543210987', 'Peugeot', 'Boxer', 2020, NULL, 16, 'available', 3),
('YU123CCH', 'XTA78901654321098', 'Citroen', 'Jumper', 2022, NULL, 16, 'available', 2),
('YA234SHCH', 'XTA89012765432109', 'Renault', 'Master', 2021, NULL, 16, 'available', 1),

-- Additional vehicles
('A345YY', 'XTA90123876543210', 'Scania', 'R580', 2022, 22.5, 2, 'available', 3),
('B456EE', 'XTA01234987654321', 'MAN', 'TGX 18.640', 2023, 24.0, 2, 'available', 2),
('C567YYA', 'XTA12345098761234', 'Volvo', 'FH 500', 2021, 21.0, 2, 'available', 1),
('D678AB', 'XTA23456109872345', 'GAZ', 'Gazelle NEXT', 2022, 1.5, 3, 'available', 1),
('E789VG', 'XTA34567210983456', 'Ford', 'Transit', 2023, NULL, 16, 'available', 2),
('F890DE', 'XTA45678321094567', 'Mercedes', 'Sprinter', 2022, NULL, 20, 'available', 3),
('Z901JZ', 'XTA56789432105678', 'GAZ', 'Sobol', 2021, 1.0, 6, 'available', 1),
('I012IK', 'XTA67890543216789', 'UAZ', 'Profy', 2020, 1.5, 2, 'available', 2),
('K123LM', 'XTA78901654327890', 'Hyundai', 'HD78', 2022, 3.0, 3, 'available', 3),
('L234MN', 'XTA89012765438901', 'Isuzu', 'NQR71', 2021, 3.5, 3, 'available', 1),
('M345NO', 'XTA90123876549012', 'Scania', 'P360', 2020, 18.0, 2, 'available', 2),
('N456OP', 'XTA01234987650123', 'Mercedes', 'Atego', 2023, 8.0, 2, 'available', 3),
('O567PR', 'XTA12345098761245', 'Volvo', 'FL', 2022, 12.0, 2, 'available', 1);

-- 3. Drivers (20 drivers)
INSERT INTO Drivers (FullName, LicenseNumber, LicenseExpiryDate, MedicalCertExpiryDate, Phone) VALUES
('Ivan Ivanov', '77UR123456', '2026-05-15', '2025-06-20', '+7(903)123-45-67'),
('Petr Petrov', '78VS654321', '2025-11-30', '2025-12-10', '+7(916)234-56-78'),
('Alexey Sidorov', '77AB789012', '2027-03-22', '2026-04-15', '+7(925)345-67-89'),
('Dmitry Kozlov', '50KL345678', '2025-09-18', '2025-10-01', '+7(903)456-78-90'),
('Sergey Morozov', '78MN567890', '2026-12-25', '2026-11-30', '+7(916)567-89-01'),
('Andrey Volkov', '77OR678901', '2027-07-14', '2026-08-20', '+7(925)678-90-12'),
('Mikhail Zaytsev', '50PR789012', '2025-10-05', '2025-09-15', '+7(903)789-01-23'),
('Vitaly Sokolov', '78ST890123', '2026-04-27', '2026-05-30', '+7(916)890-12-34'),
('Igor Lebedev', '77UF901234', '2025-08-12', '2025-09-01', '+7(925)901-23-45'),
('Roman Pavlov', '50HC012345', '2027-01-19', '2026-12-25', '+7(903)012-34-56'),
('Artem Semenov', '78CHSH123456', '2026-06-23', '2026-07-15', '+7(916)123-45-67'),
('Maxim Egorov', '77EY234567', '2025-12-11', '2025-11-20', '+7(925)234-56-78'),
('Oleg Grigoriev', '50YYA345678', '2027-09-04', '2026-10-10', '+7(903)345-67-89'),
('Konstantin Andreev', '78YY456789', '2026-02-28', '2026-03-05', '+7(916)456-78-90'),
('Denis Fedorov', '77YT567890', '2025-07-16', '2025-08-01', '+7(925)567-89-01'),
('Nikolay Kuznetsov', '50AB678901', '2027-05-30', '2027-04-25', '+7(903)678-90-12'),
('Timur Novikov', '78VG789012', '2026-10-08', '2026-09-15', '+7(916)789-01-23'),
('Alexey Smirnov', '77DE890123', '2025-04-17', '2025-05-22', '+7(925)890-12-34'),
('Pavel Mikhailov', '50JZ901234', '2027-08-13', '2026-07-18', '+7(903)901-23-45'),
('Grigory Tarasov', '78IK012345', '2026-03-21', '2026-04-10', '+7(916)012-34-56');

-- 4. Services (СНАЧАЛА заполняем услуги)
INSERT INTO Services (ServiceName, Description, BasePrice, PricePerKm, PricePerHour) VALUES
('Passenger Bus Transport', 'Group passenger transportation by bus/minibus', 3000.00, 35.00, 800.00),
('Cargo Transport', 'Freight transportation by trucks', 5000.00, 50.00, 1200.00),
('VIP Transfer', 'Luxury passenger transfer', 5000.00, 60.00, 1500.00);

-- 5. Clients
INSERT INTO Clients (Name, IsCompany, Phone, Email) VALUES
('StroyInvest LLC', 1, '+7(495)111-22-33', 'info@stroiinvest.ru'),
('IP Petrov A.V.', 0, '+7(916)222-33-44', 'petrov@mail.ru'),
('MebelTrans LLC', 1, '+7(495)333-44-55', 'zakaz@mebeltrans.ru'),
('Promsnab CJSC', 1, '+7(812)444-55-66', 'snab@promsnab.ru'),
('Food Products LLC', 1, '+7(495)555-66-77', 'food@mail.ru'),
('IP Smirnova E.V.', 0, '+7(925)666-77-88', 'smirnova@yandex.ru'),
('AutoParts LLC', 1, '+7(495)777-88-99', 'parts@auto.ru'),
('Trading House LLC', 1, '+7(812)888-99-00', 'zakaz@tdom.ru'),
('IP Kozlov D.N.', 0, '+7(903)999-00-11', 'kozlov@bk.ru'),
('Logistic LLC', 1, '+7(495)000-11-22', 'logistic@mail.ru'),
('MetalStroy JSC', 1, '+7(812)123-45-67', 'metal@stroi.ru'),
('KhimTrans LLC', 1, '+7(495)234-56-78', 'him@trans.ru'),
('IP Morozov A.S.', 0, '+7(916)345-67-89', 'moroz@mail.ru'),
('StekloTara LLC', 1, '+7(495)456-78-90', 'steklo@tararu'),
('StroyTech LLC', 1, '+7(812)567-89-01', 'teh@stroy.ru');

-- 6. Roles
INSERT INTO Roles (RoleName) VALUES 
('Administrator'),
('Dispatcher'),
('Mechanic'),
('Manager'),
('Client');

-- 7. Users (сначала системные пользователи)
INSERT INTO Users (Username, PasswordHash, TempPassword, RoleId, ClientId) VALUES 
('admin', '03AC674216F3E15C761EE1A5E255F067953623C8B388B4459E13F978D7C846F4', 0, 1, NULL),
('dispatcher1', '03AC674216F3E15C761EE1A5E255F067953623C8B388B4459E13F978D7C846F4', 0, 2, NULL),
('dispatcher2', '03AC674216F3E15C761EE1A5E255F067953623C8B388B4459E13F978D7C846F4', 0, 2, NULL),
('mechanic', '03AC674216F3E15C761EE1A5E255F067953623C8B388B4459E13F978D7C846F4', 0, 3, NULL),
('manager', '03AC674216F3E15C761EE1A5E255F067953623C8B388B4459E13F978D7C846F4', 0, 4, NULL);

-- 8. Orders (ТЕПЕРЬ заказы, используя существующие ServiceId)
INSERT INTO Orders (ClientId, ServiceId, OrderDate, TripDate, RouteFrom, RouteTo, Distance, DurationMinutes, PassengerCount, TotalPrice, Status, PaymentStatus, Notes) VALUES
(1, 2, '2025-02-01 10:00', '2025-02-01 14:00', 'Moscow, North Warehouse', 'Moscow, Stroitely St. 15', 45, 60, 2, 7250.00, 'completed', 'paid', 'Building materials delivery'),
(2, 2, '2025-02-02 11:00', '2025-02-02 15:30', 'Moscow, Furniture Factory', 'Moscow, Pushkina St. 10', 25, 40, 2, 6250.00, 'completed', 'paid', 'Furniture transportation'),
(5, 1, '2025-02-04 09:00', '2025-02-04 12:00', 'Krasnodar, Warehouse', 'Krasnodar, Central Market', 15, 25, 5, 3525.00, 'completed', 'paid', 'Food delivery');

-- 9. Trips (ТЕПЕРЬ поездки, используя существующие OrderId)
INSERT INTO Trips (OrderId, VehicleId, DriverId, ActualStartTime, ActualEndTime, ActualMileage, Status) VALUES
(1, 1, 1, '2025-02-01 14:00', '2025-02-01 15:10', 48, 'completed'),
(2, 9, 5, '2025-02-02 15:30', '2025-02-02 16:15', 27, 'completed'),
(3, 11, 9, '2025-02-04 12:00', '2025-02-04 12:30', 16, 'completed');

-- 10. Maintenance types
INSERT INTO MaintenanceTypes (WorkType) VALUES 
('Oil change'),
('Brake pad replacement'),
('Tire fitting'),
('Engine diagnostics'),
('Timing belt replacement'),
('Valve adjustment'),
('Filter replacement'),
('Coolant replacement'),
('Suspension repair'),
('Computer diagnostics');

-- 11. Maintenance log
INSERT INTO MaintenanceLog (VehicleId, MaintenanceDate, MaintenanceTypeId, Mileage, MechanicName, Notes) VALUES
(1, '2024-01-15', 1, 45000, 'Sidorov A.V.', 'Shell oil, oil filter'),
(1, '2024-05-20', 2, 52000, 'Kozlov D.N.', 'Front pads TRW'),
(2, '2024-02-10', 4, 38000, 'Morozov S.A.', 'No errors'),
(2, '2024-06-18', 1, 43000, 'Volkov A.P.', 'Mobil oil'),
(3, '2024-03-05', 3, 120000, 'Zaytsev M.I.', 'Summer tire change'),
(3, '2024-10-12', 3, 129000, 'Sokolov V.V.', 'Winter tire change'),
(4, '2024-04-22', 5, 60000, 'Lebedev I.V.', 'Gates belt'),
(5, '2024-05-30', 7, 25000, 'Pavlov R.S.', 'Fuel, air, cabin filters'),
(6, '2024-02-14', 8, 70000, 'Semenov A.A.', 'G12 coolant'),
(7, '2024-07-19', 9, 95000, 'Egorov M.D.', 'Ball joint replacement'),
(8, '2024-08-25', 10, 110000, 'Grigoriev O.V.', 'All systems check'),
(9, '2024-03-11', 1, 35000, 'Andreev K.S.', 'Castrol oil'),
(10, '2024-09-14', 2, 41000, 'Fedorov D.V.', 'Rear pads'),
(11, '2024-04-03', 4, 88000, 'Kuznetsov N.P.', 'Spark plug replacement'),
(12, '2024-10-30', 6, 115000, 'Novikov T.R.', 'Adjustment'),
(13, '2024-05-17', 1, 22000, 'Smirnov A.S.', 'First maintenance'),
(14, '2024-11-05', 3, 33000, 'Mikhailov P.A.', 'New tires'),
(15, '2024-06-21', 7, 47000, 'Tarasov G.V.', 'Carbon cabin filter'),
(16, '2024-12-12', 5, 68000, 'Ivanov I.I.', 'Belt, pulleys'),
(17, '2024-01-28', 8, 59000, 'Petrov P.P.', 'System flush'),
(18, '2024-07-08', 9, 77000, 'Sidorov A.V.', 'Stabilizer links'),
(19, '2024-02-19', 2, 103000, 'Kozlov D.N.', 'Pads + discs'),
(20, '2024-08-14', 10, 124000, 'Morozov S.A.', 'Injector cleaning'),
(21, '2024-03-27', 1, 54000, 'Volkov A.P.', 'Oil, filter'),
(22, '2024-09-30', 4, 67000, 'Zaytsev M.I.', 'Automatic transmission diagnostics'),
(23, '2024-04-09', 3, 29000, 'Sokolov V.V.', 'Wheel balancing'),
(24, '2024-10-18', 6, 83000, 'Lebedev I.V.', 'Adjustment'),
(25, '2024-05-23', 7, 49000, 'Pavlov R.S.', 'Fuel filter replacement'),
(26, '2024-11-29', 8, 62000, 'Semenov A.A.', 'Brake fluid replacement'),
(27, '2024-06-12', 1, 36000, 'Egorov M.D.', 'Semi-synthetic oil'),
(28, '2024-12-20', 9, 79000, 'Grigoriev O.V.', 'Silent blocks'),
(29, '2024-07-25', 2, 94000, 'Andreev K.S.', 'Brake pads'),
(30, '2024-08-05', 5, 112000, 'Fedorov D.V.', 'Alternator belt');
GO

-- Check record counts
SELECT 'Facilities' AS TableName, COUNT(*) AS Count FROM Facilities
UNION ALL SELECT 'Vehicles', COUNT(*) FROM Vehicles
UNION ALL SELECT 'Drivers', COUNT(*) FROM Drivers
UNION ALL SELECT 'Clients', COUNT(*) FROM Clients
UNION ALL SELECT 'Services', COUNT(*) FROM Services
UNION ALL SELECT 'Orders', COUNT(*) FROM Orders
UNION ALL SELECT 'Trips', COUNT(*) FROM Trips
UNION ALL SELECT 'MaintenanceTypes', COUNT(*) FROM MaintenanceTypes
UNION ALL SELECT 'MaintenanceLog', COUNT(*) FROM MaintenanceLog
UNION ALL SELECT 'Roles', COUNT(*) FROM Roles
UNION ALL SELECT 'Users', COUNT(*) FROM Users;
GO