import .metamodel

schema ValidationConfig:
    strictMeasurementChecks: bool = True
    strictClassicalDependencyChecks: bool = True
    strictTerminalMeasurementChecks: bool = True
    strictResetChecks: bool = True
    strictCnotChecks: bool = True

schema CircuitValidation:
    circuit: metamodel.QuantumCircuit
    config: ValidationConfig = ValidationConfig {}

    # --- 1. Resource ID Lookups ---
    _qIds = [q.id for q in circuit.qubits]
    _csNames = [cs.name for cs in circuit.classicalStores]
    _mOutputs = [m.output for m in circuit.measures]

    _producingMIds = {
        cs.name: [m.id for m in circuit.measures if m.output == cs.name]
        for cs in circuit.classicalStores
    }

    # --- 2. Execution Graph views (Reachability) ---
    _allNodes = [
        circuit.initialNode.id,
        circuit.finalNode.id
    ] + [g.id for g in circuit.gates] + [m.id for m in circuit.measures] + [r.id for r in circuit.resets] + [fk.id for fk in circuit.forkNodes] + [jn.id for jn in circuit.joinNodes]

    _directPreds = {
        n: [f.source for f in circuit.flows if f.target == n]
        for n in _allNodes
    }

    _p1 = {n: _directPreds[n] for n in _allNodes}
    _p2 = {n: _p1[n] + [p_flat for p in _p1[n] for p_flat in _p1[p] if p_flat not in _p1[n]] for n in _allNodes}
    _p3 = {n: _p2[n] + [p_flat for p in _p2[n] for p_flat in _p1[p] if p_flat not in _p2[n]] for n in _allNodes}
    _p4 = {n: _p3[n] + [p_flat for p in _p3[n] for p_flat in _p1[p] if p_flat not in _p3[n]] for n in _allNodes}

    _reachablePreds = _p4

    # --- 3. Pre-calculated Validations ---
    _c6_valid = all m in circuit.measures {
        m.qubit in _qIds and m.output in _csNames
    }

    _c7_valid = all g in circuit.gates {
        all d in g.classicalDependsOn {
            d in _mOutputs and any mid in _producingMIds[d] {
                mid in _reachablePreds[g.id]
            }
        }
    }

    _c9_valid = all g in circuit.gates {
        all m in circuit.measures {
            (m.qubit not in g.targets and m.qubit not in g.controls) or (m.id not in _reachablePreds[g.id])
        }
    }

    # For each qubit id: every node (gate, measure, reset) that operates on it
    _opsOnQubit = {
        q.id: [g.id for g in circuit.gates if q.id in g.targets or q.id in g.controls] + [m.id for m in circuit.measures if m.qubit == q.id] + [r.id for r in circuit.resets if r.qubit == q.id]
        for q in circuit.qubits
    }

    # _gateQubits = {g.id: g.targets + g.controls for g in circuit.gates}

    # C10: a Reset needs a previous operation on its qubit
    _c10_valid = all r in circuit.resets {
        r.qubit in _opsOnQubit and any opId in _opsOnQubit[r.qubit] {
            opId in _reachablePreds[r.id]
        }
    }

    # C11: every qubit used by a CNOT needs a previous operation
    # _c11_valid = all g in circuit.gates {
    #     (g.gateType != "CNOT") or all qid in _gateQubits[g.id] {
    #         qid in _opsOnQubit and any opId in _opsOnQubit[qid] {
    #             opId in _reachablePreds[g.id]
    #         }
    #     }
    # }

    check:
        (not config.strictMeasurementChecks) or _c6_valid, "C6 Violation: Measurement references invalid qubit or classical store"
        (not config.strictClassicalDependencyChecks) or _c7_valid, "C7 Violation: Classical dependency refers to a measurement not yet performed"
        (not config.strictTerminalMeasurementChecks) or _c9_valid, "C9 Violation: Gate operation attempted on a qubit after it was already measured"
        (not config.strictResetChecks) or _c10_valid, "C10 Violation: Reset applied to a qubit that has not undergone any prior operation"
        # C11 is on hold (see note above)
        # (not config.strictCnotChecks) or _c11_valid, "C11 Violation: CNOT applied to a qubit that has not undergone any prior operation"
