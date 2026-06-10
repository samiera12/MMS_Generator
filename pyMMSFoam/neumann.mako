"(patch1|patch2|patch3)"                     
{                                              
    // Neumann boundary                          
    type            codedMixed;                  
    refValue        uniform ${value};                  
    refGradient     uniform ${value};                  
    valueFraction   uniform 0;                   
                                               
    name        ${name};                              
                                               
    code                                         
    #{                                           
        // Gets current patch                      
        const fvPatch& boundaryPatch = patch();    
                                               
        // Gets the patch face centres values      
        const vectorField& Cf = boundaryPatch.Cf(); 
                                               
        const vectorField nf = patch().nf();       
                                               
        // MMS                                     
        % if has_t:
        const scalar t = this->db().time().value();
        % endif
                                            
        // Loops over the patch                    
        forAll(this->patch(), faceI)               
        {                                          
            % if dims['has_x']:
            const scalar x = Cf[faceI].x();
            % endif
            % if dims['has_y']:
            const scalar y = Cf[faceI].y();
            % endif
            % if dims['has_z']:
            const scalar z = Cf[faceI].z();
            % endif
                                        
            ${formatedCode}

            % if isScalar:
            const vector grad${solutionName}(d${solutionName}_dx, d${solutionName}_dy, d${solutionName}_dz);
            const scalar normalGradient = grad${solutionName} & nf[faceI];
            this->refGrad()[faceI] = normalGradient;
            this->valueFraction()[faceI] = scalar(0);
            % elif isVector:
            const scalar normal_1 = vector(${solutionName}1_xx, ${solutionName}1_xy, ${solutionName}1_xz) & nf[faceI];
            const scalar normal_2 = vector(${solutionName}2_yx, ${solutionName}2_yy, ${solutionName}2_yz) & nf[faceI];
            const scalar normal_3 = vector(${solutionName}3_zx, ${solutionName}3_zy, ${solutionName}3_zz) & nf[faceI];
            const vector normalGradient(normal_1, normal_2, normal_3);
            this->refGrad()[faceI] = normalGradient;
            this->valueFraction()[faceI] = scalar(0);
            % endif
        }                                          
    #};                                          
}