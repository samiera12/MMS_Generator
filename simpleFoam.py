#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Apr 16 17:38:18 2021

@author: Bruno Ramoa
@affiliation: Institute for Polymers and Composites, University of Minho, Portugal
"""

# Script for MMS in OpenFOAM
import os
import sympy as sym
from sympy import sin, cos, exp, pi, sqrt
import pyMMSFoam as mms
from pyMMSFoam import x,y,z,t

CASE_DIR = "//wsl.localhost/Ubuntu-22.04/home/samiera/OpenFOAM/samiera-v2412/run/simpleFoam/mako_test"
SYS_DIR = os.path.join(CASE_DIR, "system")
ZERO_DIR = os.path.join(CASE_DIR, "0")

Re = 5
Lambda = (Re/2) - sqrt( (Re**2/4) + 4*pi**2 )
u = 1 - exp(Lambda*x)*cos(2*pi*y)
v = (Lambda/(2*pi))*exp(Lambda*x)*sin(2*pi*y)
w = 0
p = 0.5*(1-exp(2*Lambda*x))

U = sym.Matrix([u,v,w])

# Momentum balance equation
nu = 0.01

R = nu*(mms.grad(U) + mms.grad(U).T)

S = mms.div(U*U.T) - mms.div(R) + mms.grad(p)

# # Generate fvOptions
mms.generateFvOptions(S, "momentumSource", "U", filepath=os.path.join(SYS_DIR, "fvOptions"))

# # Generate boundary conditions

U_patches = {
    'top':  ('dirichlet', U),
    'bottom': ('dirichlet', U),
    'left':  ('dirichlet', U),
    'right': ('neumann', U),
}

mms.generateBoundaryField(
    "U", U_patches,
    dimensions="[0 1 -1 0 0 0 0]",
    initial_value="(0 0 0)",
    field_class="volVectorField",
    filepath=os.path.join(ZERO_DIR, "U"),
)

p_patches = {
    'top':  ('neumann',   p),
    'bottom': ('neumann', p),
    'left':  ('neumann',   p),
    'right': ('dirichlet', p),
}
mms.generateBoundaryField(
    "p", p_patches,
    dimensions="[0 2 -2 0 0 0 0]",
    initial_value="0",
    field_class="volScalarField",
    filepath=os.path.join(ZERO_DIR, "p"),
)

# # # Velocity
# mms.generateDirichletBoundaries(U, "U")
# mms.generateNeumannBoundaries(U, "U")

# # # Pressure
# mms.generateDirichletBoundaries(p, "p")
# mms.generateNeumannBoundaries(p, "p")

# # Generate functionObjects
mms.generateFunctionObject(U, "U", filepath=os.path.join(SYS_DIR,"function_U"))
mms.generateFunctionObject(p, "p", filepath=os.path.join(SYS_DIR, "function_p"))
