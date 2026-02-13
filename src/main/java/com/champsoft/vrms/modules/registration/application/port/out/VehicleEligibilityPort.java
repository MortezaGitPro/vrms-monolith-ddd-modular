package com.champsoft.vrms.modules.registration.application.port.out;

public interface VehicleEligibilityPort {
    boolean isEligible(String vehicleId);
}
