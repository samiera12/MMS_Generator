#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Apr 16 17:38:18 2021

@author: Bruno Ramoa
@affiliation: Institute for Polymers and Composites, University of Minho, Portugal
"""


# Checks
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sympy as sym
import os
from mako.template import Template

from .generateCCode import generateCcode, getValue, getTypeOfField, standardSyntax, vectorSyntax
from .differentialOperators import grad
from .symbols import x, y, z, t

TEMPLATE_DIR = os.path.join(os.path.dirname(__file__), 'templates')

def _prepare_data(MMS, solutionName):
    """Helper function to build the data dictionary for Mako."""
    isScalar = isinstance(MMS, sym.Expr)
    isVector = (isinstance(MMS, sym.matrices.dense.MutableDenseMatrix) and MMS.shape == (3, 1))

    symbols = MMS.free_symbols
    
    data = {
        'var_name': solutionName,
        'has_x': x in symbols,
        'has_y': y in symbols,
        'has_z': z in symbols,
        'has_t': t in symbols,
        'is_scalar': isScalar,
        'is_vector': isVector,
        'uniform_value': getValue(isScalar, isVector),
        'field_type': getTypeOfField(isScalar, isVector).strip("Field")
    }
    
    if isScalar:
        data['solution_components'] = f"solution_{solutionName}" if "Source" in solutionName else solutionName
    elif isVector:
        sol_name = f"solution_{solutionName}" if "Source" in solutionName else solutionName
        sol_Name = f"solution_{solutionName}"
        data['solution'] = standardSyntax(sol_Name)
        data['solution_components'] = ", ".join(standardSyntax(sol_name))
        
    return data

def generateFvOptions(sourceTerm, titleForSource, variableInWhichToApllySourceTerm, filepath=None):
    if isinstance(sourceTerm, sym.matrices.immutable.ImmutableDenseMatrix):
       sourceTerm = sourceTerm.as_mutable()
       
    data = _prepare_data(sourceTerm, variableInWhichToApllySourceTerm)
    data['title_for_source'] = titleForSource
    
    # Generate the C++ code block from SymPy
    ccode = generateCcode(sourceTerm, f"solution_{variableInWhichToApllySourceTerm}")
    data['ccode'] = ccode.replace('\n', '\n            ')

    template = Template(filename=os.path.join(TEMPLATE_DIR, 'fvOptions.mako'))
    rendered_output=template.render(data=data)

    if filepath:
        os.makedirs(os.path.dirname(filepath), exist_ok=True)
        with open(filepath, 'w') as f:
            f.write(rendered_output)
        print(f"fvOptions generated at: {filepath}")
    else:
        print(rendered_output)


def generateDirichletBoundaries(MMS, solutionName, patchName, tempVarName='tmp', _print=True):
    data = _prepare_data(MMS, solutionName)
    data['patch_name'] = patchName

    ccode = generateCcode(MMS, solutionName, tempVarName)
    data['ccode'] = ccode.replace('\n', '\n            ')

    template = Template(filename=os.path.join(TEMPLATE_DIR, 'dirichlet.mako'))
    rendered = template.render(data=data)
    return rendered


def generateNeumannBoundaries(MMS, solutionName, patchName, tempVarName='tmp', _print=True):
    data = _prepare_data(MMS, solutionName)
    data['patch_name'] = patchName

    code_lines = []
    if data['is_scalar']:
        code_lines.append(generateCcode(grad(MMS), solutionName, tempVarName, vectorNotation=True))
    elif data['is_vector']:
        solNames = [f"{solutionName}1", f"{solutionName}2", f"{solutionName}3"]
        for i in range(len(solNames)):
            code_lines.append(generateCcode(grad(MMS[i]), solNames[i], f"tmp{i}_", vectorNotation=True))

    data['ccode'] = "".join(code_lines).replace('\n', '\n            ')

    template = Template(filename=os.path.join(TEMPLATE_DIR, 'neumann.mako'))
    rendered = template.render(data=data)
    return rendered


def generateBoundaryField(MMS, solutionName, patches, dimensions, initial_value, field_class, filepath=None, tempVarName='tmp'):
    blocks = []
    for patchName, bcType in patches.items():
        if bcType == 'dirichlet':
            block = generateDirichletBoundaries(MMS, solutionName, patchName,
                                                 tempVarName=tempVarName, _print=False)
        elif bcType == 'neumann':
            block = generateNeumannBoundaries(MMS, solutionName, patchName,
                                               tempVarName=tempVarName, _print=False)
        elif bcType == 'empty':
            block = f"{patchName}\n{{\n    type            empty;\n}}"
        else:
            raise ValueError(f"Unknown bc_type '{bcType}' for patch '{patchName}'. "
                              "Use 'dirichlet' or 'neumann'.")
        blocks.append(block)

    boundaries_content = "\n".join(blocks)
    boundaries_content = "\n".join(
        ("    " + line if line.strip() else line)
        for line in boundaries_content.splitlines()
    )
    
    data = {
        'var_name': solutionName,
        'field_class': field_class,
        'dimensions': dimensions,
        'initial_value': initial_value,
        'boundaries_content': boundaries_content,
    }

    template = Template(filename=os.path.join(TEMPLATE_DIR, '0_field.mako'))
    rendered_output = template.render(data=data)

    if filepath:
        os.makedirs(os.path.dirname(filepath), exist_ok=True)
        with open(filepath, 'w') as f:
            f.write(rendered_output)
        print(f"{solutionName} field generated at: {filepath}")
    else:
        print(rendered_output)

    return rendered_output


def generateFunctionObject(MMS, variableName, filepath=None):
    # Get the base data dictionary (has_x, has_t, field_type, etc.)
    data = _prepare_data(MMS, variableName)
    
    # Add specific Function Object variables
    base_field_type = data['field_type'] # "scalar" or "vector"
    data['type_of_field'] = f"vol{base_field_type[0].upper()}{base_field_type[1:]}Field"
    
    data['var_name_find'] = f"{variableName}_find"
    data['mms_field_name'] = f"MMS_diff_{variableName}"
    
    if data['is_scalar']:
        data['mag_func'] = "mag"
        data['field_init_dimensioned'] = f'dimensionedScalar("{data["mms_field_name"]}_", dimless, 0.0)'
    elif data['is_vector']:
        data['mag_func'] = "cmptMag"
        data['field_init_dimensioned'] = f'dimensionedVector("{data["mms_field_name"]}_", dimless, vector(0, 0, 0))'

    # Generate the C++ code block for the solution
    ccode = generateCcode(MMS, "solution")
    data['ccode'] = ccode.replace('\n', '\n                ')

    # Render template
    template = Template(filename=os.path.join(TEMPLATE_DIR, 'functionObject.mako'))
    rendered_output = template.render(data=data)

    if filepath:
        os.makedirs(os.path.dirname(filepath), exist_ok=True)
        with open(filepath, 'w') as f:
            f.write(rendered_output)
        print(f"function_{variableName} generated at: {filepath}")
    else:
        print(rendered_output)