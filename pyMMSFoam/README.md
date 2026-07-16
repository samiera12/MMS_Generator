# pyMMSFoam: Mako Template Integration

## Introduction
The Method of Manufactured Solutions (MMS) is a rigorous procedure for verifying Computational Fluid Dynamics (CFD) solvers. By defining an analytical "manufactured" solution, users can generate exact source terms and boundary conditions to test the spatial and temporal accuracy of a solver. 

pyMMSFoam automates this highly manual and error-prone process for OpenFOAM. It leverages SymPy to symbolically derive the necessary mathematical terms (e.g., gradients, divergences, and source terms) and translates them into standard OpenFOAM C++ code.

## The Mako Upgrade
Previous iterations of pyMMSFoam relied heavily on Python string concatenation to generate OpenFOAM dictionaries. While functional, this approach entangled symbolic mathematical logic with text formatting. As a result, the codebase was difficult to read, scale, and maintain, with OpenFOAM boilerplate often obscured by Python escape characters and f-strings.

The current version resolves this by introducing Mako templates. This fundamentally shifts the architecture, isolating the Python math engine from the OpenFOAM file layout.

**Key Advantages of the Mako Implementation:**
* **Separation of Concerns:** Python scripts strictly handle symbolic math, derivative calculations, and data preparation. Mako templates exclusively manage the C++ layout and dictionary structure.
* **Enhanced Readability:** The template files (`.mako`) retain native OpenFOAM formatting. They look and read like standard OpenFOAM dictionaries, making them instantly recognizable to CFD practitioners.
* **Maintainability & Reusability:** Modifying a dictionary's structure, fixing indentation, or adding new OpenFOAM fields now requires editing only the template file. The core Python mathematical engine remains untouched, ensuring consistency across all generated files.

## Template Architecture
The system generates complete case files using five distinct Mako templates, all populated by a centralized data dictionary:

| Template File | Functionality |
| :--- | :--- |
| `fvOptions.mako` | Generates a `codedSource` entry to inject the manufactured source term into the governing equations. |
| `dirichlet.mako` | Creates a `codedFixedValue` boundary block to impose the exact analytical solution directly on a patch. |
| `neumann.mako` | Creates a `codedMixed` boundary block to mathematically impose the exact normal gradient on a patch. |
| `0_field.mako` | Wraps the generated boundary conditions into a standard OpenFOAM `0/<field>` initialization file. |
| `functionObject.mako` | Generates a compiled function object to automatically compute and track $L_{1}$, $L_{2}$, and $L_{\infty}$ error norms at runtime. |

## Workflow and Execution
The Python backend processes user-defined SymPy expressions through a standardized pipeline:
1. **Symbolic Processing:** Detects field types (scalar vs. vector) and identifies the active spatial/temporal variables ($x$, $y$, $z$, $t$) to prevent unnecessary C++ variable declarations.
2. **C++ Translation:** Converts SymPy expressions into optimized C++ syntax, applying common-subexpression elimination.
3. **Template Rendering:** Injects the C++ statements and case-specific metadata (dimensions, field types, uniform values) into the Mako templates to output finalized, ready-to-run OpenFOAM dictionaries.

## Worked Example: Incompressible Navier-Stokes
Consider a verification case for a steady, incompressible solver (`simpleFoam`). The user defines a smooth manufactured velocity field ($u$, $v$, $w$) and pressure field ($p$):

$$\Lambda=\frac{Re}{2}-\sqrt{\frac{Re^{2}}{4}+4\pi^{2}}$$

$$u=1-e^{\Lambda x}\cos(2\pi y)$$

$$v=\frac{\Lambda}{2\pi}e^{\Lambda x}\sin(2\pi y)$$

$$w=0$$

$$p=\frac{1}{2}(1-e^{2\Lambda x})$$

The residual source term $S$ required to satisfy the momentum equation is computed via SymPy:

$$S=\nabla\cdot(UU^{T})-\nabla\cdot R+\nabla p$$

Using pyMMSFoam, the user passes these expressions into the generation functions. The tool automatically maps the mathematical inputs to the Mako templates, rapidly outputting a `system/fvOptions` file, complete `0/U` and `0/p` initializations, and runtime `functionObjects`. This allows the user to immediately run the solver and evaluate spatial convergence without writing a single line of C++ by hand.

---

### 2. Steps to Implement

1. **Define your Equations:** Open the primary Python execution script and input your desired analytical fields (e.g., $U$, $p$, $T$) using standard SymPy notation.
2. **Execute pyMMSFoam:** Run the script to initiate the workflow. The tool will parse your equations, calculate analytical derivatives, and isolate the source terms.
3. **Template Compilation:** The system will automatically inject the C++ translated math into the Mako templates and output the OpenFOAM dictionaries to a target directory.

