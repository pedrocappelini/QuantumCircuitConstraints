import ...metamodel
import ...constraints

# F3 — C3 Qubit Binding
# Gate declared without targets or controls.
teleportation_faulty_f3 = metamodel.QuantumCircuit {
    name = "Teleportation_F3_C3"
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
        metamodel.GateNode {id = "g1", gateType = "Custom", targets = [], controls = []},
    ]

    flows = [
        metamodel.Flow {source = "init", target = "g1"},
        metamodel.Flow {source = "g1",   target = "final"},
    ]
}

validation_f3 = constraints.CircuitValidation {
    circuit = teleportation_faulty_f3
}
