/*--------------------------------*- C++ -*----------------------------------*\
| =========                 |                                                 |
| \\      /  F ield         | OpenFOAM: The Open Source CFD Toolbox           |
|  \\    /   O peration     | Version:  v2012                                 |
|   \\  /    A nd           | Website:  www.openfoam.com                      |
|    \\/     M anipulation  |                                                 |
\*---------------------------------------------------------------------------*/
FoamFile
{
    version     2.0;
    format      ascii;
    class       dictionary;
    object      fvOptions;
}
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //

${titleForSource}
{
    type            ${vectorOrScalarSourceCode}CodedSource;
    selectionMode   all;
    fields          (${variableInWhichToApllySourceTerm});

    name            ${titleForSource}_2;

    codeInclude
    #{
        // Info: Include necessary libraries for calculation
    #};

    codeCorrect
    #{
        // Info: Apply corrections after the equation has been solved
    #};

    codeConstrain
    #{
        // Info: Constrain values before the equation is solved
    #};

    codeAddSup
    #{
        // Gets the cell volumes of the mesh
        const scalarField& V = mesh_.V();

        // Gets the vector containing cell center position of the mesh
        const volVectorField& C = mesh().C();

        // Gets the equation source term
        ${vectorOrScalarSourceCode}Field& ${variableInWhichToApllySourceTerm}Source = eqn.source();

        % if has_t:
        const Time& time = mesh().time();
        // Gets the current time value
        const scalar t = time.value();
        % endif

        // Loops over each cell in the domain
        forAll(${variableInWhichToApllySourceTerm}Source, cellI)
        {
            % if dims['has_x']:
            // Gets the x component of the current cell
            const scalar x = ${mesh_var}${iterator}.x();
            % endif
            
            % if dims['has_y']:
            //Gets the y component of the current cell
            const scalar y = ${mesh_var}${iterator}.y();
            % endif
            
            % if dims['has_z']:
            // Gets the z component of the current cell
            const scalar z = ${mesh_var}${iterator}.z();
            % endif

            ${formatedCode}

            % if isVector:
            const vector solution(${solution_components});
            ${variableInWhichToApllySourceTerm}Source[cellI] -= V[cellI]*solution;
            % else:
            ${variableInWhichToApllySourceTerm}Source[cellI] -= V[cellI]*(${solution_components});
            % endif
        };
    #};
}