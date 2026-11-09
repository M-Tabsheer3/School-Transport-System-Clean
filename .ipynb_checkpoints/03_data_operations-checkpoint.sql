USE school_transport_db;
GO

-- SELECT with AND
SELECT * FROM Students WHERE status='Active' AND gender='Female';

-- OR, NOT
SELECT * FROM Students WHERE class_name='Class 5' OR class_name='Class 6';
SELECT * FROM Buses WHERE NOT status='Active';

-- BETWEEN, IN, LIKE
SELECT * FROM Routes WHERE monthly_fee BETWEEN 3500 AND 4500;
SELECT * FROM Buses WHERE fuel_type IN ('Diesel','CNG');
SELECT * FROM Students WHERE full_name LIKE 'A%';

-- DISTINCT, ORDER BY
SELECT DISTINCT class_name FROM Students ORDER BY class_name;
SELECT * FROM Drivers ORDER BY salary DESC;
-- UPDATE (pehle aur baad dikhayen)
SELECT route_id, route_name, monthly_fee FROM Routes WHERE route_id = 1;
UPDATE Routes SET monthly_fee = monthly_fee + 200 WHERE route_id = 1;
SELECT route_id, route_name, monthly_fee FROM Routes WHERE route_id = 1;
UPDATE Routes SET monthly_fee = monthly_fee - 200 WHERE route_id = 1;   -- wapas purani value
UPDATE Buses SET status = 'Active' WHERE bus_id = 7;


-- INSERT + DELETE
INSERT INTO Students (full_name,class_name,gender,guardian_name,guardian_phone,stop_id)
VALUES ('Test Student','Class 1','Male','Test Parent','0300-0000000',1);
SELECT * FROM Students WHERE full_name = 'Test Student';
DELETE FROM Students WHERE full_name = 'Test Student';
SELECT * FROM Students WHERE full_name = 'Test Student';






















