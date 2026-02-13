package com.champsoft.vrms.modules.owners.api.mapper;

import com.champsoft.vrms.modules.owners.api.dto.OwnerResponse;
import com.champsoft.vrms.modules.owners.domain.model.Owner;

public class OwnerApiMapper {
    public static OwnerResponse toResponse(Owner o) {
        return new OwnerResponse(
                o.id().value(),
                o.fullName().value(),
                o.address().value(),
                o.status().name()
        );
    }
}
