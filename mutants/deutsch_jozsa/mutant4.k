# ============================================================
# mutant4.k  -- mutant of deutsch_jozsa.k
# ------------------------------------------------------------------
# MUTATION 1: a ResetNode targeting q2 (ancilla) is inserted at the
#             *start* of the circuit, before any operation touched q2,
#             violating C10 (reset on a qubit with no prior operation).
# MUTATION 2: the final flow edge (m_q1 -> final) is removed, so no
#             flow ever reaches the FinalNode, violating C8 (no
#             incoming flow to FinalNode).
#
# EXPECTED: fails C10 and C8.
# ============================================================

import ...metamodel
import ...constraints

deutschJozsaMutant4 = metamodel.QuantumCircuit {
    name = "DeutschJozsa_Mutant4"
    numQubits = 3
    ordering = "little"

    qubits = [
        metamodel.Qubit {id = "q0", index = 0, kind = "data"},
        metamodel.Qubit {id = "q1", index = 1, kind = "data"},
        metamodel.Qubit {id = "q2", index = 2, kind = "ancilla"}
    ]

    initialNode = metamodel.InitialNode {id = "init"}
    finalNode = metamodel.FinalNode {id = "final"}

    classicalStores = [
        metamodel.ClassicalStore {name = "c0"},
        metamodel.ClassicalStore {name = "c1"}
    ]

    # >>> MUTATION: reset on q2 before anything touches q2 (C10)
    resets = [
        metamodel.ResetNode {id = "reset_anc", qubit = "q2"}
    ]

    gates = [
        # Ancilla prepared in |1>
        metamodel.GateNode {id = "x_anc", gateType = "X", targets = ["q2"]},

        # Hadamard on every qubit
        metamodel.GateNode {id = "h_q0_in", gateType = "H", targets = ["q0"]},
        metamodel.GateNode {id = "h_q1_in", gateType = "H", targets = ["q1"]},
        metamodel.GateNode {id = "h_anc", gateType = "H", targets = ["q2"]},

        # Oracle U_f (balanced): CNOT(q0 -> q2), CNOT(q1 -> q2)
        metamodel.GateNode {id = "oracle_cx0", gateType = "CNOT", targets = ["q2"], controls = ["q0"]},
        metamodel.GateNode {id = "oracle_cx1", gateType = "CNOT", targets = ["q2"], controls = ["q1"]},

        # Hadamard on the input register before measuring
        metamodel.GateNode {id = "h_q0_out", gateType = "H", targets = ["q0"]},
        metamodel.GateNode {id = "h_q1_out", gateType = "H", targets = ["q1"]}
    ]

    measures = [
        metamodel.MeasureNode {id = "m_q0", qubit = "q0", output = "c0"},
        metamodel.MeasureNode {id = "m_q1", qubit = "q1", output = "c1"}
    ]

    flows = [
        # >>> MUTATION: reset runs first (C10)
        metamodel.Flow {source = "init", target = "reset_anc"}, #reset
        metamodel.Flow {source = "reset_anc", target = "x_anc"},
        metamodel.Flow {source = "x_anc", target = "h_q0_in"},
        metamodel.Flow {source = "h_q0_in", target = "h_q1_in"},
        metamodel.Flow {source = "h_q1_in", target = "h_anc"},
        metamodel.Flow {source = "h_anc", target = "oracle_cx0"},
        metamodel.Flow {source = "oracle_cx0", target = "oracle_cx1"},
        metamodel.Flow {source = "oracle_cx1", target = "h_q0_out"},
        metamodel.Flow {source = "h_q0_out", target = "h_q1_out"},
        metamodel.Flow {source = "h_q1_out", target = "m_q0"},
        metamodel.Flow {source = "m_q0", target = "m_q1"}
        #no final flow
    ]
}

validation = constraints.CircuitValidation {
    circuit = deutschJozsaMutant4
}
