# ============================================================
# mutant2.k  -- mutant of deutsch_jozsa.k
# MUTATION: the ancilla preparation (X and H on q2) is removed, so the
#           first oracle CNOT targets q2 before any operation touched it.
# EXPECTED: fails C11 (CNOT applied to a qubit with no prior operation)
# ============================================================

import ...metamodel
import ...constraints

deutschJozsaMutant2 = metamodel.QuantumCircuit {
    name = "DeutschJozsa_Mutant2"
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
        #no ancilla

        metamodel.GateNode {id = "h_q0_in", gateType = "H", targets = ["q0"]},
        metamodel.GateNode {id = "h_q1_in", gateType = "H", targets = ["q1"]},

        metamodel.GateNode {id = "oracle_cx0", gateType = "CNOT", targets = ["q2"], controls = ["q0"]},
        metamodel.GateNode {id = "oracle_cx1", gateType = "CNOT", targets = ["q2"], controls = ["q1"]},

        metamodel.GateNode {id = "h_q0_out", gateType = "H", targets = ["q0"]},
        metamodel.GateNode {id = "h_q1_out", gateType = "H", targets = ["q1"]}
    ]

    measures = [
        metamodel.MeasureNode {id = "m_q0", qubit = "q0", output = "c0"},
        metamodel.MeasureNode {id = "m_q1", qubit = "q1", output = "c1"}
    ]

    flows = [
        metamodel.Flow {source = "init", target = "h_q0_in"},        # <<< MUTATION
        metamodel.Flow {source = "h_q0_in", target = "h_q1_in"},
        metamodel.Flow {source = "h_q1_in", target = "oracle_cx0"},  # <<< MUTATION
        metamodel.Flow {source = "oracle_cx0", target = "oracle_cx1"},
        metamodel.Flow {source = "oracle_cx1", target = "h_q0_out"},
        metamodel.Flow {source = "h_q0_out", target = "h_q1_out"},
        metamodel.Flow {source = "h_q1_out", target = "m_q0"},
        metamodel.Flow {source = "m_q0", target = "m_q1"},
        metamodel.Flow {source = "m_q1", target = "final"}
    ]
}

validation = constraints.CircuitValidation {
    circuit = deutschJozsaMutant2
}
