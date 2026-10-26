
import ..metamodel
import ..constraints

qaoa = metamodel.QuantumCircuit {
    name = "QAOA_MaxCut_Triangle_p1"
    numQubits = 3
    ordering = "little"

    qubits = [
        metamodel.Qubit {id = "q0", index = 0, kind = "data"},
        metamodel.Qubit {id = "q1", index = 1, kind = "data"},
        metamodel.Qubit {id = "q2", index = 2, kind = "data"}
    ]

    initialNode = metamodel.InitialNode {id = "init"}
    finalNode = metamodel.FinalNode {id = "final"}

    classicalStores = [
        metamodel.ClassicalStore {name = "c0"},
        metamodel.ClassicalStore {name = "c1"},
        metamodel.ClassicalStore {name = "c2"}
    ]

    gates = [
        # Initial superposition
        metamodel.GateNode {id = "h_q0", gateType = "H", targets = ["q0"]},
        metamodel.GateNode {id = "h_q1", gateType = "H", targets = ["q1"]},
        metamodel.GateNode {id = "h_q2", gateType = "H", targets = ["q2"]},

        # Cost layer, edge (0,1)
        metamodel.GateNode {id = "cx_01_a", gateType = "CNOT", targets = ["q1"], controls = ["q0"]},
        metamodel.GateNode {id = "rz_01", gateType = "Custom", targets = ["q1"], decompositionName = "RZ(gamma)"},
        metamodel.GateNode {id = "cx_01_b", gateType = "CNOT", targets = ["q1"], controls = ["q0"]},

        # Cost layer, edge (1,2)
        metamodel.GateNode {id = "cx_12_a", gateType = "CNOT", targets = ["q2"], controls = ["q1"]},
        metamodel.GateNode {id = "rz_12", gateType = "Custom", targets = ["q2"], decompositionName = "RZ(gamma)"},
        metamodel.GateNode {id = "cx_12_b", gateType = "CNOT", targets = ["q2"], controls = ["q1"]},

        # Cost layer, edge (0,2)
        metamodel.GateNode {id = "cx_02_a", gateType = "CNOT", targets = ["q2"], controls = ["q0"]},
        metamodel.GateNode {id = "rz_02", gateType = "Custom", targets = ["q2"], decompositionName = "RZ(gamma)"},
        metamodel.GateNode {id = "cx_02_b", gateType = "CNOT", targets = ["q2"], controls = ["q0"]},

        # Mixer layer
        metamodel.GateNode {id = "rx_q0", gateType = "Custom", targets = ["q0"], decompositionName = "RX(2*beta)"},
        metamodel.GateNode {id = "rx_q1", gateType = "Custom", targets = ["q1"], decompositionName = "RX(2*beta)"},
        metamodel.GateNode {id = "rx_q2", gateType = "Custom", targets = ["q2"], decompositionName = "RX(2*beta)"}
    ]

    measures = [
        metamodel.MeasureNode {id = "m_q0", qubit = "q0", output = "c0"},
        metamodel.MeasureNode {id = "m_q1", qubit = "q1", output = "c1"},
        metamodel.MeasureNode {id = "m_q2", qubit = "q2", output = "c2"}
    ]

    flows = [
        metamodel.Flow {source = "init", target = "h_q0"},
        metamodel.Flow {source = "h_q0", target = "h_q1"},
        metamodel.Flow {source = "h_q1", target = "h_q2"},
        metamodel.Flow {source = "h_q2", target = "cx_01_a"},
        metamodel.Flow {source = "cx_01_a", target = "rz_01"},
        metamodel.Flow {source = "rz_01", target = "cx_01_b"},
        metamodel.Flow {source = "cx_01_b", target = "cx_12_a"},
        metamodel.Flow {source = "cx_12_a", target = "rz_12"},
        metamodel.Flow {source = "rz_12", target = "cx_12_b"},
        metamodel.Flow {source = "cx_12_b", target = "cx_02_a"},
        metamodel.Flow {source = "cx_02_a", target = "rz_02"},
        metamodel.Flow {source = "rz_02", target = "cx_02_b"},
        metamodel.Flow {source = "cx_02_b", target = "rx_q0"},
        metamodel.Flow {source = "rx_q0", target = "rx_q1"},
        metamodel.Flow {source = "rx_q1", target = "rx_q2"},
        metamodel.Flow {source = "rx_q2", target = "m_q0"},
        metamodel.Flow {source = "m_q0", target = "m_q1"},
        metamodel.Flow {source = "m_q1", target = "m_q2"},
        metamodel.Flow {source = "m_q2", target = "final"}
    ]
}

validation = constraints.CircuitValidation {
    circuit = qaoa
}
