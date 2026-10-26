# ============================================================
# grover_mutant.k  -- mutant of grover.k
# MUTATION: the measurement of q0 is moved BEFORE the last Hadamard on q0
#           (premature measurement).
# EXPECTED: fails C9 (gate applied to a qubit after it was already measured)
# ============================================================

import ...metamodel
import ...constraints

groverMutant = metamodel.QuantumCircuit {
    name = "Grover2Q_Mutant"
    numQubits = 2
    ordering = "little"

    qubits = [
        metamodel.Qubit {id = "q0", index = 0, kind = "data"},
        metamodel.Qubit {id = "q1", index = 1, kind = "data"}
    ]

    initialNode = metamodel.InitialNode {id = "init"}
    finalNode = metamodel.FinalNode {id = "final"}

    classicalStores = [
        metamodel.ClassicalStore {name = "c0"},
        metamodel.ClassicalStore {name = "c1"}
    ]

    gates = [
        # 1. Uniform superposition
        metamodel.GateNode {id = "h_q0_init", gateType = "H", targets = ["q0"]},
        metamodel.GateNode {id = "h_q1_init", gateType = "H", targets = ["q1"]},

        # 2. Oracle: flips the sign of |11>
        metamodel.GateNode {id = "oracle_cz", gateType = "CZ", targets = ["q1"], controls = ["q0"]},

        # 3. Diffusion operator (reflection about |00>, conjugated by H)
        metamodel.GateNode {id = "h_q0_diff_in", gateType = "H", targets = ["q0"]},
        metamodel.GateNode {id = "h_q1_diff_in", gateType = "H", targets = ["q1"]},
        metamodel.GateNode {id = "z_q0_diff", gateType = "Z", targets = ["q0"]},
        metamodel.GateNode {id = "z_q1_diff", gateType = "Z", targets = ["q1"]},
        metamodel.GateNode {id = "cz_diff", gateType = "CZ", targets = ["q1"], controls = ["q0"]},
        metamodel.GateNode {id = "h_q0_diff_out", gateType = "H", targets = ["q0"]},
        metamodel.GateNode {id = "h_q1_diff_out", gateType = "H", targets = ["q1"]}
    ]

    measures = [
        metamodel.MeasureNode {id = "m_q0", qubit = "q0", output = "c0"},
        metamodel.MeasureNode {id = "m_q1", qubit = "q1", output = "c1"}
    ]

    flows = [
        metamodel.Flow {source = "init", target = "h_q0_init"},
        metamodel.Flow {source = "h_q0_init", target = "h_q1_init"},
        metamodel.Flow {source = "h_q1_init", target = "oracle_cz"},
        metamodel.Flow {source = "oracle_cz", target = "h_q0_diff_in"},
        metamodel.Flow {source = "h_q0_diff_in", target = "h_q1_diff_in"},
        metamodel.Flow {source = "h_q1_diff_in", target = "z_q0_diff"},
        metamodel.Flow {source = "z_q0_diff", target = "z_q1_diff"},
        metamodel.Flow {source = "z_q1_diff", target = "cz_diff"},
        metamodel.Flow {source = "cz_diff", target = "m_q0"},                # <<< MUTATION: m_q0 moved up
        metamodel.Flow {source = "m_q0", target = "h_q0_diff_out"},          # <<< MUTATION
        metamodel.Flow {source = "h_q0_diff_out", target = "h_q1_diff_out"},
        metamodel.Flow {source = "h_q1_diff_out", target = "m_q1"},          # <<< MUTATION
        metamodel.Flow {source = "m_q1", target = "final"}
    ]
}

validation = constraints.CircuitValidation {
    circuit = groverMutant
}
