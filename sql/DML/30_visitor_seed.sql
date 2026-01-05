-- sql/DML/30_visitor_seed.sql
-- 可重复执行，使用 INSERT IGNORE / ON DUPLICATE KEY UPDATE 避免主键冲突

-- Region (依赖表)
INSERT IGNORE INTO Region (region_id, region_name, region_type) VALUES
('R001', 'Yellowstone North', 'core'),
('R002', 'Yosemite Valley', 'core'),
('R003', 'Grand Canyon South Rim', 'buffer'),
('R004', 'Zion Narrows', 'restricted'),
('R005', 'Yosemite High Sierra', 'core'),
('R006', 'Everglades Wetland', 'buffer'),
('R007', 'Acadia Coastal Trail', 'tourist'),
('R008', 'Rocky Mountain Peak', 'core'),
('R009', 'Olympic Rainforest', 'buffer'),
('R010', 'Arches Scenic Loop', 'tourist');

-- FlowControl (依赖 Region)
INSERT INTO FlowControl (region_id, daily_capacity, current_visitor_count, warning_threshold, flow_status)
VALUES
('R001', 5000, 4200, 4500, 'warning'),
('R002', 8000, 7500, 7800, 'warning'),
('R003', 3000, 2800, 2900, 'warning'),
('R004', 500, 480, 490, 'restricted'),
('R005', 2000, 1200, 1800, 'normal'),
('R006', 4000, 3500, 3800, 'normal'),
('R007', 6000, 5900, 5950, 'warning'),
('R008', 1500, 1400, 1450, 'warning'),
('R009', 3500, 3000, 3300, 'normal'),
('R010', 2500, 2400, 2450, 'warning')
ON DUPLICATE KEY UPDATE
    current_visitor_count = VALUES(current_visitor_count),
    flow_status = VALUES(flow_status);

-- Visitor (20+ records)
INSERT IGNORE INTO Visitor (visitor_id, visitor_name, id_number, contact_number, entry_time, exit_time, entry_method) VALUES
('V1001', 'Alice Johnson', 'ID10000001', '+1-555-0101', '2025-06-01', '2025-06-05', 'online'),
('V1002', 'Bob Smith', 'ID10000002', '+1-555-0102', '2025-06-02', '2025-06-04', 'onsite'),
('V1003', 'Charlie Brown', 'ID10000003', '+1-555-0103', '2025-06-03', '2025-06-06', 'online'),
('V1004', 'Diana Prince', 'ID10000004', '+1-555-0104', '2025-06-01', '2025-06-03', 'online'),
('V1005', 'Edward Norton', 'ID10000005', '+1-555-0105', '2025-06-04', '2025-06-07', 'onsite'),
('V1006', 'Fiona Gallagher', 'ID10000006', '+1-555-0106', '2025-06-02', '2025-06-05', 'online'),
('V1007', 'George Clooney', 'ID10000007', '+1-555-0107', '2025-06-05', '2025-06-08', 'online'),
('V1008', 'Helen Mirren', 'ID10000008', '+1-555-0108', '2025-06-03', '2025-06-04', 'onsite'),
('V1009', 'Ian McKellen', 'ID10000009', '+1-555-0109', '2025-06-06', '2025-06-09', 'online'),
('V1010', 'Julia Roberts', 'ID10000010', '+1-555-0110', '2025-06-01', '2025-06-02', 'onsite'),
('V1011', 'Kevin Spacey', 'ID10000011', '+1-555-0111', '2025-06-07', '2025-06-10', 'online'),
('V1012', 'Laura Linney', 'ID10000012', '+1-555-0112', '2025-06-04', '2025-06-06', 'online'),
('V1013', 'Michael Caine', 'ID10000013', '+1-555-0113', '2025-06-02', '2025-06-03', 'onsite'),
('V1014', 'Natalie Portman', 'ID10000014', '+1-555-0114', '2025-06-05', '2025-06-07', 'online'),
('V1015', 'Orlando Bloom', 'ID10000015', '+1-555-0115', '2025-06-03', '2025-06-05', 'online'),
('V1016', 'Penelope Cruz', 'ID10000016', '+1-555-0116', '2025-06-06', '2025-06-08', 'onsite'),
('V1017', 'Quentin Tarantino', 'ID10000017', '+1-555-0117', '2025-06-01', '2025-06-04', 'online'),
('V1018', 'Rachel McAdams', 'ID10000018', '+1-555-0118', '2025-06-04', '2025-06-05', 'onsite'),
('V1019', 'Samuel L Jackson', 'ID10000019', '+1-555-0119', '2025-06-07', '2025-06-09', 'online'),
('V1020', 'Tilda Swinton', 'ID10000020', '+1-555-0120', '2025-06-02', '2025-06-06', 'online');

