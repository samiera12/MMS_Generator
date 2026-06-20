${data['patch_name']}                    
{                                              
    type        codedFixedValue;                 
    value       uniform ${data['uniform_value']};                      
    name        ${data['var_name']}_dirichlet;                              
                                               
    code                                         
    #{                                           
        const fvPatch& boundaryPatch = patch();    
        const vectorField& Cf = boundaryPatch.Cf(); 
        ${data['field_type']}Field& field = *this;                         
                                               
        % if data['has_t']:
        const scalar t = this->db().time().value();
        % endif
                                               
        forAll(Cf, faceI)                          
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
                                             
            % if data['is_vector']:
            const vector ${data['var_name']}(${data['solution_components']});
            % endif
            
            field[faceI] = ${data['var_name']};
        }                                          
    #};                                          
}