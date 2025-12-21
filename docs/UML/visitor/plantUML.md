@startuml
hide circle
skinparam classAttributeIconSize 0
skinparam classFontSize 11
skinparam relationFontSize 10
skinparam enumFontSize 10
skinparam backgroundColor #FFFFFF
skinparam classBorderColor #333333
skinparam enumBorderColor #333333
skinparam lineColor #666666


enum EntryMethod {
    online_reservation  
    on-site_ticket   
}

enum ReservationStatus {
    confirmed  
    cancelled   
    completed   
}

enum PaymentStatus {
    paid        
    unpaid     
}

enum FlowStatus {
    normal     
    warning   
    restricted  
}


class Visitor {
    + visitor_id: String (PK)         
    + visitor_name: String            
    + id_number: String (UNIQUE)      
    + contact_number: String           
    + reservation_id: String (FK)      
    + entry_time: Date                
    + exit_time: Date                 
    + entry_method: EntryMethod       
}

class Reservation {
    + reservation_id: String (PK)     
    + visitor_id: String (FK)          
    + reservation_date: Date           
    + entry_time_slot: String          
    + group_size: Integer             
    + reservation_status: ReservationStatus 
    + ticket_amount: Double            
    + payment_status: PaymentStatus    
}

class VisitorTrajectory {
    + trajectory_id: String (PK)     
    + visitor_id: String (FK)          
    + location_time: Date              
    + longitude: Double              
    + latitude: Double                
    + area_id: String (FK)            
    + is_out_of_route: Boolean         
}

class FlowControl {
    + area_id: String (PK)            
    + daily_capacity: Integer          
    + current_visitor_count: Integer   
    + warning_threshold: Integer       
    + flow_status: FlowStatus          
}


Visitor "1" -- "*" Reservation : has (via visitor_id)
Visitor "1" -- "*" VisitorTrajectory : generates (via visitor_id)
VisitorTrajectory "*" -- "1" FlowControl : belongs to (via area_id)

@enduml