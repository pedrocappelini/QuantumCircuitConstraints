# ============================================================
# mutant3.k  -- mutant of deutsch_jozsa.k
# ------------------------------------------------------------------
# MUTATION 1: an X correction gate is added after the measurements,
#             classically controlled by c0 and c1. But the flow is
#             reordered so the CNOT oracle runs *after* m_q0 was
#             already measured, violating C9 (gate after measurement).
# MUTATION 2: the X gate depends on classical store c1 (via
#             classicalDependsOn), but m_q1 (which produces c1) is
#             scheduled *after* the X gate in the flow, violating
#             C7 (classical dependency produced later).
#
# EXPECTED: fails C9 and C7.
# ============================================================

import ...metamodel
import ...constraints

deutschJozsaMutant3 = metamodel.QuantumCircuit {
    name = "DeutschJozsa_Mutant3"
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


        metamodel.GateNode {id = "corr_x", gateType = "X", targets = ["q0"], classicalDependsOn = ["c1"]}, #targets q0 and dependes on c1

        # Hadamard on the input register before measuring
        metamodel.GateNode {id = "h_q0_out", gateType = "H", targets = ["q0"]},
        metamodel.GateNode {id = "h_q1_out", gateType = "H", targets = ["q1"]}
    ]

    measures = [
        metamodel.MeasureNode {id = "m_q0", qubit = "q0", output = "c0"},
        metamodel.MeasureNode {id = "m_q1", qubit = "q1", output = "c1"}
    ]

    flows = [
        metamodel.Flow {source = "init", target = "x_anc"},
        metamodel.Flow {source = "x_anc", target = "h_q0_in"},
        metamodel.Flow {source = "h_q0_in", target = "h_q1_in"},
        metamodel.Flow {source = "h_q1_in", target = "h_anc"},
        metamodel.Flow {source = "h_anc", target = "oracle_cx0"},
        metamodel.Flow {source = "oracle_cx0", target = "oracle_cx1"},
        metamodel.Flow {source = "oracle_cx1", target = "m_q0"},
        metamodel.Flow {source = "m_q0", target = "corr_x"}, #measures q0 before corr_x
        metamodel.Flow {source = "corr_x", target = "h_q0_out"}, #use of corr_x
        metamodel.Flow {source = "h_q0_out", target = "h_q1_out"},
        metamodel.Flow {source = "h_q1_out", target = "m_q1"}, #c1 produced
        metamodel.Flow {source = "m_q1", target = "final"}
    ]
}

validation = constraints.CircuitValidation {
    circuit = deutschJozsaMutant3
}
