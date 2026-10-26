import ...metamodel
import ...constraints

# F5 — C5 Resource Locality
# Gate references a qubit that does not belong to the circuit.
teleportation_faulty_f5 = metamodel.QuantumCircuit {
    name = "Teleportation_F5_C5"
    numQubits = 3
    ordering = "little"

    qubits = [
        metamodel.Qubit {id = "q0", index = 0, kind = "data"},
        metamodel.Qubit {id = "q1", index = 1, kind = "ancilla"},
        metamodel.Qubit {id = "q2", index = 2, kind = "data"},
    ]

    initialNode = metamodel.InitialNode {id = "init"}
    finalNode   = metamodel.FinalNode   {id = "final"}

    gates = [
        metamodel.GateNode {id = "g1", gateType = "X", targets = ["q9"]},
    ]

    flows = [
        metamodel.Flow {source = "init", target = "g1"},
        metamodel.Flow {source = "g1",   target = "final"},
    ]
}

validation_f5 = constraints.CircuitValidation {
    circuit = teleportation_faulty_f5
}
