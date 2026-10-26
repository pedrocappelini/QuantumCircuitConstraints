import ...metamodel
import ...constraints

# F4 — C4 Control-Target Disjointness
# Same qubit used as control and target in a controlled gate.
teleportation_faulty_f4 = metamodel.QuantumCircuit {
    name = "Teleportation_F4_C4"
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
        metamodel.GateNode {id = "g1", gateType = "CNOT", targets = ["q1"], controls = ["q1"]},
    ]

    flows = [
        metamodel.Flow {source = "init", target = "g1"},
        metamodel.Flow {source = "g1",   target = "final"},
    ]
}

validation_f4 = constraints.CircuitValidation {
    circuit = teleportation_faulty_f4
}
