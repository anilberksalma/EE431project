# EE431: Coding Theory - BSC Simulation Project
**Institution:** Ankara Yıldırım Beyazıt University (AYBU)  
**Department:** Electrical and Electronics Engineering  
**Author:** Anıl Berk Salma/22050211015  

---

## Project Overview
This repository contains a complete MATLAB simulation framework evaluating and comparing the performance of **Block Codes** and **Convolutional Codes** under a **Binary Symmetric Channel (BSC)** environment. 

The core implementation consists of:
1. **Hamming (7,4) Linear Block Code** with Syndrome and Coset Leader decoding.
2. **Convolutional Code (K=4, Rate 1/2)** with the full Viterbi Decoding algorithm.

---

## System Components & Specifications

* **Hamming (7,4) Code:** Derived from the systematic parity-check matrix H = [P^T \I_3]. Utilizes an explicit Coset Leader error-vector mapping table for 1-bit hard-decision correction.
* **Convolutional Encoder:** Uses constraint length $K=4$ (8 states) with octal polynomials g_1 = 17 and g_2 = 13. Implements state termination by appending K-1 = 3 trailing zero bits.
* **Personalized Message Stream:** Converts the mandated 12-character string (`ECC2026-S06F`) into a 96-bit binary sequence using 8-bit ASCII (MSB first format).
* **Deterministic Channel Noise:** Initializes the PRNG prior to each experiment execution using the exact specified seeds: `8677`, `13981`, and `21493`.
* **BSC Evaluation:** Tests the transceiver baseline performance under exact channel flip probabilities p \in \{0.001, 0.01, 0.05, 0.10, 0.15\}.

---

## How to Run

1. Execute the main validation loop to view tabulated output scores across all seeds and probabilities:
   ```matlab
   main_bsc_simulation
2. Generate and save the comparative semi-logarithmic performance curves:
   ```matlab
   plot_bsc_results
