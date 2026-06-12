functions
{
    errorNorm_${data['var_name']}
    {
        type coded;
        libs (utilityFunctionObjects);
        writeControl writeTime;

        name analyticalSolution_${data['var_name']};

        codeWrite
        #{
            const ${data['type_of_field']}& ${data['var_name_find']} = mesh().lookupObject<${data['type_of_field']}>("${data['var_name']}");

            const volVectorField& C = mesh().C();
            const surfaceVectorField& Cf = mesh().Cf();
            const scalarField& V = mesh().V();

            // Initialize MMS Field
            ${data['type_of_field']} ${data['mms_field_name']}
            (
                IOobject
                (
                    "${data['mms_field_name']}",
                    mesh().time().timeName(),
                    mesh(),
                    IOobject::NO_READ,
                    IOobject::AUTO_WRITE
                ),
                mesh(),
                ${data['field_init_dimensioned']}
            );

            % if data['has_t']:
            const Time& time = mesh().time();
            const scalar t = time.value();
            % endif

            forAll(${data['mms_field_name']}, cellI)
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
                const vector solution(solution_1, solution_2, solution_3);
                % endif

                ${data['mms_field_name']}[cellI] = ${data['mag_func']}(solution - ${data['var_name_find']}[cellI]);
            }

            forAll(${data['mms_field_name']}.boundaryField(), patchI)
            {
                forAll(${data['mms_field_name']}.boundaryField()[patchI], faceI)
                {
                    % if data['has_x']:
                    const scalar x = Cf.boundaryField()[patchI][faceI].x();
                    % endif
                    % if data['has_y']:
                    const scalar y = Cf.boundaryField()[patchI][faceI].y();
                    % endif
                    % if data['has_z']:
                    const scalar z = Cf.boundaryField()[patchI][faceI].z();
                    % endif

                    // SymPy Generated C-Code
                    ${data['ccode']}
                    
                    % if data['is_vector']:
                    const vector solution(solution_1, solution_2, solution_3);
                    % endif

                    ${data['mms_field_name']}.boundaryFieldRef()[patchI][faceI] = ${data['mag_func']}(solution - ${data['var_name_find']}.boundaryField()[patchI][faceI]);
                }
            }

            // Print Error Norms
            % if data['is_scalar']:
            Info << "L1 norm is: "    << gSum( ${data['mms_field_name']}*V )/gSum(V)            << endl;
            Info << "L2 norm is: "    << Foam::sqrt( gSum(${data['mms_field_name']}*${data['mms_field_name']}*V)/gSum(V) )    << endl;
            Info << "Linf norm is: "  << gMax( ${data['mms_field_name']} )                 << endl;
            % else:
            Info << "For the 1st component of the vector" << endl;
            Info << "L1 norm is: "    << gSum( ${data['mms_field_name']}.component(0)*V )/gSum(V) << endl;
            Info << "L2 norm is: "    << Foam::sqrt( gSum( ${data['mms_field_name']}.component(0)*${data['mms_field_name']}.component(0)*V)/gSum(V) ) << endl;
            Info << "Linf norm is: "  << gMax( ${data['mms_field_name']}.component(0).ref() ) << endl;

            Info << "For the 2nd component of the vector" << endl;
            Info << "L1 norm is: "    << gSum( ${data['mms_field_name']}.component(1)*V )/gSum(V) << endl;
            Info << "L2 norm is: "    << Foam::sqrt( gSum( ${data['mms_field_name']}.component(1)*${data['mms_field_name']}.component(1)*V)/gSum(V) ) << endl;
            Info << "Linf norm is: "  << gMax( ${data['mms_field_name']}.component(1).ref() ) << endl;

            Info << "For the 3rd component of the vector" << endl;
            Info << "L1 norm is: "    << gSum( ${data['mms_field_name']}.component(2)*V )/gSum(V) << endl;
            Info << "L2 norm is: "    << Foam::sqrt( gSum( ${data['mms_field_name']}.component(2)*${data['mms_field_name']}.component(2)*V)/gSum(V) ) << endl;
            Info << "Linf norm is: "  << gMax( ${data['mms_field_name']}.component(2).ref() ) << endl;
            % endif

            ${data['mms_field_name']}.write();
        #};
    }
}