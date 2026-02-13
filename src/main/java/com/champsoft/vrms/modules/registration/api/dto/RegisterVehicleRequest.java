package com.champsoft.vrms.modules.registration.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.time.LocalDate;

public record RegisterVehicleRequest(
        @NotBlank String vehicleId,
        @NotBlank String ownerId,
        @NotBlank String agentId,
        @NotBlank String plate,
        @NotNull LocalDate expiry) {}
