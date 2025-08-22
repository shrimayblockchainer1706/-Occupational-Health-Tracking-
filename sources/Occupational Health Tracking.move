module HealthModule::OccupationalHealthTracking {
    use aptos_framework::signer;
    use aptos_framework::timestamp;

    /// Struct representing an employee's health record
    struct HealthRecord has store, key {
        employee_id: u64,           // Unique employee identifier
        last_checkup_date: u64,     // Timestamp of last health checkup
        health_score: u8,           // Health score (1-10, 10 being excellent)
        incidents_count: u64,       // Number of workplace incidents reported
        medical_clearance: bool,    // Medical clearance status for work
    }

    /// Error codes
    const E_HEALTH_RECORD_NOT_FOUND: u64 = 1;
    const E_INVALID_HEALTH_SCORE: u64 = 2;
    const E_UNAUTHORIZED_ACCESS: u64 = 3;

    /// Function to initialize a health record for an employee
    public fun create_health_record(
        employer: &signer, 
        employee_id: u64, 
        initial_health_score: u8
    ) {
        // Validate health score is between 1 and 10
        assert!(initial_health_score >= 1 && initial_health_score <= 10, E_INVALID_HEALTH_SCORE);
        
        let health_record = HealthRecord {
            employee_id,
            last_checkup_date: timestamp::now_seconds(),
            health_score: initial_health_score,
            incidents_count: 0,
            medical_clearance: true,
        };
        
        move_to(employer, health_record);
    }

    /// Function to update employee health data after checkup or incident
    public fun update_health_data(
        employer: &signer,
        employee_address: address,
        new_health_score: u8,
        incident_occurred: bool,
        medical_clearance: bool
    ) acquires HealthRecord {
        // Validate health score
        assert!(new_health_score >= 1 && new_health_score <= 10, E_INVALID_HEALTH_SCORE);
        
        // Get mutable reference to health record
        let health_record = borrow_global_mut<HealthRecord>(employee_address);
        
        // Update health data
        health_record.last_checkup_date = timestamp::now_seconds();
        health_record.health_score = new_health_score;
        health_record.medical_clearance = medical_clearance;
        
        // Increment incident count if incident occurred
        if (incident_occurred) {
            health_record.incidents_count = health_record.incidents_count + 1;
        };
    }
}