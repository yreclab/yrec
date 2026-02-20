import numpy as np
import matplotlib.pyplot as plt
import matplotlib as mpl
import os
import glob 
import scipy.interpolate as interp
import pandas as pd


def gen_runfile(runfile_params, runfile_name, runfile_temp = "runfile_temp"):
    
    """
    Generates a rotevol runfile from a template runfile given the following inputs: 
    
    runfile_params: Dictionary with keys given by runfile variables and values for desired grid inputs and outputs
    runfile_name: File savename for the run file. 
    
    Optional: runfile_temp: Template filled in by runfile_params. Unless changes to rotevol runfile inputs are made, should remain = "runfile_temp"
    
    """
    
    with open(runfile_temp, "r") as c:
        lines = c.read() 
        input_vals = list(runfile_params.values()) #get values from runfile params

        lines = lines.format(*input_vals) 
        
        c.close()
    
    with open(runfile_name, 'w') as r:
        r.write(lines)
        
        r.close()
    
    os.system("chmod +x {0}".format(runfile_name)) #runfile needs to be an executable 

    return 

def gen_controlfile(controlfile_params, controlfile_name, control_file_temp = "control_file_temp.dat"):
    
    """
    Generates a rotevol control file from a template control file given the following inputs: 
    
    controlfile_params: Dictionary with keys given by control file variables and values for desired grid parameters
    controlfile_name: File savename for the control file. 
    
    Optional: control_file_temp: Template filled in by controlfile_params. Unless changes to available rotevol parameters are made, should remain = "control_file_temp.dat"
    
    """
    
    with open(control_file_temp, "r") as c:
        lines = c.read()
        input_vals = list(controlfile_params.values())

        lines = lines.format(*input_vals)
        
        c.close()
        
    with open(controlfile_name, 'w') as r:
        r.write(lines)
        
        r.close()
    return 


def read_rotfile(rottrack_file, output_dir):
    
    """
    Given a rotevol output file and an output directory, generates a numpy/pandas readable datafile 
    
    rottrack_file = location + name of rotevol outpout file 
    output_dir = where you want to store numpy/pandas readable files
    
    Returns
        filename 
        data columns
    
    """
    
        
    os.system("mkdir -p {0}".format(output_dir)) #make "clean directory"
       
    with open(rottrack_file, "r") as file:
        rot_file_name = rottrack_file.split(".out")[0].split("/")[-1]
        lines = file.readlines()

        
        if np.shape(lines)[0] <= 10:
            return "", {}, pd.DataFrame()
        model_info = lines[0]
        
        ntracks = model_info.split()[3]
        track_info = lines[1:1+int(ntracks)]
        data_header = lines[int(ntracks) + 1]
        data_start_line = int(ntracks) + 2
        data_lines = np.array(lines[data_start_line:])
        
        file.close()

        start_line = 0

        for mod in track_info:
            mod_info = mod.split()
            mod_num = int(mod_info[0])
            mod_lines = int(mod_info[1])
            mod_mass0 = float(mod_info[2])
            mod_prot0 = float(mod_info[3])

            mod_dat = data_lines[start_line: start_line + mod_lines - 1]
            mod_dat = np.array(mod_dat)
            len_line = len(mod_dat[0].split())
            model = []
            for line in mod_dat:
            
                line = line.split()
                
                
                if len(line) != len_line:
                    
                    line_entry0 = line[0].split(str(mod_num))
                    line_copy = line
                    line = [str(mod_num), line_entry0[1]] + line_copy[1:]
                
                try:
                    line = np.array(line, dtype = "float")
                    
                    model.append(line)

                except:
                    pass
            
            model = np.array(model)
            
            np.savetxt(output_dir + "/" + rot_file_name, 
                      model, header = data_header)
            
            start_line = start_line + mod_lines
        
        header_dict = {}
        for i in range(len(data_header.split())):
            header_dict[data_header.split()[i]] = i
        
        model_df = pd.DataFrame(model, columns = header_dict.keys())
        return output_dir + "/" + rot_file_name, header_dict, model_df

def read_trackfile(track_file, output_dir, savefile = False):
    
    """
    Given a YREC output track file and an output directory, generates a numpy/pandas readable datafile 
    
    rottrack_file = location + name of rotevol outpout file 
    output_dir = where you want to store numpy/pandas readable files
    
    Returns
        dataframe
        filename 
        
    
    """
    
        
    
       
    with open(track_file, "r") as file:
        file_name = track_file.split(".track")[0].split("/")[-1]
        lines = file.readlines()
        
        
        data_header = ""
        
        
        data = lines[0:]
        nlines = len(lines)
        file.close()

        mod_dat = []
        
        read_dat = False
        for n in range(nlines):
            line = lines[n]
            
            if line[:9] == "     Step":
                
                data_header = data_header + line
                read_dat = True
                continue
            if read_dat == True:
                line_dat = line.split()
                if len(line_dat) == 83:
                    mod_dat.append(np.array(line_dat))
                
         
        model = np.array(mod_dat, dtype = float)
        
        data_columns = data_header.split()
        df = pd.DataFrame(data = model, columns = data_columns)  
           
            
        if savefile == True:
            os.system("mkdir -p {0}".format(output_dir)) #make "clean directory"
            np.savetxt(output_dir + "/" + file_name, 
                      model, header = data_header)
            
            

        return df, output_dir + "/" + file_name

