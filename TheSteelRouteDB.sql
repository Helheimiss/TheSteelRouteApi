-- Create database
--CREATE DATABASE SteelRouteDB;
--GO

USE SteelRouteDB;
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
    IsCompany BIT DEFAULT 1,
    Phone NVARCHAR(20),
    Email NVARCHAR(50)
);

-- 5. Orders
CREATE TABLE Orders (
    Id INT PRIMARY KEY IDENTITY(1,1),
    ClientId INT NOT NULL,
    OrderDate DATE DEFAULT GETDATE(),
    Description NVARCHAR(500),
    FOREIGN KEY (ClientId) REFERENCES Clients(Id)
);

-- 6. Trips
CREATE TABLE Trips (
    Id INT PRIMARY KEY IDENTITY(1,1),
    OrderId INT NOT NULL,
    VehicleId INT NOT NULL,
    DriverId INT NOT NULL,
    TripDate DATE DEFAULT GETDATE(),
    RouteFrom NVARCHAR(200),
    RouteTo NVARCHAR(200),
    Mileage INT,
    FOREIGN KEY (OrderId) REFERENCES Orders(Id),
    FOREIGN KEY (VehicleId) REFERENCES Vehicles(Id),
    FOREIGN KEY (DriverId) REFERENCES Drivers(Id)
);

-- 7. Maintenance types directory
CREATE TABLE MaintenanceTypes (
    Id INT PRIMARY KEY IDENTITY(1,1),
    WorkType NVARCHAR(100) NOT NULL
);

-- 8. Maintenance log
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

-- 9. Users and roles
CREATE TABLE Roles (
    Id INT PRIMARY KEY IDENTITY(1,1),
    RoleName NVARCHAR(50) NOT NULL
);

