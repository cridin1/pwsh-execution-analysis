import os
import shutil
# resume the experiment with the samples unused

# get the path of the current input scripts
path_scripts = os.path.abspath(r"C:\Users\super\Desktop\tesi_magistrale\zircolite-test\data\data\test")
path_output = os.path.abspath(r"C:\Users\super\Desktop\tesi_magistrale\pwsh-execution-analysis\output\output")
resume_scripts = r"C:\Users\super\Desktop\tesi_magistrale\pwsh-execution-analysis\resume-scripts"

#create new dir for the new samples
os.makedirs(resume_scripts, exist_ok=True)
elems = os.listdir(os.path.join(path_output,'evtx'))
print(elems)

for elem_ps1 in os.listdir(os.path.join(path_scripts)):
    elem = elem_ps1.split(".")[0]
    if elem + ".evtx" in elems:
        #skip
        continue
    else:
        #copy the file
        shutil.copy(os.path.join(path_scripts,elem_ps1),resume_scripts)