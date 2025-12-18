```plantUML
@startuml
skinparam classAttributeIconSize 0

' ===== Enums =====
enum RecordStatus {
  pending
  rechecked
  valid
}

enum MonitoringMethod {
  camera
  manual
  drone
}

enum ProtectionLevel {
  first_class
  second_class
  none
}

enum UserRole {
  ecological_monitor
  data_analyst
}

' ===== Core Classes =====
class Species {
  +species_id: String <<PK>>
  +species_name_cn: String
  +species_name_latin: String
  +kingdom: String
  +phylum: String
  +tax_class: String
  +tax_order: String
  +family: String
  +genus: String
  +species: String
  +protection_level: ProtectionLevel
  +living_habits: Text
  +distribution_description: Text
  +habitat_id: String <<FK>>  ' optional
}

class Habitat {
  +habitat_id: String <<PK>>
  +area_name: String
  +ecological_type: String
  +area_size: Decimal
  +core_protection_area: Text
  +environment_suitability_score: Decimal
}

class HabitatPrimarySpecies {
  +habitat_id: String <<PK, FK>>
  +species_id: String <<PK, FK>>
  +is_primary: Boolean
}

class MonitoringRecord {
  +record_id: String <<PK>>
  +species_id: String <<FK>>
  +device_id: String <<FK>>  ' nullable
  +monitoring_time: DateTime
  +longitude: Decimal
  +latitude: Decimal
  +monitoring_method: MonitoringMethod
  +image_path: String
  +count_number: Integer
  +behavior_description: Text
  +recorder_id: String <<FK>>
  +status: RecordStatus
}

class MonitoringDevice {
  +device_id: String <<PK>>
  +device_type: String
  +deployed_area: String
  +status: String
}

class User {
  +user_id: String <<PK>>
  +user_name: String
  +role: UserRole
}



' ===== Relationships =====
Habitat "1" -- "0..*" Species : contains >
Species "0..1" -- "1" Habitat : belongs_to >

Habitat "1" -- "0..*" HabitatPrimarySpecies
Species "1" -- "0..*" HabitatPrimarySpecies

Species "1" -- "0..*" MonitoringRecord
MonitoringDevice "0..1" -- "0..*" MonitoringRecord
User "1" -- "0..*" MonitoringRecord : records >

@enduml

```
