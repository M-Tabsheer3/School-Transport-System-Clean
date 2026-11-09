USE school_transport_db;
GO

-- VIEW 1: route occupancy
CREATE OR ALTER VIEW vw_route_occupancy AS
SELECT t.route_id, t.route_name, t.seat_capacity, t.enrolled,
       ROUND(t.enrolled * 100.0 / NULLIF(t.seat_capacity,0), 1) AS occupancy_pct
FROM (
  SELECT r.route_id, r.route_name,
    (SELECT COALESCE(SUM(b.capacity),0) FROM Assignments a JOIN Buses b ON b.bus_id=a.bus_id
      WHERE a.route_id=r.route_id AND a.shift='Morning' AND a.end_date IS NULL) AS seat_capacity,
    (SELECT COUNT(*) FROM Students s JOIN Stops st ON st.stop_id=s.stop_id
      WHERE st.route_id=r.route_id AND s.status='Active') AS enrolled
  FROM Routes r
) t;
GO

-- VIEW 2: student full transport details
CREATE OR ALTER VIEW vw_student_transport_details AS
SELECT s.student_id, s.full_name AS student_name, s.class_name, s.guardian_phone,
       st.stop_name, CONVERT(VARCHAR(5), st.pickup_time, 108) AS pickup_time,
       r.route_name, b.bus_number, d.full_name AS driver_name, s.status AS student_status
FROM Students s
JOIN Stops st ON st.stop_id = s.stop_id
JOIN Routes r ON r.route_id = st.route_id
LEFT JOIN Assignments a ON a.route_id = r.route_id AND a.shift='Morning' AND a.end_date IS NULL
LEFT JOIN Buses b ON b.bus_id = a.bus_id
LEFT JOIN Drivers d ON d.driver_id = a.driver_id;
GO

-- PROCEDURE 1: register student (stop check + seat check)
CREATE OR ALTER PROCEDURE sp_register_student
  @name VARCHAR(80), @class VARCHAR(20), @gender VARCHAR(10),
  @guardian VARCHAR(80), @phone VARCHAR(15), @address VARCHAR(120), @stop INT
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @route INT, @cap INT, @enrolled INT;

  SELECT @route = route_id FROM Stops WHERE stop_id = @stop;
  IF @route IS NULL
    THROW 50001, 'Invalid stop selected', 1;

  SELECT @cap = COALESCE(SUM(b.capacity),0)
  FROM Assignments a JOIN Buses b ON b.bus_id = a.bus_id
  WHERE a.route_id = @route AND a.shift='Morning' AND a.end_date IS NULL;

  SELECT @enrolled = COUNT(*)
  FROM Students s JOIN Stops st ON st.stop_id = s.stop_id
  WHERE st.route_id = @route AND s.status='Active';

  IF @enrolled >= @cap
    THROW 50002, 'Route is full: no seats available', 1;

  INSERT INTO Students (full_name,class_name,gender,guardian_name,guardian_phone,address,stop_id)
  VALUES (@name,@class,@gender,@guardian,@phone,@address,@stop);

  SELECT CAST(SCOPE_IDENTITY() AS INT) AS new_student_id, 'Student registered' AS message;
END;
GO

-- PROCEDURE 2: monthly fee report
CREATE OR ALTER PROCEDURE sp_monthly_fee_report @month CHAR(7)
AS
BEGIN
  SET NOCOUNT ON;
  SELECT s.student_id, s.full_name, r.route_name, r.monthly_fee,
         COALESCE(p.status,'Not Paid') AS payment_status, p.payment_date, p.method
  FROM Students s
  JOIN Stops st ON st.stop_id = s.stop_id
  JOIN Routes r ON r.route_id = st.route_id
  LEFT JOIN Payments p ON p.student_id = s.student_id AND p.month_paid = @month
  WHERE s.status = 'Active'
  ORDER BY payment_status, s.full_name;
END;
GO

-- TRIGGER 1: payment 10 tareekh ke baad ho to status 'Late'
CREATE OR ALTER TRIGGER trg_payment_late ON Payments
AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON;
  UPDATE p SET status = 'Late'
  FROM Payments p JOIN inserted i ON i.payment_id = p.payment_id
  WHERE i.status = 'Paid' AND DAY(i.payment_date) > 10;
END;
GO

-- TRIGGER 2: aaj ya future ki maintenance entry par bus status 'Maintenance'
CREATE OR ALTER TRIGGER trg_bus_maintenance ON Maintenance
AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON;
  UPDATE b SET status = 'Maintenance'
  FROM Buses b JOIN inserted i ON i.bus_id = b.bus_id
  WHERE i.maint_date >= CAST(GETDATE() AS DATE);
END;
GO

-- BONUS: indexes
CREATE INDEX idx_students_stop ON Students(stop_id);
CREATE INDEX idx_payments_month ON Payments(month_paid);
GO


-- Demo 1: VIEW
SELECT * FROM vw_route_occupancy;

-- Demo 2: VIEW
SELECT TOP 5 * FROM vw_student_transport_details;


-- Demo 3: Stored procedure (success)
EXEC sp_register_student 'Demo Student','Class 4','Male','Demo Parent','0321-9999999','Test Address',1;
SELECT TOP 3 * FROM Students ORDER BY student_id DESC;


-- Demo 4: Stored procedure (error)
EXEC sp_register_student 'X','Class 1','Male','Y','0300-0000000','Z',999;

-- Demo 6: Trigger 1 (Late payment)
INSERT INTO Payments (student_id,amount,payment_date,month_paid) VALUES (12,3500,'2026-10-20','2026-10');
SELECT * FROM Payments WHERE student_id = 12;


INSERT INTO Maintenance (bus_id,maint_date,description,cost) VALUES (2,CAST(GETDATE() AS DATE),'Engine check',5000);
SELECT bus_id, bus_number, status FROM Buses WHERE bus_id = 2;    -- AFTER







