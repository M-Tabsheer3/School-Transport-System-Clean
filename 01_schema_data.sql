IF DB_ID('school_transport_db') IS NOT NULL
BEGIN
    ALTER DATABASE school_transport_db SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE school_transport_db;
END
GO
CREATE DATABASE school_transport_db;
GO
USE school_transport_db;
GO

CREATE TABLE Drivers (
  driver_id      INT IDENTITY(1,1) PRIMARY KEY,
  full_name      VARCHAR(80)  NOT NULL,
  cnic           CHAR(15)     NOT NULL UNIQUE,
  phone          VARCHAR(15)  NOT NULL UNIQUE,
  license_no     VARCHAR(20)  NOT NULL UNIQUE,
  license_expiry DATE         NOT NULL,
  hire_date      DATE         NOT NULL DEFAULT (CAST(GETDATE() AS DATE)),
  salary         DECIMAL(10,2) NOT NULL CHECK (salary > 0),
  status         VARCHAR(10)  NOT NULL DEFAULT 'Active'
                 CHECK (status IN ('Active','On Leave','Resigned'))
);

CREATE TABLE Buses (
  bus_id        INT IDENTITY(1,1) PRIMARY KEY,
  bus_number    VARCHAR(15) NOT NULL UNIQUE,
  model         VARCHAR(50) NOT NULL,
  capacity      INT NOT NULL CHECK (capacity BETWEEN 10 AND 70),
  purchase_year INT CHECK (purchase_year BETWEEN 2000 AND 2035),
  fuel_type     VARCHAR(10) NOT NULL DEFAULT 'Diesel' CHECK (fuel_type IN ('Diesel','Petrol','CNG')),
  status        VARCHAR(12) NOT NULL DEFAULT 'Active' CHECK (status IN ('Active','Maintenance','Retired'))
);

CREATE TABLE Routes (
  route_id    INT IDENTITY(1,1) PRIMARY KEY,
  route_name  VARCHAR(60) NOT NULL UNIQUE,
  start_point VARCHAR(60) NOT NULL,
  end_point   VARCHAR(60) NOT NULL,
  distance_km DECIMAL(5,1) NOT NULL CHECK (distance_km > 0),
  monthly_fee DECIMAL(8,2) NOT NULL CHECK (monthly_fee > 0)
);

CREATE TABLE Stops (
  stop_id     INT IDENTITY(1,1) PRIMARY KEY,
  route_id    INT NOT NULL,
  stop_name   VARCHAR(60) NOT NULL,
  stop_order  INT NOT NULL CHECK (stop_order > 0),
  pickup_time TIME NOT NULL,
  CONSTRAINT fk_stop_route FOREIGN KEY (route_id) REFERENCES Routes(route_id) ON DELETE CASCADE,
  CONSTRAINT uq_route_order UNIQUE (route_id, stop_order)
);

CREATE TABLE Students (
  student_id      INT IDENTITY(1,1) PRIMARY KEY,
  full_name       VARCHAR(80) NOT NULL,
  class_name      VARCHAR(20) NOT NULL,
  gender          VARCHAR(6)  NOT NULL CHECK (gender IN ('Male','Female')),
  guardian_name   VARCHAR(80) NOT NULL,
  guardian_phone  VARCHAR(15) NOT NULL,
  address         VARCHAR(120),
  stop_id         INT NOT NULL,
  enrollment_date DATE NOT NULL DEFAULT (CAST(GETDATE() AS DATE)),
  status          VARCHAR(10) NOT NULL DEFAULT 'Active' CHECK (status IN ('Active','Inactive')),
  CONSTRAINT fk_student_stop FOREIGN KEY (stop_id) REFERENCES Stops(stop_id)
);

