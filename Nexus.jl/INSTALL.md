# Installation Guide for Developers

This document provides the instructions for setting up a local development environment for the **Nexus Protocol**. This guide is intended for developers and contributors who wish to work on the core protocol itself.

For instructions on how to run a production node as a network participant, please see the **[Node Operator's Manual](https://your-codex-url.com/operator/)**.

## Prerequisites

  * **Git:** For cloning the repository.
  * **Julia:** Version 1.9 or higher.

## Step-by-Step Installation

### 1\. Clone the Sovereign Ground

First, clone the official `Nexus.jl` repository to your local machine.

```bash
git clone https://your-repository.com/nexus.jl.git
cd nexus.jl
```

### 2\. Activate the Environment & Instantiate

Julia has a powerful built-in package manager. The `Project.toml` file in this repository defines all necessary dependencies.

Open the Julia REPL (by typing `julia` in your terminal) and perform the following steps:

```julia
# 1. Press ']' to enter the Pkg REPL mode.
(v1.9) pkg>

# 2. Activate the project environment.
(v1.9) pkg> activate .
Activating project at `~/path/to/nexus.jl`

# 3. Instantiate the project to download and install all dependencies.
(nexus.jl) pkg> instantiate
   Resolving package versions...
   # ... output will show packages being installed ...

# 4. Press Backspace to return to the Julia REPL.
julia>
```

### 3\. Run the Test Suite

A fortress must be tested before it is garrisoned. Run the full test suite to ensure your local environment is correctly configured and all systems are nominal.

```julia
# From within the Julia REPL
include("test/runtests.jl")
```

You should see a series of passing tests. If any tests fail, please consult the troubleshooting guide or open an issue.

Your development environment is now fully configured. Welcome to the forge, Architect.
