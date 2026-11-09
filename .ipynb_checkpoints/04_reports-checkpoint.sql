-- Q1: Active students per route
SELECT r.route_name, COUNT(s.student_id) AS total_students
FROM Routes r
LEFT JOIN Stops st ON st.route_id = r.route_id
LEFT JOIN Students s ON s.stop_id = st.stop_id AND s.status = 'Active'
GROUP BY r.route_id, r.route_name
ORDER BY total_students DESC;

-- Q2: Routes with 2 or more active students (HAVING)
SELECT r.route_name, COUNT(s.student_id) AS total_students
FROM Routes r
JOIN Stops st ON st.route_id = r.route_id
JOIN Students s ON s.stop_id = st.stop_id AND s.status = 'Active'
GROUP BY r.route_id, r.route_name
HAVING COUNT(s.student_id) >= 2;

-- Q3: Monthly fee collection
SELECT month_paid, COUNT(*) AS payments, SUM(amount) AS total_collected
FROM Payments WHERE status IN ('Paid','Late')
GROUP BY month_paid ORDER BY month_paid;



-- Q4: Students who have not paid October 2026 (subquery)
SELECT s.student_id, s.full_name, s.class_name, r.route_name, r.monthly_fee, s.guardian_phone
FROM Students s
JOIN Stops st ON st.stop_id = s.stop_id
JOIN Routes r ON r.route_id = st.route_id
WHERE s.status = 'Active'
  AND NOT EXISTS (SELECT 1 FROM Payments p WHERE p.student_id = s.student_id AND p.month_paid = '2026-10')
ORDER BY r.monthly_fee DESC;

-- Q5: Route distance and fee statistics (AVG, MIN, MAX)
SELECT COUNT(*) AS total_routes,
       ROUND(AVG(distance_km),1) AS avg_distance, MIN(distance_km) AS min_distance, MAX(distance_km) AS max_distance,
       ROUND(AVG(monthly_fee),0) AS avg_fee, MIN(monthly_fee) AS min_fee, MAX(monthly_fee) AS max_fee
FROM Routes;

-- Q6: Driver licenses expiring within 365 days (date filtering)
SELECT driver_id, full_name, license_no, license_expiry,
       DATEDIFF(day, CAST(GETDATE() AS DATE), license_expiry) AS days_left
FROM Drivers
WHERE license_expiry BETWEEN CAST(GETDATE() AS DATE) AND DATEADD(day, 365, CAST(GETDATE() AS DATE))
ORDER BY license_expiry;


-- Q7: Maintenance cost per bus
SELECT b.bus_number, b.model, COUNT(m.maint_id) AS jobs, COALESCE(SUM(m.cost),0) AS total_cost
FROM Buses b LEFT JOIN Maintenance m ON m.bus_id = b.bus_id
GROUP BY b.bus_id, b.bus_number, b.model
ORDER BY total_cost DESC;


-- Q8: Buses with above-average capacity (subquery)
SELECT bus_number, model, capacity
FROM Buses
WHERE capacity > (SELECT AVG(capacity) FROM Buses)
ORDER BY capacity DESC;


-- Q9: Route occupancy (uses VIEW)
SELECT * FROM vw_route_occupancy ORDER BY occupancy_pct DESC;


-- Q10: Current bus, driver and route assignments
SELECT a.shift, r.route_name, b.bus_number, d.full_name AS driver, a.start_date
FROM Assignments a
JOIN Buses b ON b.bus_id = a.bus_id
JOIN Drivers d ON d.driver_id = a.driver_id
JOIN Routes r ON r.route_id = a.route_id
WHERE a.end_date IS NULL
ORDER BY a.shift, r.route_name;

-- Q11: Payment method breakdown
SELECT method, COUNT(*) AS payments, SUM(amount) AS total, ROUND(AVG(amount),0) AS avg_amount
FROM Payments GROUP BY method ORDER BY total DESC;


-- Q12: Revenue by route
SELECT r.route_name, COUNT(p.payment_id) AS payments, SUM(p.amount) AS revenue
FROM Payments p
JOIN Students s ON s.student_id = p.student_id
JOIN Stops st ON st.stop_id = s.stop_id
JOIN Routes r ON r.route_id = st.route_id
GROUP BY r.route_id, r.route_name
ORDER BY revenue DESC;


-- Q13: Late payment percentage by month
SELECT month_paid,
       SUM(CASE WHEN status='Late' THEN 1 ELSE 0 END) AS late_count,
       COUNT(*) AS total_payments,
       ROUND(SUM(CASE WHEN status='Late' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS late_pct
FROM Payments GROUP BY month_paid ORDER BY month_paid;





























