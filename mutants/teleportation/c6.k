import ...metamodel
import ...constraints

# F6 — C6 Measurement Integrity
# Measurement output does not correspond to a valid classical
# store in the circuit. Under the current metamodel, this also
# triggers C5 because output locality is structural.
teleportation_faulty_f6 = metamodel.QuantumCircuit {
    name = "Teleportation_F6_C6"
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
    ]

    measures = [
        metamodel.MeasureNode {id = "m1", qubit = "q0", basis = "Z", output = "cX"},
    ]

    flows = [
        metamodel.Flow {source = "init", target = "m1"},
        metamodel.Flow {source = "m1",   target = "final"},
    ]
}

validation_f6 = constraints.CircuitValidation {
    circuit = teleportation_faulty_f6
}
