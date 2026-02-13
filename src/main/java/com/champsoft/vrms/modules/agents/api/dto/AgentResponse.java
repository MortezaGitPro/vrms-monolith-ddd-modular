package com.champsoft.vrms.modules.agents.api.dto;

public record AgentResponse(
        String id,
        String name,
        String role,
        String status) {}
