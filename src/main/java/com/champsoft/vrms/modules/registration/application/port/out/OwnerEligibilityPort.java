package com.champsoft.vrms.modules.registration.application.port.out;

public interface OwnerEligibilityPort {
    boolean isEligible(String ownerId);
}
