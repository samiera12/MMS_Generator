functions
{
    errorNorm_${variableName}
    {
        type coded;
        libs (utilityFunctionObjects);
        writeControl writeTime;

        name analyticalSolution_${variableName};

        codeWrite
        #{
            const ${typeOfField}& ${variableName_find} = mesh().lookupObject<${typeOfField}>("${variableName}");

            const volVectorField& C = mesh().C();
            const surfaceVectorField& Cf = mesh().Cf();
            const scalarField& V = mesh().V();

            ${fieldInit}

            % if has_t:
            const Time& time = mesh().time();
            const scalar t = time.value();
            % endif

            forAll(${MMSFieldName}, cellI)
            {
                % if dims['has_x']:
                const scalar x = C[cellI].x();
                % endif
                % if dims['has_y']:
                const scalar y = C[cellI].y();
                % endif
                % if dims['has_z']:
                const scalar z = C[cellI].z();
                % endif

                ${formatedCode}
                
                % if isVector:
                const vector solution(solution_1, solution_2, solution_3);
                % endif

                ${MMSFieldName}[cellI] = ${mag}(solution - ${variableName_find}[cellI]);
            }

            forAll(${MMSFieldName}.boundaryField(), patchI)
            {
                forAll(${MMSFieldName}.boundaryField()[patchI], faceI)
                {
                    % if dims['has_x']:
                    const scalar x = Cf.boundaryField()[patchI][faceI].x();
                    % endif
                    % if dims['has_y']:
                    const scalar y = Cf.boundaryField()[patchI][faceI].y();
                    % endif
                    % if dims['has_z']:
                    const scalar z = Cf.boundaryField()[patchI][faceI].z();
                    % endif

                    ${formatedCode}
                    
                    % if isVector:
                    const vector solution(solution_1, solution_2, solution_3);
                    % endif

                    ${MMSFieldName}.boundaryFieldRef()[patchI][faceI] = ${mag}(solution - ${variableName_find}.boundaryField()[patchI][faceI]);
                }
            }

            ${errorNorms}

            ${MMSFieldName}.write();
        #};
    }
}