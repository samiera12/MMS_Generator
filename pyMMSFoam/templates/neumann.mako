${data['patch_name']}                     
{                                              
    type            codedMixed;                  
    refValue        uniform ${data['uniform_value']};                  
    refGradient     uniform ${data['uniform_value']};                  
    valueFraction   uniform 0;                   
    name            ${data['var_name']}_Neumann;                              
                                               
    code                                         
    #{                                           
        const fvPatch& boundaryPatch = patch();    
        const vectorField& Cf = boundaryPatch.Cf(); 
        const vectorField nf = patch().nf();       
                                               
        % if data['has_t']:
        const scalar t = this->db().time().value();
        % endif
                                               
        forAll(this->patch(), faceI)               
        {                                          
            % if data['has_x']:
            const scalar x = Cf[faceI].x();
            % endif
            % if data['has_y']:
            const scalar y = Cf[faceI].y();
            % endif
            % if data['has_z']:
            const scalar z = Cf[faceI].z();
            % endif
                                             
            // SymPy Generated C-Code
            ${data['ccode']}
            
            % if data['is_scalar']:
            const vector grad${data['var_name']} (d${data['var_name']}_dx, d${data['var_name']}_dy, d${data['var_name']}_dz);
            const scalar normalGradient = grad${data['var_name']} & nf[faceI];
            % endif
            
            % if data['is_vector']:
            const scalar normal_1 = vector(${data['var_name']}1_xx, ${data['var_name']}1_xy, ${data['var_name']}1_xz) & nf[faceI];
            const scalar normal_2 = vector(${data['var_name']}2_yx, ${data['var_name']}2_yy, ${data['var_name']}2_yz) & nf[faceI];
            const scalar normal_3 = vector(${data['var_name']}3_zx, ${data['var_name']}3_zy, ${data['var_name']}3_zz) & nf[faceI];
            const vector normalGradient (normal_1, normal_2, normal_3);
            % endif
            
            this->refGrad()[faceI] = normalGradient;
            this->valueFraction()[faceI] = scalar(0); 
        }                                          
    #};                                          
}