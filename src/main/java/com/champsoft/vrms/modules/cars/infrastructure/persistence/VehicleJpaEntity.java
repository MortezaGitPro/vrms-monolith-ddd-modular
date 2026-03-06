package com.champsoft.vrms.modules.cars.infrastructure.persistence;

import jakarta.persistence.Column;
import jakarta.persistence.Embedded;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "vehicles")
public class VehicleJpaEntity {
    @Id
    public String id;

    @Column(nullable = false, unique = true)
    public String vin;

    @Embedded
    public VehicleSpecsEmbeddable specs;

    @Column(nullable = false)
    public String status;
}