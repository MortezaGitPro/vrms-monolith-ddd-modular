package com.champsoft.vrms.modules.cars.domain.exception;

public class VehicleAlreadyActiveException extends RuntimeException {
    public VehicleAlreadyActiveException(String message) { super(message); }
}
