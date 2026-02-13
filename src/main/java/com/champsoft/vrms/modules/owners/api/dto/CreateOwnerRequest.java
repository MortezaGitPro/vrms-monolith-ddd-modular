package com.champsoft.vrms.modules.owners.api.dto;

import jakarta.validation.constraints.NotBlank;

public record CreateOwnerRequest(
        @NotBlank String fullName,
        String address) {}
