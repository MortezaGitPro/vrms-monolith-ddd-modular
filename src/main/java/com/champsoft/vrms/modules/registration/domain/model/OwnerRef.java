package com.champsoft.vrms.modules.registration.domain.model;

public record OwnerRef(String value) {
    public OwnerRef {
        if (value == null) throw new IllegalArgumentException("ownerId is required");
        value = value.trim();
        if (value.isEmpty()) throw new IllegalArgumentException("ownerId is required");
    }
}
