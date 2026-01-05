-- sql/INDEX/30_visitor_indexes.sql

-- INDEX 1: Reservation 表上的 reservation_date
CREATE INDEX idx_reservation_date ON Reservation(reservation_date);

-- INDEX 2: VisitorTrajectory 表上的 location_time 和 region_id
CREATE INDEX idx_trajectory_location_time_region ON VisitorTrajectory(location_time, region_id);

-- INDEX 3: Visitor 表上的 visitor_id
CREATE INDEX idx_visitor_id ON Visitor(visitor_id);

-- INDEX 4: FlowControl 表上的 region_id
CREATE INDEX idx_flowcontrol_region ON FlowControl(region_id);