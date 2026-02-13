package com.champsoft.vrms.modules.cars.infrastructure.persistence;

import jakarta.persistence.*;

@Entity
@Table(name = "vehicles")
public class VehicleJpaEntity {
    @Id
    public String id;

    @Column(nullable = false, unique = true)
    public String vin;

    @Column(nullable = false)
    public String make;

    @Column(nullable = false)
    public String model;

    @Column(nullable = false)
    public int vehicle_year;

    @Column(nullable = false)
    public String status;
}
