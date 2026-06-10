"(patch1|patch2|patch3)"                     
{                                              
    // Dirichlet boundary                        
    type        codedFixedValue;                 
    value       uniform ${value};                      
                                               
    name        ${name};                              
                                               
    code                                         
    #{                                           
        // Gets current patch                      
        const fvPatch& boundaryPatch = patch();    
                                               
        // Gets the patch face centres values      
        const vectorField& Cf = boundaryPatch.Cf(); 
                                               
        // Gets the current field                  
        ${typeOfField}& field = *this;                         
                                               
        // MMS
        % if has_t:
        const scalar t = this->db().time().value();
        % endif                                    
        
        // Loops over the patch                    
        forAll(Cf, faceI)                          
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
            field[faceI] = ${solutionName};
            % elif isVector:
            const vector ${solutionName}(${solutionName}_1, ${solutionName}_2, ${solutionName}_3);
            field[faceI] = ${solutionName};
            % endif                                       
        }                                          
    #};                                          
}