-- Reservation
INSERT IGNORE INTO Reservation (reservation_id, visitor_id, reservation_date, entry_time_slot, group_size, reservation_status, ticket_amount, payment_status) VALUES
('RES001', 'V1001', '2025-05-25', '09:00-11:00', 2, 'completed', 40.00, 'paid'),
('RES002', 'V1002', '2025-05-26', '13:00-15:00', 1, 'completed', 20.00, 'paid'),
('RES003', 'V1003', '2025-05-27', '10:00-12:00', 3, 'confirmed', 60.00, 'pending'),
('RES004', 'V1004', '2025-05-24', '08:00-10:00', 2, 'completed', 40.00, 'paid'),
('RES005', 'V1005', '2025-05-28', '14:00-16:00', 1, 'completed', 20.00, 'paid'),
('RES006', 'V1006', '2025-05-26', '11:00-13:00', 4, 'confirmed', 80.00, 'paid'),
('RES007', 'V1007', '2025-05-29', '09:00-11:00', 2, 'completed', 40.00, 'paid'),
('RES008', 'V1008', '2025-05-27', '15:00-17:00', 1, 'completed', 20.00, 'paid'),
('RES009', 'V1009', '2025-05-30', '10:00-12:00', 2, 'confirmed', 40.00, 'pending'),
('RES010', 'V1010', '2025-05-24', '16:00-18:00', 1, 'completed', 20.00, 'paid'),
('RES011', 'V1011', '2025-06-01', '09:00-11:00', 3, 'confirmed', 60.00, 'paid'),
('RES012', 'V1012', '2025-05-28', '13:00-15:00', 2, 'completed', 40.00, 'paid'),
('RES013', 'V1013', '2025-05-26', '14:00-16:00', 1, 'completed', 20.00, 'paid'),
('RES014', 'V1014', '2025-05-29', '11:00-13:00', 2, 'confirmed', 40.00, 'pending'),
('RES015', 'V1015', '2025-05-27', '10:00-12:00', 2, 'completed', 40.00, 'paid'),
('RES016', 'V1016', '2025-05-30', '15:00-17:00', 1, 'completed', 20.00, 'paid'),
('RES017', 'V1017', '2025-05-24', '08:00-10:00', 2, 'completed', 40.00, 'paid'),
('RES018', 'V1018', '2025-05-28', '16:00-18:00', 1, 'completed', 20.00, 'paid'),
('RES019', 'V1019', '2025-06-01', '13:00-15:00', 2, 'confirmed', 40.00, 'paid'),
('RES020', 'V1020', '2025-05-26', '09:00-11:00', 3, 'completed', 60.00, 'paid');

-- VisitorTrajectory (simulate GPS points)
INSERT IGNORE INTO VisitorTrajectory (trajectory_id, visitor_id, location_time, longitude, latitude, region_id, is_out_of_route) VALUES
('T001', 'V1001', '2025-06-01 09:15:00', -110.5885, 44.4280, 'R001', FALSE),
('T002', 'V1001', '2025-06-01 10:30:00', -110.5900, 44.4300, 'R001', FALSE),
('T003', 'V1002', '2025-06-02 13:20:00', -119.5622, 37.7456, 'R002', FALSE),
('T004', 'V1003', '2025-06-03 10:10:00', -112.1400, 36.0544, 'R003', TRUE),
('T005', 'V1004', '2025-06-01 08:30:00', -119.5622, 37.7456, 'R002', FALSE),
('T006', 'V1005', '2025-06-04 14:15:00', -111.8200, 37.2100, 'R004', FALSE),
('T007', 'V1006', '2025-06-02 11:45:00', -80.8919, 25.2870, 'R006', FALSE),
('T008', 'V1007', '2025-06-05 09:05:00', -68.2100, 44.3385, 'R007', FALSE),
('T009', 'V1008', '2025-06-03 15:30:00', -105.6830, 40.3428, 'R008', FALSE),
('T010', 'V1009', '2025-06-06 10:20:00', -123.7000, 47.8020, 'R009', FALSE),
('T011', 'V1010', '2025-06-01 16:10:00', -109.5600, 38.7330, 'R010', FALSE),
('T012', 'V1011', '2025-06-07 09:25:00', -110.5885, 44.4280, 'R001', FALSE),
('T013', 'V1012', '2025-06-04 13:40:00', -119.5622, 37.7456, 'R002', TRUE),
('T014', 'V1013', '2025-06-02 14:05:00', -112.1400, 36.0544, 'R003', FALSE),
('T015', 'V1014', '2025-06-05 11:15:00', -111.8200, 37.2100, 'R004', FALSE),
('T016', 'V1015', '2025-06-03 10:50:00', -80.8919, 25.2870, 'R006', FALSE),
('T017', 'V1016', '2025-06-06 15:20:00', -68.2100, 44.3385, 'R007', FALSE),
('T018', 'V1017', '2025-06-01 08:45:00', -105.6830, 40.3428, 'R008', FALSE),
('T019', 'V1018', '2025-06-04 16:30:00', -123.7000, 47.8020, 'R009', FALSE),
('T020', 'V1019', '2025-06-07 13:10:00', -109.5600, 38.7330, 'R010', TRUE);