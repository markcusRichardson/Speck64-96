# Speck64/96 Block Cipher – VHDL Implementation

This project implements the **Speck64/96 lightweight block cipher** in VHDL, designed for efficient hardware execution in resource-constrained embedded and cryptographic systems.

Project Overview

- **Cipher Type**: SPECK64/96 (NSA lightweight block cipher)
- **Language**: VHDL
- **Architecture**: Behavioral
- **Encryption Rounds**: 26
- **Key Size**: 96 bits (3 × 32-bit words)
- **Block Size**: 64 bits (2 × 32-bit words)

Inputs & Outputs

Inputs:
- `clk` – Clock signal
- `reset` – Synchronous reset
- `start` – Start signal to begin encryption
- `key_in` – 96-bit encryption key (`unsigned(95 downto 0)`)
- `x_in`, `y_in` – 32-bit plaintext halves

Outputs:
- `x_out`, `y_out` – 32-bit ciphertext halves
- `done` – Signals completion of encryption

Features

- Fully pipelined FSM for sequential encryption processing
- Implements full key expansion and 26 encryption rounds per SPECK specification
- Rotation and modular arithmetic functions implemented in hardware
- Low-level signal control for use in simulation or hardware prototyping

Simulation & Testing

Simulation is performed using **ModelSim**. A `.do` file is provided to automate compilation and waveform setup:

- `Test.do`:
  - Compiles the VHDL source
  - Sets up the simulation environment
  - Adds key signals to the waveform viewer
  - Runs the simulation

To run it:
vsim -do Test.do
