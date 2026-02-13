package com.champsoft.vrms.modules.agents.api.dto;

import com.champsoft.vrms.modules.agents.domain.model.Role;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record UpdateAgentRequest(
        @NotBlank String name,
        @NotNull Role role) {}

