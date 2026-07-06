import subprocess
import re
import os

def run_hybrid_simulation():
    print("1. Running simpleFoam.py (pyMMSFoam file generation)...")
    
    gen_result = subprocess.run(["python", "simpleFoam.py"])
    
    if gen_result.returncode != 0:
        return {"status": "failed", "data": "simpleFoam.py encountered an error. Stopping execution."}

    wsl_case_path = "/home/samiera/OpenFOAM/samiera-v2412/run/simpleFoam/subprocess" 
    win_log_path = r"\\wsl$\Ubuntu-22.04" + wsl_case_path.replace("/", "\\") + r"\log.simpleFoam"


    print(f"2. Bridging to WSL and executing OpenFOAM in {wsl_case_path}...")

    linux_command = f"cd {wsl_case_path} && blockMesh && simpleFoam && simpleFoam > log.simpleFoam 2>&1"
    
    try:
        result = subprocess.run(["wsl", "bash", "-ic", linux_command])

        if result.returncode != 0:
            print("Warning: The OpenFOAM execution threw a non-zero exit code. Checking logs anyway...")
        
        # print("3. Execution finished. Fetching error norms from Ubuntu filesystem...")
        
        # if not os.path.exists(win_log_path):
        #     return {"status": "failed", "data": f"Could not find log file at: {win_log_path}"}
            
        # with open(win_log_path, 'r') as file:
        #     output = file.read()
        
        # extracted_lines = []
        
        # for line in output.splitlines():
        #     if re.search(r'(component of the vector|norm is:)', line, re.IGNORECASE):
        #         extracted_lines.append(line.strip())
        
        # final_block = extracted_lines[-20:] if len(extracted_lines) > 20 else extracted_lines

        # return {"status": "success", "data": final_block}

    except Exception as e:
        return {"status": "failed", "data": f"An unexpected system error occurred: {e}"}

if __name__ == "__main__":
    simulation = run_hybrid_simulation()
    
    # if simulation["status"] == "failed":
    #     print("\n--- ERROR ---")
    #     print(simulation["data"])
        
    # elif simulation["status"] == "success":
    #     print("\n--- FINAL ERROR NORMS / RESIDUALS ---")
        
    #     if len(simulation["data"]) == 0:
    #         print("The log file was read successfully, but the norms were not found inside it.")
    #     else:
    #         for line in simulation["data"]:
    #             print(line)