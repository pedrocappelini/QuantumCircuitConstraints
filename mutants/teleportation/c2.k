import ...metamodel
import ...constraints

# F2 — C2 Node Existence
# Undefined target node referenced by a flow.
teleportation_faulty_f2 = metamodel.QuantumCircuit {
    name = "Teleportation_F2_C2"
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
    ]

    flows = [
        metamodel.Flow {source = "init", target = "g1"},
        metamodel.Flow {source = "g1",   target = "ghost_node"},
        metamodel.Flow {source = "g1",   target = "final"},
    ]
}

validation_f2 = constraints.CircuitValidation {
    circuit = teleportation_faulty_f2
}
