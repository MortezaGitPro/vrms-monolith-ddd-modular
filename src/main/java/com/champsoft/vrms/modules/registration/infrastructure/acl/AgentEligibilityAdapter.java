package com.champsoft.vrms.modules.registration.infrastructure.acl;

import com.champsoft.vrms.modules.agents.application.service.AgentEligibilityService;
import com.champsoft.vrms.modules.registration.application.port.out.AgentEligibilityPort;
import org.springframework.stereotype.Component;

@Component
public class AgentEligibilityAdapter implements AgentEligibilityPort {

    private final AgentEligibilityService agentsEligibility;

    public AgentEligibilityAdapter(AgentEligibilityService agentsEligibility) {
        this.agentsEligibility = agentsEligibility;
    }

    @Override
    public boolean isEligible(String agentId) {
        return agentsEligibility.isEligible(agentId);
    }
}