CREATE TABLE Users (
    Id INT PRIMARY KEY IDENTITY(1,1),
    Username NVARCHAR(50) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(256) NOT NULL,
    RoleId INT NOT NULL,
    FOREIGN KEY (RoleId) REFERENCES Roles(Id)
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
('B456EN', 'XTA23456789012345', 'MAN', 'TGX', 2020, 22.0, 2, 'on trip', 1),
('C789NK', 'XTA34567890123456', 'Volvo', 'FH16', 2022, 25.0, 2, 'repair', 1),
('K123MR', 'XTA45678901234567', 'Mercedes', 'Actros', 2021, 21.5, 2, 'available', 1),
('M456OR', 'XTA56789012345678', 'DAF', 'XF', 2019, 19.8, 2, 'on trip', 2),
('N789ST', 'XTA67890123456789', 'Scania', 'R450', 2023, 20.5, 2, 'available', 2),
('R123UH', 'XTA78901234567890', 'IVECO', 'Stralis', 2020, 21.0, 2, 'available', 3),

-- Gazelles (light trucks)
('T234AE', 'XTA89012345678901', 'GAZ', 'Gazelle NEXT', 2022, 1.5, 3, 'available', 1),
('U345VS', 'XTA90123456789012', 'GAZ', 'Gazelle Business', 2021, 1.5, 3, 'on trip', 1),
('F456EK', 'XTA01234567890123', 'GAZ', 'Gazelle Farmer', 2020, 1.3, 5, 'available', 2),
('H567MN', 'XTA12345098765432', 'GAZ', 'Gazelle NEXT', 2023, 1.5, 3, 'on trip', 2),
('C678OR', 'XTA23456109876543', 'GAZ', 'Gazelle Business', 2021, 1.5, 3, 'repair', 3),

-- Minibuses (passenger)
('CH789PT', 'XTA34567210987654', 'Ford', 'Transit', 2022, NULL, 16, 'available', 1),
('SH890RS', 'XTA45678321098765', 'Mercedes', 'Sprinter', 2023, NULL, 20, 'on trip', 1),
('SCH901TU', 'XTA56789432109876', 'Volkswagen', 'Crafter', 2021, NULL, 18, 'available', 2),
('E012FH', 'XTA67890543210987', 'Peugeot', 'Boxer', 2020, NULL, 16, 'available', 3),
('YU123CCH', 'XTA78901654321098', 'Citroen', 'Jumper', 2022, NULL, 16, 'on trip', 2),
('YA234SHCH', 'XTA89012765432109', 'Renault', 'Master', 2021, NULL, 16, 'available', 1),

-- Additional vehicles
('A345YY', 'XTA90123876543210', 'Scania', 'R580', 2022, 22.5, 2, 'available', 3),
('B456EE', 'XTA01234987654321', 'MAN', 'TGX 18.640', 2023, 24.0, 2, 'on trip', 2),
('C567YYA', 'XTA12345098761234', 'Volvo', 'FH 500', 2021, 21.0, 2, 'available', 1),
('D678AB', 'XTA23456109872345', 'GAZ', 'Gazelle NEXT', 2022, 1.5, 3, 'available', 1),
('E789VG', 'XTA34567210983456', 'Ford', 'Transit', 2023, NULL, 16, 'repair', 2),
('F890DE', 'XTA45678321094567', 'Mercedes', 'Sprinter', 2022, NULL, 20, 'available', 3),
('Z901JZ', 'XTA56789432105678', 'GAZ', 'Sobol', 2021, 1.0, 6, 'available', 1),
('I012IK', 'XTA67890543216789', 'UAZ', 'Profy', 2020, 1.5, 2, 'on trip', 2),
('K123LM', 'XTA78901654327890', 'Hyundai', 'HD78', 2022, 3.0, 3, 'available', 3),
('L234MN', 'XTA89012765438901', 'Isuzu', 'NQR71', 2021, 3.5, 3, 'available', 1),
('M345NO', 'XTA90123876549012', 'Scania', 'P360', 2020, 18.0, 2, 'on trip', 2),
('N456OP', 'XTA01234987650123', 'Mercedes', 'Atego', 2023, 8.0, 2, 'available', 3),
('O567PR', 'XTA12345098761245', 'Volvo', 'FL', 2022, 12.0, 2, 'repair', 1);

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

-- 4. Clients (15 clients)
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

-- 5. Orders (20 orders)
INSERT INTO Orders (ClientId, OrderDate, Description) VALUES
(1, '2025-02-01', 'Delivery of building materials to site'),
(2, '2025-02-02', 'Furniture transportation for client'),
(3, '2025-02-03', 'Equipment transport'),
(4, '2025-02-04', 'Food delivery to stores'),
(5, '2025-02-05', 'Spare parts transport from warehouse'),
(6, '2025-02-06', 'Corporate employee transport'),
(7, '2025-02-07', 'Metal products delivery'),
(8, '2025-02-08', 'Chemical products transport'),
(9, '2025-02-09', 'Urgent document delivery'),
(10, '2025-02-10', 'Office relocation'),
(1, '2025-02-11', 'Additional building materials supply'),
(2, '2025-02-12', 'Old furniture removal'),
(3, '2025-02-13', 'Machine tools delivery'),
(4, '2025-02-14', 'Perishable food transport'),
(5, '2025-02-15', 'Battery transport'),
(6, '2025-02-16', 'Delegation transfer'),
(7, '2025-02-17', 'Reinforcement delivery'),
(8, '2025-02-18', 'Solvents transport'),
(9, '2025-02-19', 'Courier delivery'),
(10, '2025-02-20', 'Office equipment transport');

-- 6. Trips (30+ records)
INSERT INTO Trips (OrderId, VehicleId, DriverId, TripDate, RouteFrom, RouteTo, Mileage) VALUES
(1, 1, 1, '2025-02-01', 'Moscow, North Warehouse', 'Moscow, Stroitely St. 15', 45),
(1, 2, 3, '2025-02-01', 'Moscow, South Warehouse', 'Moscow, Lenina St. 20', 60),
(2, 9, 5, '2025-02-02', 'Moscow, Furniture Factory', 'Moscow, Pushkina St. 10', 25),
(3, 10, 7, '2025-02-03', 'SPb, North Warehouse', 'SPb, Entuziastov Ave. 50', 35),
(4, 11, 9, '2025-02-04', 'Krasnodar, Warehouse', 'Krasnodar, Central Market', 15),
(5, 3, 11, '2025-02-05', 'Moscow, Auto Warehouse', 'Moscow, South Service Station', 30),
(6, 15, 13, '2025-02-06', 'Moscow, Company Office', 'Sheremetyevo Airport', 65),
(7, 4, 15, '2025-02-07', 'Moscow, Metal Base', 'SPb, Construction Site', 750),
(8, 5, 17, '2025-02-08', 'Moscow, Chemical Warehouse', 'Tver, Factory', 180),
(9, 12, 19, '2025-02-09', 'Moscow, Center', 'Moscow, Kursky Railway Station', 12),
(10, 6, 2, '2025-02-10', 'Moscow, Office 1', 'Moscow, Office 2', 20),
(11, 7, 4, '2025-02-11', 'SPb, Port', 'SPb, Warehouse', 25),
(12, 8, 6, '2025-02-12', 'Moscow, Warehouse', 'Mytishchi, Shopping Center', 35),
(13, 13, 8, '2025-02-13', 'Krasnodar, Factory', 'Rostov-on-Don, Warehouse', 280),
(14, 14, 10, '2025-02-14', 'SPb, Warehouse', 'Veliky Novgorod, Store', 190),
(15, 16, 12, '2025-02-15', 'Moscow, Warehouse', 'Elektrostal, Factory', 70),
(16, 17, 14, '2025-02-16', 'Moscow, Hotel', 'Vnukovo Airport', 55),
(17, 18, 16, '2025-02-17', 'Moscow, Metal Base', 'Lyubertsy, Construction', 25),
(18, 19, 18, '2025-02-18', 'Moscow, Chemical Warehouse', 'Klin, Factory', 95),
(19, 20, 20, '2025-02-19', 'Moscow, Center', 'Moscow, South Port', 18),
(20, 21, 1, '2025-02-20', 'Moscow, Office', 'Krasnogorsk, Warehouse', 30),
(1, 22, 3, '2025-02-21', 'Moscow, Warehouse', 'Moscow, RIO Mall', 15),
(2, 23, 5, '2025-02-22', 'SPb, Warehouse', 'Pushkin, Store', 30),
(3, 24, 7, '2025-02-23', 'Krasnodar, Warehouse', 'Anapa, Resort Base', 180),
(4, 25, 9, '2025-02-24', 'Moscow, Warehouse', 'Solnechnogorsk, Factory', 80),
(5, 26, 11, '2025-02-25', 'Moscow, Auto Warehouse', 'Podolsk, Service Station', 55),
(6, 27, 13, '2025-02-26', 'Moscow, Office', 'Odintsovo, Business Center', 25),
(7, 28, 15, '2025-02-27', 'Moscow, Metal Base', 'Naro-Fominsk, Construction', 110),
(8, 29, 17, '2025-02-28', 'Moscow, Chemical Warehouse', 'Serpukhov, Factory', 130),
(9, 30, 19, '2025-03-01', 'Moscow, Center', 'Moscow, Paveletsky Railway Station', 10);

-- 7. Maintenance types
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

-- 8. Maintenance log (30+ records)
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

-- 9. Roles
INSERT INTO Roles (RoleName) VALUES 
('Administrator'),
('Dispatcher'),
('Mechanic'),
('Manager');

-- 10. Users (username: name, password: 1234 - for example only)
-- In real project passwords must be hashed!
INSERT INTO Users (Username, PasswordHash, RoleId) VALUES 
('admin', '03AC674216F3E15C761EE1A5E255F067953623C8B388B4459E13F978D7C846F4', 1),
('dispatcher1', '03AC674216F3E15C761EE1A5E255F067953623C8B388B4459E13F978D7C846F4', 2),
('dispatcher2', '03AC674216F3E15C761EE1A5E255F067953623C8B388B4459E13F978D7C846F4', 2),
('mechanic', '03AC674216F3E15C761EE1A5E255F067953623C8B388B4459E13F978D7C846F4', 3),
('manager', '03AC674216F3E15C761EE1A5E255F067953623C8B388B4459E13F978D7C846F4', 4);
GO

-- Check record counts
SELECT 'Facilities' AS TableName, COUNT(*) AS Count FROM Facilities
UNION ALL SELECT 'Vehicles', COUNT(*) FROM Vehicles
UNION ALL SELECT 'Drivers', COUNT(*) FROM Drivers
UNION ALL SELECT 'Clients', COUNT(*) FROM Clients
UNION ALL SELECT 'Orders', COUNT(*) FROM Orders
UNION ALL SELECT 'Trips', COUNT(*) FROM Trips
UNION ALL SELECT 'MaintenanceTypes', COUNT(*) FROM MaintenanceTypes
UNION ALL SELECT 'MaintenanceLog', COUNT(*) FROM MaintenanceLog
UNION ALL SELECT 'Users', COUNT(*) FROM Users;
GO