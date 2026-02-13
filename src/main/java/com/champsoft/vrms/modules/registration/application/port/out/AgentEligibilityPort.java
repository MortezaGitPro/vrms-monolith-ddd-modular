package com.champsoft.vrms.modules.registration.application.port.out;

public interface AgentEligibilityPort {
    boolean isEligible(String agentId);
}
