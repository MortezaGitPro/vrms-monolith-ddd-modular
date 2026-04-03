-- Flyway init schema (tables for vehicle/owner/agent/registration)
-- NOTE: H2 is used in-memory (see application.yml), so we keep this H2-friendly.

CREATE TABLE IF NOT EXISTS vehicles (
    id VARCHAR(36) PRIMARY KEY,
    vin VARCHAR(32) NOT NULL UNIQUE,
    make VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    vehicle_year INT NOT NULL,
    status VARCHAR(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS owners (
    id VARCHAR(36) PRIMARY KEY,
    full_name VARCHAR(120) NOT NULL,
    address VARCHAR(200),
    status VARCHAR(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS agents (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    role VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS registrations (
    id VARCHAR(36) PRIMARY KEY,
    vehicle_id VARCHAR(36) NOT NULL,
    owner_id VARCHAR(36) NOT NULL,
    agent_id VARCHAR(36) NOT NULL,
    plate VARCHAR(16) NOT NULL UNIQUE,
    expiry DATE NOT NULL,
    status VARCHAR(20) NOT NULL,

    CONSTRAINT fk_registrations_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
    CONSTRAINT fk_registrations_owner FOREIGN KEY (owner_id) REFERENCES owners(id),
    CONSTRAINT fk_registrations_agent FOREIGN KEY (agent_id) REFERENCES agents(id)
);

-- Helpful indexes for lookups / joins
CREATE INDEX IF NOT EXISTS idx_registrations_vehicle_id ON registrations(vehicle_id);
CREATE INDEX IF NOT EXISTS idx_registrations_owner_id ON registrations(owner_id);
CREATE INDEX IF NOT EXISTS idx_registrations_agent_id ON registrations(agent_id);

INSERT INTO vehicles (id, vin, make, model, vehicle_year, status) VALUES
    ('veh-1', 'VIN0001ABCDEFGHJK', 'Toyota', 'Corolla', 2018, 'ACTIVE'),
    ('veh-2', 'VIN0002ABCDEFGHJK', 'Honda', 'Civic', 2019, 'ACTIVE'),
    ('veh-3', 'VIN0003ABCDEFGHJK', 'Ford', 'Focus', 2017, 'ACTIVE'),
    ('veh-4', 'VIN0004ABCDEFGHJK', 'BMW', '320i', 2020, 'ACTIVE'),
    ('veh-5', 'VIN0005ABCDEFGHJK', 'Audi', 'A4', 2021, 'ACTIVE'),
    ('veh-6', 'VIN0006ABCDEFGHJK', 'Hyundai', 'Elantra', 2018, 'ACTIVE'),
    ('veh-7', 'VIN0007ABCDEFGHJK', 'Kia', 'Forte', 2019, 'ACTIVE'),
    ('veh-8', 'VIN0008ABCDEFGHJK', 'Mazda', 'Mazda3', 2020, 'ACTIVE'),
    ('veh-9', 'VIN0009ABCDEFGHJK', 'Nissan', 'Sentra', 2017, 'ACTIVE'),
    ('veh-10','VIN0010ABCDEFGHJK', 'Volkswagen', 'Jetta', 2021, 'ACTIVE');

INSERT INTO owners (id, full_name, address, status) VALUES
    ('own-1', 'John Smith', 'Montreal, QC', 'ACTIVE'),
    ('own-2', 'Sarah Johnson', 'Laval, QC', 'ACTIVE'),
    ('own-3', 'Michael Brown', 'Longueuil, QC', 'ACTIVE'),
    ('own-4', 'Emily Davis', 'Brossard, QC', 'ACTIVE'),
    ('own-5', 'David Wilson', 'Montreal, QC', 'ACTIVE'),
    ('own-6', 'Laura Martinez', 'Laval, QC', 'ACTIVE'),
    ('own-7', 'James Anderson', 'Montreal, QC', 'ACTIVE'),
    ('own-8', 'Olivia Taylor', 'Longueuil, QC', 'ACTIVE'),
    ('own-9', 'Daniel Thomas', 'Brossard, QC', 'ACTIVE'),
    ('own-10','Sophia Moore', 'Montreal, QC', 'ACTIVE');

INSERT INTO agents (id, name, role, status) VALUES
    ('agent-1', 'Alice Martin', 'CLERK', 'ACTIVE'),
    ('agent-2', 'Robert Lee', 'SUPERVISOR', 'ACTIVE');

INSERT INTO registrations (id, vehicle_id, owner_id, agent_id, plate, expiry, status) VALUES
    ('reg-1', 'veh-1', 'own-1', 'agent-1', 'QC-1001', DATE '2027-12-31', 'ACTIVE'),
    ('reg-2', 'veh-2', 'own-2', 'agent-1', 'QC-1002', DATE '2028-11-30', 'ACTIVE'),
    ('reg-3', 'veh-3', 'own-3', 'agent-1', 'QC-1003', DATE '2028-10-31', 'ACTIVE'),
    ('reg-4', 'veh-4', 'own-4', 'agent-1', 'QC-1004', DATE '2028-09-30', 'ACTIVE'),
    ('reg-5', 'veh-5', 'own-5', 'agent-1', 'QC-1005', DATE '2028-08-31', 'ACTIVE'),
    ('reg-6', 'veh-6', 'own-6', 'agent-2', 'QC-1006', DATE '2026-07-31', 'ACTIVE'),
    ('reg-7', 'veh-7', 'own-7', 'agent-2', 'QC-1007', DATE '2026-06-30', 'ACTIVE'),
    ('reg-8', 'veh-8', 'own-8', 'agent-2', 'QC-1008', DATE '2026-05-31', 'ACTIVE'),
    ('reg-9', 'veh-9', 'own-9', 'agent-2', 'QC-1009', DATE '2026-04-30', 'ACTIVE'),
    ('reg-10','veh-10','own-10','agent-2','QC-1010', DATE '2026-03-31', 'ACTIVE');