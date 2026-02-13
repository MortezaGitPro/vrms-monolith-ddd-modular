package com.champsoft.vrms.modules.cars.api.dto;

import jakarta.validation.constraints.*;

public record CreateVehicleRequest(
        @NotBlank String vin,
        @NotBlank String make,
        @NotBlank String model,
        @Min(1980) @Max(2050) int year) {}
