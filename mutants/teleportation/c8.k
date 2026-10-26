import ...metamodel
import ...constraints

# F8 — C8 Control-Flow Anchoring
# No incoming flow reaches the FinalNode.
teleportation_faulty_f8 = metamodel.QuantumCircuit {
    name = "Teleportation_F8_C8"
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
        metamodel.GateNode {id = "g1", gateType = "H", targets = ["q1"]},
        metamodel.GateNode {id = "g2", gateType = "X", targets = ["q2"]},
    ]

    flows = [
        metamodel.Flow {source = "init", target = "g1"},
        metamodel.Flow {source = "g1",   target = "g2"},
    ]
}

validation_f8 = constraints.CircuitValidation {
    circuit = teleportation_faulty_f8
}
