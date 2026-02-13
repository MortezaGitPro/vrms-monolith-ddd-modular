package com.champsoft.vrms.modules.registration.infrastructure.acl;

import com.champsoft.vrms.modules.cars.application.service.VehicleEligibilityService;
import com.champsoft.vrms.modules.registration.application.port.out.VehicleEligibilityPort;
import org.springframework.stereotype.Component;

@Component
public class VehicleEligibilityAdapter implements VehicleEligibilityPort {

    private final VehicleEligibilityService carsEligibility;

    public VehicleEligibilityAdapter(VehicleEligibilityService carsEligibility) {
        this.carsEligibility = carsEligibility;
    }

    @Override
    public boolean isEligible(String vehicleId) {
        return carsEligibility.isEligible(vehicleId);
    }
}
