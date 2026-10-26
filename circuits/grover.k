# ============================================================
# grover.k
# Grover's search, 2 qubits (N = 4), marked state |11>, 1 iteration.
# With N = 4 a single iteration finds the marked item with probability 1.
#
#         |---- oracle ----|  |---------- diffusion ----------|
#   q0: ─H────────■──────────H───Z───────■──────H────────M
#   q1: ─H────────■──────────H───Z───────■──────H────────M
#
# Expected result: measurement always yields "11".
# ============================================================

import ..metamodel
import ..constraints

grover = metamodel.QuantumCircuit {
    name = "Grover2Q"
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
        metamodel.GateNode {id = "h_q0_init", gateType = "H", targets = ["q0"]},
        metamodel.GateNode {id = "h_q1_init", gateType = "H", targets = ["q1"]},

        metamodel.GateNode {id = "oracle_cz", gateType = "CZ", targets = ["q1"], controls = ["q0"]},

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
        metamodel.Flow {source = "cz_diff", target = "h_q0_diff_out"},
        metamodel.Flow {source = "h_q0_diff_out", target = "h_q1_diff_out"},
        metamodel.Flow {source = "h_q1_diff_out", target = "m_q0"},
        metamodel.Flow {source = "m_q0", target = "m_q1"},
        metamodel.Flow {source = "m_q1", target = "final"}
    ]
}

validation = constraints.CircuitValidation {
    circuit = grover
}
