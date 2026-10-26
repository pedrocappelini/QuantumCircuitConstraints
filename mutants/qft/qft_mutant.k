# ============================================================
# qft_mutant.k  -- mutant of qft.k
# MUTATION: the first controlled-phase gate (cp_q1_q0) uses q0 as BOTH
#           control and target (typical off-by-one in the loop index).
# EXPECTED: fails C4 (control and target qubits must be disjoint)
# ============================================================

import ...metamodel
import ...constraints

qftMutant = metamodel.QuantumCircuit {
    name = "QFT3_Mutant"
    numQubits = 3
    ordering = "big"

    qubits = [
        metamodel.Qubit {id = "q0", index = 0, kind = "data"},
        metamodel.Qubit {id = "q1", index = 1, kind = "data"},
        metamodel.Qubit {id = "q2", index = 2, kind = "data"}
    ]

    initialNode = metamodel.InitialNode {id = "init"}
    finalNode = metamodel.FinalNode {id = "final"}

    gates = [
        # Block for q0
        metamodel.GateNode {id = "h_q0", gateType = "H", targets = ["q0"]},
        # >>> MUTATION: controls = ["q0"] (was ["q1"])
        metamodel.GateNode {id = "cp_q1_q0", gateType = "Custom", targets = ["q0"], controls = ["q0"], decompositionName = "CP(pi/2)"},
        metamodel.GateNode {id = "cp_q2_q0", gateType = "Custom", targets = ["q0"], controls = ["q2"], decompositionName = "CP(pi/4)"},

        # Block for q1
        metamodel.GateNode {id = "h_q1", gateType = "H", targets = ["q1"]},
        metamodel.GateNode {id = "cp_q2_q1", gateType = "Custom", targets = ["q1"], controls = ["q2"], decompositionName = "CP(pi/2)"},

        # Block for q2
        metamodel.GateNode {id = "h_q2", gateType = "H", targets = ["q2"]},

        # Bit reversal
        metamodel.GateNode {id = "swap_q0_q2", gateType = "SWAP", targets = ["q0", "q2"]}
    ]

    flows = [
        metamodel.Flow {source = "init", target = "h_q0"},
        metamodel.Flow {source = "h_q0", target = "cp_q1_q0"},
        metamodel.Flow {source = "cp_q1_q0", target = "cp_q2_q0"},
        metamodel.Flow {source = "cp_q2_q0", target = "h_q1"},
        metamodel.Flow {source = "h_q1", target = "cp_q2_q1"},
        metamodel.Flow {source = "cp_q2_q1", target = "h_q2"},
        metamodel.Flow {source = "h_q2", target = "swap_q0_q2"},
        metamodel.Flow {source = "swap_q0_q2", target = "final"}
    ]
}

validation = constraints.CircuitValidation {
    circuit = qftMutant
}