CREATE TABLE Assignments (
  assignment_id INT IDENTITY(1,1) PRIMARY KEY,
  bus_id        INT NOT NULL,
  driver_id     INT NOT NULL,
  route_id      INT NOT NULL,
  shift         VARCHAR(10) NOT NULL DEFAULT 'Morning' CHECK (shift IN ('Morning','Afternoon')),
  start_date    DATE NOT NULL,
  end_date      DATE NULL,
  CONSTRAINT fk_as_bus    FOREIGN KEY (bus_id)    REFERENCES Buses(bus_id),
  CONSTRAINT fk_as_driver FOREIGN KEY (driver_id) REFERENCES Drivers(driver_id),
  CONSTRAINT fk_as_route  FOREIGN KEY (route_id)  REFERENCES Routes(route_id),
  CONSTRAINT uq_bus_shift UNIQUE (bus_id, shift, start_date),
  CONSTRAINT chk_dates CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE TABLE Payments (
  payment_id   INT IDENTITY(1,1) PRIMARY KEY,
  student_id   INT NOT NULL,
  amount       DECIMAL(8,2) NOT NULL CHECK (amount > 0),
  payment_date DATE NOT NULL DEFAULT (CAST(GETDATE() AS DATE)),
  month_paid   CHAR(7) NOT NULL CHECK (month_paid LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9]'),
  method       VARCHAR(15) NOT NULL DEFAULT 'Cash' CHECK (method IN ('Cash','Bank Transfer','JazzCash','Easypaisa')),
  status       VARCHAR(10) NOT NULL DEFAULT 'Paid' CHECK (status IN ('Paid','Pending','Late')),
  CONSTRAINT fk_pay_student FOREIGN KEY (student_id) REFERENCES Students(student_id),
  CONSTRAINT uq_student_month UNIQUE (student_id, month_paid)
);

CREATE TABLE Maintenance (
  maint_id    INT IDENTITY(1,1) PRIMARY KEY,
  bus_id      INT NOT NULL,
  maint_date  DATE NOT NULL,
  description VARCHAR(150) NOT NULL,
  cost        DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (cost >= 0),
  CONSTRAINT fk_maint_bus FOREIGN KEY (bus_id) REFERENCES Buses(bus_id)
);
GO

-- ===================== DATA =====================
INSERT INTO Drivers (full_name,cnic,phone,license_no,license_expiry,hire_date,salary,status) VALUES
('Muhammad Aslam','42101-1000001-1','0300-1000001','LIC-KHI-001','2029-05-14','2018-03-10',48000,'Active'),
('Abdul Rehman','42101-1000002-3','0301-1000002','LIC-KHI-002','2027-02-20','2019-06-01',46000,'Active'),
('Shahid Mehmood','42101-1000003-5','0302-1000003','LIC-KHI-003','2028-09-30','2020-01-15',45000,'Active'),
('Imran Qureshi','42101-1000004-7','0303-1000004','LIC-KHI-004','2027-04-10','2017-08-20',50000,'Active'),
('Zubair Ahmed','42101-1000005-9','0304-1000005','LIC-KHI-005','2030-01-05','2021-02-11',44000,'Active'),
('Naveed Khan','42101-1000006-1','0305-1000006','LIC-KHI-006','2029-11-18','2022-07-07',43000,'Active'),
('Tariq Hussain','42101-1000007-3','0306-1000007','LIC-KHI-007','2028-03-22','2016-05-30',52000,'On Leave'),
('Farooq Ali','42101-1000008-5','0307-1000008','LIC-KHI-008','2029-08-09','2023-01-09',42000,'Active'),
('Kamran Siddiqui','42101-1000009-7','0308-1000009','LIC-KHI-009','2027-12-01','2020-10-12',47000,'Active'),
('Waseem Akhtar','42101-1000010-9','0309-1000010','LIC-KHI-010','2030-06-25','2024-02-19',41000,'Active');

INSERT INTO Buses (bus_number,model,capacity,purchase_year,fuel_type,status) VALUES
('KHI-1001','Toyota Coaster',29,2018,'Diesel','Active'),
('KHI-1002','Hino Rainbow',32,2017,'Diesel','Active'),
('KHI-1003','Toyota HiAce',15,2020,'Petrol','Active'),
('KHI-1004','Isuzu NPR Coach',35,2016,'Diesel','Active'),
('KHI-1005','Toyota Coaster',29,2021,'Diesel','Active'),
('KHI-1006','Suzuki Bolan',12,2019,'CNG','Active'),
('KHI-1007','Hino Rainbow',32,2015,'Diesel','Maintenance'),
('KHI-1008','Toyota HiAce',15,2022,'Petrol','Active'),
('KHI-1009','Yutong Mini Coach',40,2023,'Diesel','Active'),
('KHI-1010','Toyota Coaster',29,2019,'Diesel','Active');

INSERT INTO Routes (route_name,start_point,end_point,distance_km,monthly_fee) VALUES
('Gulshan Express','Gulshan-e-Iqbal','School Campus',12.5,3500),
('North Nazimabad Line','North Nazimabad','School Campus',14.0,3800),
('Korangi Route','Korangi','School Campus',18.5,4200),
('Malir Route','Malir','School Campus',20.0,4500),
('Clifton-DHA Route','DHA Phase 5','School Campus',16.0,4800),
('Saddar Route','Saddar','School Campus',11.0,3300),
('Landhi Route','Landhi','School Campus',22.5,4600),
('Gulistan-e-Johar Route','Gulistan-e-Johar','School Campus',13.5,3600),
('Nazimabad Route','Nazimabad','School Campus',15.0,3700),
('PECHS Route','PECHS','School Campus',9.5,3200);

INSERT INTO Stops (route_id,stop_name,stop_order,pickup_time) VALUES
(1,'Gulshan Chowrangi',1,'06:45'),(1,'Johar Mor',2,'07:05'),
(2,'Five Star Chowrangi',1,'06:40'),(2,'Nagan Chowrangi',2,'07:00'),
(3,'Korangi Crossing',1,'06:30'),(3,'Indus Mehran',2,'06:50'),
(4,'Malir Halt',1,'06:25'),(4,'Model Colony',2,'06:50'),
(5,'Zamzama',1,'06:50'),(5,'Khayaban-e-Ittehad',2,'07:10'),
(6,'Saddar Empress Market',1,'06:55'),(6,'Frere Town',2,'07:15'),
(7,'Landhi Chowrangi',1,'06:20'),(7,'Quaidabad',2,'06:40'),
(8,'Safoora Chowrangi',1,'06:45'),(8,'University Road',2,'07:05'),
(9,'Nazimabad No.1',1,'06:50'),(9,'Liaquatabad 10 Number',2,'07:10'),
(10,'PECHS Block 2',1,'07:00'),(10,'Tariq Road',2,'07:20');

INSERT INTO Students (full_name,class_name,gender,guardian_name,guardian_phone,address,stop_id,enrollment_date,status) VALUES
('Ayaan Khan','Class 5','Male','Imran Khan','0321-2000001','Block 13-D, Gulshan',1,'2025-04-01','Active'),
('Fatima Noor','Class 3','Female','Noor Ahmed','0321-2000002','Block 7, Gulshan',1,'2025-04-01','Active'),
('Hamza Ali','Class 8','Male','Ali Raza','0321-2000003','Sector 5-C, North Nazimabad',3,'2025-08-15','Active'),
('Zainab Raza','Class 6','Female','Raza Hussain','0321-2000004','Korangi No. 5',5,'2025-08-15','Active'),
('Usman Tariq','Class 9','Male','Tariq Mehmood','0321-2000005','Malir Cantt Road',7,'2025-04-01','Active'),
('Maryam Siddiqui','Class 4','Female','Adeel Siddiqui','0321-2000006','Phase 5, DHA',9,'2026-01-10','Active'),
('Bilal Ahmed','Class 7','Male','Ahmed Yar','0321-2000007','Saddar Garden Road',11,'2025-04-01','Active'),
('Hira Fatima','Class 2','Female','Shahid Ali','0321-2000008','Landhi 36-B',13,'2026-01-10','Active'),
('Saad Mansoor','Class 10','Male','Mansoor Elahi','0321-2000009','Safoora Goth',15,'2024-08-20','Active'),
('Areeba Khalid','Class 1','Female','Khalid Javed','0321-2000010','Nazimabad Block 3',17,'2026-04-05','Active'),
('Daniyal Shah','Class 6','Male','Shah Nawaz','0321-2000011','PECHS Block 6',19,'2025-08-15','Active'),
('Sana Iqbal','Class 5','Female','Iqbal Hussain','0321-2000012','Johar Block 12',2,'2025-08-15','Active'),
('Rohan Das','Class 8','Male','Anil Das','0321-2000013','Nagan Society',4,'2024-08-20','Active'),
('Iqra Hassan','Class 3','Female','Hassan Raza','0321-2000014','Frere Town',12,'2025-04-01','Inactive'),
('Taha Malik','Class 9','Male','Malik Aslam','0321-2000015','Tariq Road',20,'2025-04-01','Active');

INSERT INTO Assignments (bus_id,driver_id,route_id,shift,start_date,end_date) VALUES
(1,1,1,'Morning','2026-08-01',NULL),
(2,2,2,'Morning','2026-08-01',NULL),
(3,3,3,'Morning','2026-08-01',NULL),
(4,4,4,'Morning','2026-08-01',NULL),
(5,5,5,'Morning','2026-08-01',NULL),
(6,6,6,'Morning','2026-08-01',NULL),
(7,7,7,'Morning','2026-08-01',NULL),
(8,8,8,'Morning','2026-08-01',NULL),
(9,9,9,'Morning','2026-08-01',NULL),
(10,10,10,'Morning','2026-08-01',NULL),
(1,1,2,'Afternoon','2026-08-01',NULL),
(3,3,6,'Afternoon','2026-08-01',NULL),
(8,8,1,'Morning','2026-01-01','2026-07-31');

INSERT INTO Maintenance (bus_id,maint_date,description,cost) VALUES
(1,'2026-01-15','Oil change and filter replacement',8500),
(2,'2026-02-10','Brake pad replacement',22000),
(3,'2026-03-05','Tyre rotation and alignment',6500),
(4,'2026-03-28','Engine tune-up',35000),
(5,'2026-04-18','AC compressor repair',28000),
(6,'2026-05-09','CNG kit inspection',12000),
(7,'2026-06-21','Gearbox overhaul',60000),
(7,'2026-09-30','Suspension repair',18000),
(9,'2026-08-12','Routine service',9000),
(10,'2026-10-05','Battery replacement',14500);

INSERT INTO Payments (student_id,amount,payment_date,month_paid,method,status) VALUES
(1,3500,'2026-09-03','2026-09','Cash','Paid'),
(2,3500,'2026-09-05','2026-09','Bank Transfer','Paid'),
(3,3800,'2026-09-04','2026-09','JazzCash','Paid'),
(4,4200,'2026-09-12','2026-09','Easypaisa','Late'),
(5,4500,'2026-09-06','2026-09','Cash','Paid'),
(6,4800,'2026-09-08','2026-09','Bank Transfer','Paid'),
(7,3300,'2026-09-02','2026-09','Cash','Paid'),
(8,4600,'2026-09-15','2026-09','JazzCash','Late'),
(9,3600,'2026-09-07','2026-09','Easypaisa','Paid'),
(10,3700,'2026-09-09','2026-09','Cash','Paid'),
(1,3500,'2026-10-04','2026-10','Cash','Paid'),
(2,3500,'2026-10-06','2026-10','Bank Transfer','Paid'),
(3,3800,'2026-10-05','2026-10','JazzCash','Paid'),
(4,4200,'2026-10-14','2026-10','Easypaisa','Late'),
(5,4500,'2026-10-07','2026-10','Cash','Paid'),
(6,4800,'2026-10-09','2026-10','Bank Transfer','Paid'),
(7,3300,'2026-10-03','2026-10','Cash','Paid'),
(9,3600,'2026-10-08','2026-10','Easypaisa','Paid'),
(10,3700,'2026-10-10','2026-10','Cash','Paid'),
(11,3200,'2026-10-06','2026-10','JazzCash','Paid');
GO

SELECT 'Drivers' AS tbl, COUNT(*) AS n FROM Drivers UNION ALL SELECT 'Buses',COUNT(*) FROM Buses
UNION ALL SELECT 'Routes',COUNT(*) FROM Routes UNION ALL SELECT 'Stops',COUNT(*) FROM Stops
UNION ALL SELECT 'Students',COUNT(*) FROM Students UNION ALL SELECT 'Assignments',COUNT(*) FROM Assignments
UNION ALL SELECT 'Maintenance',COUNT(*) FROM Maintenance UNION ALL SELECT 'Payments',COUNT(*) FROM Payments;