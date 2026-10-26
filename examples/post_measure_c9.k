import ..metamodel
import ..constraints

# ============================================================
# simple_post_measure_fault.k
# ------------------------------------------------------------
# A standalone, minimal circuit demonstrating a violation of
# the C9 constraint. It measures a qubit and then illegally
# attempts to apply an X gate to it afterwards.
# ============================================================

invalid_post_measure_circuit = metamodel.QuantumCircuit {
    name = "Simple_Post_Measurement_Error"
    numQubits = 1
    ordering = "little"

    qubits = [
        metamodel.Qubit {id = "q0", index = 0, kind = "data"}
    ]

    initialNode = metamodel.InitialNode {id = "init"}
    finalNode   = metamodel.FinalNode   {id = "final"}

    classicalStores = [
        metamodel.ClassicalStore {name = "c0"}
    ]

    # 1. Measure q0 and store result in c0
    measures = [
        metamodel.MeasureNode {id = "m1", qubit = "q0", basis = "Z", output = "c0"}
    ]

    # 2. Attempt to apply a gate to q0 (FAULT: C9 Violation)
    gates = [
        metamodel.GateNode {id = "g1", gateType = "X", targets = ["q0"]}
    ]

    # The flow clearly shows the gate happening AFTER the measurement
    flows = [
        metamodel.Flow {source = "init", target = "m1"},
        metamodel.Flow {source = "m1",   target = "g1"},
        metamodel.Flow {source = "g1",   target = "final"}
    ]
}

validation_c9 = constraints.CircuitValidation {
    circuit = invalid_post_measure_circuit
}
