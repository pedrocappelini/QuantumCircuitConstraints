import ...metamodel
import ...constraints

# F7 — C7 Classical Dependency Safety
# Classically controlled gate depends on an existing classical
# store that is never produced by any preceding measurement.
teleportation_faulty_f7 = metamodel.QuantumCircuit {
    name = "Teleportation_F7_C7"
    numQubits = 3
    ordering = "little"

    qubits = [
        metamodel.Qubit {id = "q0", index = 0, kind = "data"},
        metamodel.Qubit {id = "q1", index = 1, kind = "ancilla"},
        metamodel.Qubit {id = "q2", index = 2, kind = "data"},
    ]

    initialNode = metamodel.InitialNode {id = "init"}
    finalNode   = metamodel.FinalNode   {id = "final"}

    classicalStores = [
        metamodel.ClassicalStore {name = "c0"},
        metamodel.ClassicalStore {name = "c1"},
    ]

    gates = [
        metamodel.GateNode {id = "g1", gateType = "H", targets = ["q1"]},
        metamodel.GateNode {id = "g2", gateType = "X", targets = ["q2"], classicalDependsOn = ["c1"]},
    ]

    measures = [
        metamodel.MeasureNode {id = "m1", qubit = "q0", basis = "Z", output = "c0"},
    ]

    flows = [
        metamodel.Flow {source = "init", target = "g1"},
        metamodel.Flow {source = "g1",   target = "m1"},
        metamodel.Flow {source = "m1",   target = "g2"},
        metamodel.Flow {source = "g2",   target = "final"},
    ]
}

validation_f7 = constraints.CircuitValidation {
    circuit = teleportation_faulty_f7
}
