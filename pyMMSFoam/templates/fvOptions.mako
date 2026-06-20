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

${data['title_for_source']}
{
    type            ${data['field_type']}CodedSource;
    selectionMode   all;
    fields          (${data['var_name']});

    name            ${data['title_for_source']}_2;

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
        const scalarField& V = mesh_.V();
        const volVectorField& C = mesh().C();
        ${data['field_type']}Field& ${data['var_name']}Source = eqn.source();

        % if data['has_t']:
        const Time& time = mesh().time();
        const scalar t = time.value();
        % endif

        forAll(${data['var_name']}Source, cellI)
        {
            % if data['has_x']:
            const scalar x = C[cellI].x();
            % endif
            % if data['has_y']:
            const scalar y = C[cellI].y();
            % endif
            % if data['has_z']:
            const scalar z = C[cellI].z();
            % endif

            // SymPy Generated C-Code
            ${data['ccode']}

            % if data['is_vector']:
            const vector solution (${", ".join(data['solution'])});
            ${data['var_name']}Source[cellI] -= V[cellI] * solution;
            % else:
            ${data['var_name']}Source[cellI] -= V[cellI] * (solution_${data['solution_components']});
            % endif
        };
    #};
}